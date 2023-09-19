import Foundation
import AppKit
import ScriptingBridge

struct Lyric: Decodable, Identifiable, Hashable {
    let id = UUID()
    let startTimeMs: String
    let words: String
    let syllables: [String]
    let endTimeMs: String
}

struct LyricResponse: Decodable {
    let error: Bool
    let syncType: String
    let lines: [Lyric]
}

class SpotifyManager: ObservableObject {
    
    @Published var currentTrackName = "N/A"
    @Published var currentArtistName = "N/A"
    @Published var currentArtworkUrl = ""
    @Published var currentPosition: Double = 0.0
    @Published var currentId: UUID?
    @Published var lyrics: [Lyric] = []
    @Published var hasSpotifyApp = false
    @Published var hasPermission = false
    @Published var loading = true
    @Published var loadingLyric = false
    @Published var isPlaying = false
    
    private var timer: Timer?
    private var currentSpotifyUrl = ""
    private var hasOpenSetting = false
    
    
    private var spotifyApplication: SpotifyApplication?
    
    init() {
        
        
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.handleAutomationPermissionChange()
        }
        
    }
    
    func startListen() {
        spotifyApplication = SBApplication(bundleIdentifier: "com.spotify.client")
        updateCurrentTrack()
        // Listen for changes to the current track
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleTrackChange),
            name: NSNotification.Name(rawValue: "com.spotify.client.PlaybackStateChanged"),
            object: nil
        )
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.updateCurrentPosition()
        }
    }
    
    private func updateCurrentPosition() {
        guard let spotify = spotifyApplication else { return }
        let playerPosition = spotify.playerPosition ?? 0.0
        if  playerPosition > 0  {
            currentPosition = playerPosition
            if !self.lyrics.isEmpty {
                let currentIndex = self.lyrics.lastIndex(where: { playerPosition * 1000 >= (Double($0.startTimeMs) ?? 0.0 )}) ?? -1
                if(currentIndex >= 0){
                    let bunch = self.lyrics
                    self.currentId = bunch[currentIndex].id
                } else {
                    self.currentId = nil
                }
            }
        }
    }
    
    @objc func handleTrackChange() {
        updateCurrentTrack()
    }
    
    func handleClickLyric(item: Lyric){
        let playerPosition = (Double(item.startTimeMs) ?? 0.0 ) / 1000
        spotifyApplication?.setPlayerPosition?(playerPosition)
    }
    
    
    func handleBackward(){
       
        spotifyApplication?.previousTrack?()
    }
    func handleForward(){
       
        spotifyApplication?.nextTrack?()
    }
    
    func handlePlayPause(){
       
        spotifyApplication?.playpause?()
    }
    
    @objc func handleAutomationPermissionChange() {
            let target = NSAppleEventDescriptor(bundleIdentifier: "com.spotify.client")
            let err = AEDeterminePermissionToAutomateTarget(target.aeDesc, typeWildCard, typeWildCard, true)
        
        print(err)

        if err == noErr {
            
            self.hasSpotifyApp = true
            self.hasPermission = true
            
            print("done")
            timer?.invalidate()
            timer = nil
            
            self.startListen()
        } else if err == -1743 {
            print("doneasdasd")
            self.hasSpotifyApp = true
            self.hasPermission = false
            
            if !self.hasOpenSetting {
                let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation")!
                NSWorkspace.shared.open(url)
                self.hasOpenSetting = true
            }
            
        }
        
        self.loading = false
        
        
    }

    
    

    
    private func updateCurrentTrack() {
        guard let spotify = spotifyApplication else { return }
        if let currentTrack = spotify.currentTrack {
            
            
            
            if(self.currentSpotifyUrl != currentTrack.spotifyUrl || self.lyrics.isEmpty){
                self.loadingLyric = true
                self.fetchNetworkLyrics(trackID:  currentTrack.spotifyUrl ?? "")
                self.currentSpotifyUrl = currentTrack.spotifyUrl ?? ""
                
                
            }
            
//
            self.isPlaying = spotifyApplication?.playerState == SpotifyEPlS.playing
            self.currentTrackName = currentTrack.name ?? ""
            self.currentArtistName = currentTrack.artist ?? ""
            self.currentArtworkUrl = currentTrack.artworkUrl ?? ""
            
            
            
        } else {
            self.currentTrackName = ""
            self.currentArtistName = ""
            self.currentArtworkUrl = ""
        }
    }
    func fetchNetworkLyrics(trackID: String){
            DispatchQueue.main.async {
                self.lyrics = []
            }
            if let url = URL(string: "https://spotify-lyric-api.herokuapp.com/?url=\(trackID)") {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data {
                        do {
                            let decodedData = try JSONDecoder().decode(LyricResponse.self, from: data)
                            DispatchQueue.main.async {
                                self.lyrics = decodedData.lines
                                self.loadingLyric = false
                            }
                        } catch {
                            print("Error decoding JSON: \(error.localizedDescription)")
                            self.loadingLyric = false
                        }
                    } else if let error = error {
                        print("Error fetching data: \(error.localizedDescription)")
                        self.loadingLyric = false
                    }
                }.resume()
            }
        }
    
    
}

