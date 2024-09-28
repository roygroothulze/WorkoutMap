//
//  PastWorkoutSingleView.swift
//  WorkoutMap
//
//  Created by Roy Groot Hulze on 28/09/2024.
//

import SwiftUI
import MapKit

struct PastWorkoutSingleView: View {
    @ObservedObject private var workoutManager = WorkoutManager.shared
    var workout: Workout
    @State var route: [CLLocation]?
    @State private var mapPosition: MapCameraPosition = .automatic
    
    var body: some View {
        VStack {
            if let route {
                let polyline = route.asPolyline()
                
                Map(
                    position: $mapPosition
                ) {
                    MapPolyline(polyline)
                        .stroke(.blue, lineWidth: 3)
                }
                .frame(height: 300)
                .cornerRadius(10)
                .padding()
                
                Spacer()
            }
        }
        .task {
            await _loadRoute()
        }
    }
    
    private func _loadRoute() async {
        self.route = try? await workoutManager.getWorkoutRoute(for: workout)
    }
}
