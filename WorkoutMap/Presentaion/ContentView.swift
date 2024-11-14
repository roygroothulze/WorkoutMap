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
                    Label("Plan Route", systemImage: "map.fill")
                }
            
            SavedRoutesView()
                .tabItem {
                    Label("Routes", systemImage: "list.bullet")
                }
        }
        .tint(.accentColor)
    }
}
