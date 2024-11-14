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
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button(role: .destructive) {
                        showConfirmDeleteDialog.toggle()
                    } label: {
                        Label("New Route", systemImage: "plus.circle.fill")
                            .foregroundStyle(.red)
                    }
                    
                    Button {
                        route.removeLastLocation()
                    } label: {
                        Label("Undo", systemImage: "arrow.uturn.backward.circle.fill")
                    }
                    .disabled(route.parts?.isEmpty ?? true)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        route.name = "Route of \(route.getDistance().to2Decimals())km"
                        showSaveRouteDialog.toggle()
                    } label: {
                        Label("Save", systemImage: "square.and.arrow.down.fill")
                    }
                    .disabled(route.parts?.isEmpty ?? true)
                    .alert("Save Route", isPresented: $showSaveRouteDialog) {
                        TextField("Route Name", text: $route.name)
                            .textFieldStyle(.roundedBorder)
                        Button("Cancel", role: .cancel) { }
                        Button("Save", action: _saveAsNewRoute)
                            .disabled(route.name.isEmpty)
                    } message: {
                        Text("Give your route a memorable name")
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
