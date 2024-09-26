//
//  PastWorkoutsNoWorkoutsView.swift
//  WorkoutMap
//
//  Created by Roy Groot Hulze on 26/09/2024.
//

import SwiftUI

struct PastWorkoutsNoWorkoutsView: View {
    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding()
            Text("Access to your past workouts has been granted. Workouts will appear here.")
                .font(.headline)
                .padding()
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(.accent.gradient)
    }
}
