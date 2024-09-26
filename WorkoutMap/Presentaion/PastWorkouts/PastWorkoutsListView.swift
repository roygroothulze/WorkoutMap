//
//  PastWorkoutsListView.swift
//  WorkoutMap
//
//  Created by Roy Groot Hulze on 26/09/2024.
//

import SwiftUI

struct PastWorkoutsListView: View {
    @ObservedObject private var workoutManager = WorkoutManager.shared
    
    @State var workoutsLoaded: Bool = false
    @State var workouts: [Workout] = []
    
    var body: some View {
        let layout = workoutsLoaded ? AnyLayout(HStackLayout(spacing: 0)) : AnyLayout(VStackLayout(spacing: 0))
        let systemImageName = workoutsLoaded ? "figure.run.circle" : "checkmark.circle"
        let imageSize: CGFloat = workoutsLoaded ? 50 : 100
        let titleText = workoutsLoaded ? "Past workouts" : "Loading workouts..."
         
        VStack {
            layout {
                Image(systemName: systemImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize)
                    .padding(.trailing, workoutsLoaded ? 8 : 0)
                    .padding(.bottom, workoutsLoaded ? 0 : 16)
                    .id("hero-image")
                Text(titleText)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .id("hero-title")
                
                if workoutsLoaded.reversed {
                    Text("Access to your past workouts has been granted. Workouts will appear here.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .id("hero-caption")
                } else {
                    Spacer()
                }
                
            }
            .padding(.horizontal, 20)
            
            if workoutsLoaded {
                if workouts.isEmpty {
                    Spacer()
                    Text("No workouts yet.")
                        .font(.headline)
                    Spacer()
                } else {
                    List {
                        ForEach(workouts) { workout in
                            HStack {
                                workout.type.getImage()
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding(.trailing, 8)
                                    .padding(.vertical, 4)
                                
                                Text("\(workout.distance.to2Decimals()) km")
                                    .font(.callout)
                                
                                Spacer()
                                
                                Text(workout.date.formatted(.relative(presentation: .named)))
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: 700)
        .foregroundStyle(.accent.gradient)
        .onAppear {
            _loadWorkouts()
        }
    }
    
    private func _loadWorkouts() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            workoutManager.syncWorkouts { success, error in
                if success {
                    workouts = workoutManager.getAllWorkouts()
                    withAnimation {
                        workoutsLoaded = true
                    }
                }
            }
        }
    }
}
