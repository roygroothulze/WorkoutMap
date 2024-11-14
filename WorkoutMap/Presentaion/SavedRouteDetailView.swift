//
//  SavedRouteDetailView.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 05/09/2024.
//

import SwiftUI
import MapKit

struct SavedRouteDetailView: View {
    let route: Route
    
    var body: some View {
        MapView(route: .constant(route), allowEditingRoute: false)
            .navigationTitle(route.name)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(
                        item: route.name,
                        subject: Text("Check out this route!"),
                        message: Text("A \(route.getDistance().to2Decimals()) km route")
                    )
                }
            }
            .overlay(alignment: .bottom) {
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Distance")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("\(route.getDistance().to2Decimals()) km")
                                .font(.title2.bold())
                        }
                        Spacer()
                    }
                    .padding()
                    .background(.thinMaterial)
                }
            }
    }
}
