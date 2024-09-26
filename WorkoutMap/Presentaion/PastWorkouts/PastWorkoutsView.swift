//
//  PastWorkoutsView.swift
//  WorkoutMap
//
//  Created by Roy Groot Hulze on 25/09/2024.
//

import SwiftUI

struct PastWorkoutsView: View {
    @ObservedObject private var workoutManager = WorkoutManager.shared
    @State private var didAskedForAccess: Bool = false
    @State private var didGetAccess: Bool = false
    
    init() {
        _initHealthKit()
    }
    
    var body: some View {
        // VStack is used to prevent app from moving to first tab after giving permission
        VStack {
            if (didGetAccess) {
                PastWorkoutsListView()
            } else {
                PastWorkoutsOnboardingView(
                    didAskedForAccess: $didAskedForAccess,
                    didGetAccess: $didGetAccess
                )
            }
        }
    }
    
    private func _initHealthKit() {
        // Only continue if healthkit is availble
        guard workoutManager.isHealthKitAvailable() else {
            // TODO: Show error when healthkit is not available
            print("HealthKit not available.")
            return
        }
        
        // Don't need to ask again foor authorization if already made choose
        if workoutManager.isAuthorized() {
            didGetAccess = true
        } else if workoutManager.isDenied() {
            didAskedForAccess = true
        }
        
    }
}

