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
    let route: HKAuthorizationStatus
    let walkingRunningDistance: HKAuthorizationStatus
    let cyclingDistance: HKAuthorizationStatus
    
    func isAllAllowed() -> Bool {
        workouts == .sharingAuthorized &&
        route == .sharingAuthorized &&
        walkingRunningDistance == .sharingAuthorized &&
        cyclingDistance == .sharingAuthorized
    }
    
    func containsNotDetermined() -> Bool {
        workouts == .notDetermined ||
        route == .notDetermined ||
        walkingRunningDistance == .notDetermined ||
        cyclingDistance == .notDetermined
    }
}
