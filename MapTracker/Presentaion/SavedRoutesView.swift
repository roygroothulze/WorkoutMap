//
//  SavedRoutesView.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 05/09/2024.
//

import SwiftUI
import SwiftData

struct SavedRoutesView: View {
    @Query var routes: [Route]
    @Environment(\.modelContext) var context
    
    @State private var selectedRoute: Route?
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(routes) { route in
                    NavigationLink {
                        SavedRouteDetailView(route: route)
                    } label: {
                        Text(route.name)
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Saved Routes")
        } detail: {
            Text("No route selected")
        }
    }
    
    func delete(at offsets: IndexSet) {
        let routesToDelete = offsets.map { self.routes[$0] }
        routesToDelete.forEach { route in
            context.delete(route)
        }
        
        try? context.save()
        
    }
}
