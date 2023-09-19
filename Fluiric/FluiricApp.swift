//
//  FluiricApp.swift
//  Fluiric
//
//  Created by Angga on 19/09/2023.
//

import SwiftUI

@main
struct FluiricApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
