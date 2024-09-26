//
//  PastWorkoutsView.swift
//  WorkoutMap
//
//  Created by Roy Groot Hulze on 25/09/2024.
//

import SwiftUI

struct PastWorkoutsView: View {
    @State var didAskedForAccess: Bool = false
    @State var didGetAccess: Bool = false
    
    var body: some View {
        // VStack is used to prevent app from moving to first tab after giving permission
        VStack {
            if (didGetAccess) {
                PastWorkoutsNoWorkoutsView()
            } else {
                PastWorkoutsOnboardingView(
                    didAskedForAccess: $didAskedForAccess,
                    didGetAccess: $didGetAccess
                )
            }
        }
    }
}
