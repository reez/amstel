//
//  amstelApp.swift
//  amstel
//
//  Created by Robert Netzke on 7/2/25.
//

import SwiftData
import SwiftUI

@main
struct amstelApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WalletItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .navigationTitle("")
        }
        .modelContainer(sharedModelContainer)
    }
}
