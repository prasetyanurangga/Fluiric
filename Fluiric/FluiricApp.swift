//
//  Spotify_LiyricApp.swift
//  Spotify Liyric
//
//  Created by Angga on 16/09/2023.
//

import SwiftUI

@main
struct Spotify_LiyricApp: App {
    
    @StateObject var spotifyManager = SpotifyManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(spotifyManager)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}
