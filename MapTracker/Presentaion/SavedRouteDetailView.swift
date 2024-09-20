//
//  SavedRouteDetailView.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 05/09/2024.
//

import SwiftUI
import MapKit

struct SavedRouteDetailView: View {
    @Environment(\.modelContext) private  var context
    @State private var route: Route
    @State private var routeName = ""
    @State private var showRouteNameEditField: Bool = false
    
    init(route: Route) {
        _route = .init(initialValue: route)
    }
    
    var body: some View {
        MapView(route: $route, allowEditingRoute: false)
            .navigationTitle(route.name)
            .toolbar {
                ToolbarItem {
                    Button {
                        routeName = route.name
                        showRouteNameEditField.toggle()
                    } label: {
                        Label("Edit name", systemImage: "pencil")
                    }
                    .alert("Enter the route name", isPresented: $showRouteNameEditField) {
                        TextField("Name", text: $routeName)
                        Button("Cancel", role: .cancel) {}
                        Button("Save", action: updateRouteName)
                            .disabled(routeName.isEmpty)
                    } message: {
                        Text("Give your route a name")
                    }
                }
            }
    }
    
    private func updateRouteName() {
        route.name = routeName
        try? context.save()
    }
}
