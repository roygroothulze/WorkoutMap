//
//  ContentView.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 03/09/2024.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        TabView {
            MapPlannerView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            SavedRoutesView()
                .tabItem {
                    Label("Saved Routes", systemImage: "folder.badge.plus")
                }
        }
    }
}
