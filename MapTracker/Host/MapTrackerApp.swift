//
//  MapTrackerApp.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 03/09/2024.
//

import SwiftUI
import SwiftData
import TelemetryDeck

@main
struct MapTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Route.self,
            RoutePart.self,
            RoutePinLocation.self,
            CoordinateData.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        // TelemetryDeck
        let appId = (Bundle.main.object(forInfoDictionaryKey: "TELEMENTRYDECK_APP_ID") as? String) ?? ProcessInfo.processInfo.environment["TELEMENTRYDECK_APP_ID"]
        
        if let appId {
            let configuration = TelemetryManagerConfiguration(appID: appId)
            configuration.sendNewSessionBeganSignal = true
            configuration.testMode = Config.appConfiguration != .appStore
            TelemetryDeck.initialize(config: configuration)
        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
