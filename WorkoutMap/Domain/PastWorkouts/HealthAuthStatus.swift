//
//  HealthAuthStatus.swift
//  WorkoutMap
//
//  Created by Roy Groot Hulze on 26/09/2024.
//

import Foundation
import HealthKit

struct HealthAuthStatus {
    let workouts: HKAuthorizationStatus
    let walkingRunningDistance: HKAuthorizationStatus
    let cyclingDistance: HKAuthorizationStatus
    
    func isAllAllowed() -> Bool {
        workouts == .sharingAuthorized &&
        walkingRunningDistance == .sharingAuthorized &&
        cyclingDistance == .sharingAuthorized
    }
    
    func containsNotDetermined() -> Bool {
        workouts == .notDetermined ||
        walkingRunningDistance == .notDetermined ||
        cyclingDistance == .notDetermined
    }
}
