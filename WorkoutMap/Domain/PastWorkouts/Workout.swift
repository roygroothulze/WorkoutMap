//
//  Workout.swift
//  WorkoutMap
//
//  Created by Roy Groot Hulze on 26/09/2024.
//

import Foundation

struct Workout: Identifiable {
    let id: UUID = UUID()
    let type: WorkoutType
    let distance: Double // in kilometers
    let duration: TimeInterval // in seconds
    let date: Date
}
