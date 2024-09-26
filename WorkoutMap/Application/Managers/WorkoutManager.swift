//
//  WorkoutManager.swift
//  WorkoutMap
//
//  Created by Roy Groot Hulze on 26/09/2024.
//

import SwiftUI
import HealthKit

class WorkoutManager: ObservableObject {
    static var shared: WorkoutManager = .init()
    
    @Published var workouts: [Workout] = []
    
    private let healthStore = HKHealthStore()
    
    private init() {}
    
    
    // Check if HealthKit is available on the device
    func isHealthKitAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    func isAuthorized() -> Bool {
        return healthStore.authorizationStatus(for: .workoutType()) == .sharingAuthorized
    }
    
    func isDenied() -> Bool {
        return healthStore.authorizationStatus(for: .workoutType()) == .sharingDenied
    }
    
    // Request authorization to access HealthKit data
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let readTypes: Set = [
            HKObjectType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!
        ]
        
        healthStore.requestAuthorization(toShare: readTypes, read: readTypes) { success, error in
            completion(success, error)
        }
    }
    
    func getAuthorizationStatus() -> HealthAuthStatus {
        let workoutType = HKObjectType.workoutType()
        let walkingRunningDistanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let cyclingDistanceType = HKQuantityType.quantityType(forIdentifier: .distanceCycling)!
        
        let workoutAuthStatus = healthStore.authorizationStatus(for: workoutType)
        let walkingRunningDistanceAuthStatus = healthStore.authorizationStatus(for: walkingRunningDistanceType)
        let cyclingDistanceAuthStatus = healthStore.authorizationStatus(for: cyclingDistanceType)
        
        return HealthAuthStatus(
            workouts: workoutAuthStatus,
            walkingRunningDistance: walkingRunningDistanceAuthStatus,
            cyclingDistance: cyclingDistanceAuthStatus
        )
    }
    
    // Sync workouts from the Health app
    func syncWorkouts(completion: @escaping (Bool, Error?) -> Void) {
        // Define workout predicate to fetch all workouts
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .greaterThanOrEqualTo, duration: 0)
        
        let sort = [
            // We want descending order to get the most recent date FIRST
             NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        ]
        
        let workoutQuery = HKSampleQuery(sampleType: HKObjectType.workoutType(),
                                         predicate: workoutPredicate,
                                         limit: 100,
                                         sortDescriptors: sort
        ) { [weak self] (_, samples, error) in
            guard let self = self, let workoutsSamples = samples as? [HKWorkout] else {
                completion(false, error)
                return
            }
            
            // Process each workout
            for workoutSample in workoutsSamples {
                if let type = self.getWorkoutType(from: workoutSample) {
                    let distance = self.getDistance(for: workoutSample)
                    let duration = workoutSample.duration
                    let date = workoutSample.startDate
                    
                    let workout = Workout(type: type, distance: distance, duration: duration, date: date)
                    workouts.append(workout)
                }
            }
            
            self.workouts = workouts
            completion(true, nil)
        }
        
        healthStore.execute(workoutQuery)
    }
    
    // Get all synced workouts
    func getAllWorkouts() -> [Workout] {
        return workouts
    }
    
    // Helper function to determine workout type from HKWorkout
    private func getWorkoutType(from workout: HKWorkout) -> WorkoutType? {
        switch workout.workoutActivityType {
        case .running:
            return .running
        case .walking:
            return .walking
        case .cycling:
            return .cycling
        default:
            return nil
        }
    }
    
    // Helper function to get the distance for a workout
    private func getDistance(for workout: HKWorkout) -> Double {
        if workout.totalDistance != nil {
            return workout.totalDistance!.doubleValue(for: HKUnit.meter()) / 1000.0 // Convert to kilometers
        }
        return 0.0
    }
}

