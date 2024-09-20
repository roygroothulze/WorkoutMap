//
//  MapPlannerView.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 05/09/2024.
//

import SwiftUI
import StoreKit

struct MapPlannerView: View {
    @Environment(\.requestReview) private var requestReview
    @Environment(\.modelContext) private  var context
    
    @State private var route: Route = .empty()
    @State private var showConfirmDeleteDialog = false
    @State private var showSaveRouteDialog = false
    
    var body: some View {
        NavigationStack {
            MapView(
                route: $route,
                allowEditingRoute: true
            )
            .navigationTitle("\(route.getDistance().to2Decimals()) km")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .destructive) {
                        showConfirmDeleteDialog.toggle()
                    } label: {
                        Text("New")
                    }
                    .confirmationDialog("Confirm", isPresented: $showConfirmDeleteDialog) {
                        Button(role: .destructive) {
                            route = .empty()
                            showConfirmDeleteDialog = false
                        } label: {
                            Text("Yes, delete route")
                        }
                    } message: {
                        Text("Are you sure you want to delete this route?")
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        route.removeLastLocation()
                    } label: {
                        Text("Undo")
                    }
                }
                
                ToolbarItem {
                    Button {
                        route.name = "Route of \(route.getDistance().to2Decimals())km"
                        showSaveRouteDialog.toggle()
                    } label: {
                        Text("Save route")
                    }
                    .disabled(route.parts?.isEmpty ?? true)
                    .alert("Enter the route name", isPresented: $showSaveRouteDialog) {
                        TextField("Name", text: $route.name)
                        Button("Save", action: _saveAsNewRoute)
                    } message: {
                        Text("Give your route a name")
                    }
                }
            }
        }
    }
    
    private func _saveAsNewRoute() {
        context.insert(route)
        try? context.save()
        
        requestReview()
    }
}
