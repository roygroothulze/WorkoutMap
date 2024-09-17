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
    var route: Route
    @State private var routeName = ""
    @State private var showRouteNameEditField: Bool = false
    
    var body: some View {
        Map {
            ForEach(route.parts ?? [], id: \.id) { part in
                MapPolyline(part.getPolyline())
                    .stroke(.blue, lineWidth: 2)
            }
            
            ForEach(route.getPinLocation()) { location in
                if (location == route.getPinLocation().first) {
                    Marker(coordinate: location.getAsCLLocationCoordinate2D()) {
                        Image(systemName: "flag.fill")
                    }
                    .tint(.red)
                } else if (location == route.getPinLocation().last) {
                    Marker(coordinate: location.getAsCLLocationCoordinate2D()) {
                        Image(systemName: "flag.pattern.checkered")
                    }
                    .tint(.green)
                } else {
                Marker(coordinate: location.getAsCLLocationCoordinate2D()) {
                        Text("")
                    }
                    .tint(.blue.opacity(0.5))
                }
            }
        }
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
