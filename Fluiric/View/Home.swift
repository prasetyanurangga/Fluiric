
import SwiftUI
import ScriptingBridge
import ServiceManagement


struct Home: View {
    
    @State private var showFloatingWindow: Bool = true
    @EnvironmentObject var spotifyManager: SpotifyManager
    
    
    
    var body: some View {
        
        VStack{
            
        }.floatingWindow(poition: CGPoint(x: 0, y: 0), show: $showFloatingWindow) {
            
            GeometryReader{
                let size = $0.size
                if spotifyManager.loading {
                    Text("Loading ....").fontWeight(.bold)
                        .font(.system(size: 20))
                    
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .frame(width: size.width, height: size.height)
                } else if !spotifyManager.hasSpotifyApp {
                    Text("Please Open Spotify").fontWeight(.bold)
                        .font(.system(size: 20))
                    
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .frame(width: size.width, height: size.height)
                } else if !spotifyManager.hasPermission {
                    Text("Please Give me Automation Permission").fontWeight(.medium)
                        .font(.system(size: 20))
                    
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .frame(width: size.width, height: size.height)
                } else {
                    HStack{
                        VStack{
                            AsyncImage(url: URL(string: spotifyManager.currentArtworkUrl)) { phase in
                                switch phase {
                                        case .empty:
                                            Text("Loading...")
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 88, height: 88) // Set your desired width and height here
                                        case .failure:
                                            Text("Failed to load image")
                                        @unknown default:
                                            Text("Unknown state")
                                        }
                                    }
                            .frame(width: 88, height: 88)
                            .padding(.bottom, 4)
                            Text(spotifyManager.currentTrackName).font(
                                Font.custom("Poppins", size: 14)
                                .weight(.semibold)
                                )
                                .foregroundColor(.white).lineLimit(1) // Limit to a single line
                                .truncationMode(.tail)
                            Text(spotifyManager.currentArtistName).font(
                                Font.custom("Poppins", size: 11)
                                .weight(.light)
                                )
                                .foregroundColor(.white).lineLimit(1) // Limit to a single line
                                .truncationMode(.tail)
                                .padding(.bottom, 8)
                            HStack{
                                
                                    Image("backward").resizable()
                                        .scaledToFill()
                                        .onTapGesture {
                                            spotifyManager.handleBackward()
                                        }
                                    .frame(width: 15, height: 11)
                                Image(spotifyManager.isPlaying ? "pause" : "play").resizable()
                                    .scaledToFill()
                                    .onTapGesture {
                                        spotifyManager.handlePlayPause()
                                    }
                                .frame(width: 32, height: 32)
                                
                                    Image("forward").resizable()
                                        .scaledToFill()
                                        .onTapGesture {
                                            spotifyManager.handleForward()
                                        }
                                    .frame(width: 15, height: 11)
                            }
                        }.padding(.horizontal, 32) // Horizontal padding of 32 points
                            .padding(.vertical, 16)
                            .frame(width: 160)
                        if spotifyManager.loadingLyric {
                            Text("Loading ....").fontWeight(.bold)
                                .font(.system(size: 14))
                            
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32).frame(width: 355)
                        } else if !spotifyManager.lyrics.isEmpty && !spotifyManager.loadingLyric {
                            ScrollViewReader { pageScroller in
                                
                                ScrollView(showsIndicators: false){
                                    
                                    ForEach(spotifyManager.lyrics, id: \.self) { line in
                                        Text(line.words).fontWeight(spotifyManager.currentId == line.id ? .bold : .light)
                                            .font(.system(size: spotifyManager.currentId == line.id ? 20 : 14))
                                            .onTapGesture{
                                                spotifyManager.handleClickLyric(item: line)
                                            }
                                        
                                            .foregroundColor(Color.white)
                                            .multilineTextAlignment(.center)
                                            .padding(.top, 4)
                                        
                                            .id(line.id)
                                        
                                    }.onChange(of: spotifyManager.currentId) { newIndex in
                                        withAnimation {
                                            pageScroller.scrollTo(newIndex, anchor: .center)
                                        }
                                    }
                                }
                                .padding(.horizontal, 32).frame(width: 355)
                            }
                        } else if spotifyManager.lyrics.isEmpty {
                            Text("Lyric Not Found").fontWeight(.bold)
                                .font(.system(size: 14))
                            
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32).frame(width: 355)
                        }
                        
                    }.frame(width: size.width, height: size.height)
                }
            }
            .frame(width: 509, height: 248)
            .background(Color.black.opacity(0.5))
        }
    }
    
    
}

struct Home_Preview: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
