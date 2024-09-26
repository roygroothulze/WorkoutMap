//
//  PastWorkoutsOnboardingView.swift
//  WorkoutMap
//
//  Created by Roy Groot Hulze on 26/09/2024.
//

import SwiftUI

struct PastWorkoutsOnboardingView: View {
    @Binding var didAskedForAccess: Bool
    @Binding var didGetAccess: Bool
    
    @State private var scale = 0.001
    @State private var buttonScale = 0.5
    
    func showError() -> Bool {
        didAskedForAccess && didGetAccess.reversed
    }
    
    func title() -> String {
        showError() ? "Error importing workouts" : "Import your workouts"
    }
    
    func description() -> String {
        showError() ? "Permission is needed to access your workouts." : "View your Running, Walking, and \nCycling workouts here and import the routes."
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Spacer()
                
                ImageWithOptionalOverlay(
                    showOverlay: showError(),
                    image: .runningCircle,
                    overlay: .slashCircle)
                .scaleEffect(scale)
                
                Spacer()
                
                ImageWithOptionalOverlay(
                    showOverlay: showError(),
                    image: .walkingCircle,
                    overlay: .slashCircle)
                .scaleEffect(scale)
                
                Spacer()
                
                ImageWithOptionalOverlay(
                    showOverlay: showError(),
                    image: .cycleCircle,
                    overlay: .slashCircle)
                .scaleEffect(scale)
                
                Spacer()
                Spacer()
            }
            .padding(.bottom, 16)
            
            Text(title())
                .font(.title)
                .padding(.bottom, 4)
                .transition(.opacity)
            Text(description())
                .font(.caption)
                .padding(.bottom, 8)
                .transition(.opacity)
            
            Button {
                _permissionButtonAction()
            } label: {
                Text("Give permission to load workouts")
            }
            .buttonStyle(.borderedProminent)
            .scaleEffect(buttonScale)
            
            Spacer()
            
            Text("We never store your data. All your data stays on your device or your iCloud account.")
                .padding(.bottom, 18)
                .foregroundStyle(.gray)
        }
        .padding(.horizontal, 20)
        .multilineTextAlignment(.center)
        .onAppear {
            // Animate the scale of the icons.
            // Animation needs to start on opening this view
            withAnimation(Animation.easeInOut(duration: 1)) {
                scale = 1
            }
            
            // Animate the scale of the button.
            withAnimation(Animation.easeInOut(duration: 0.5)) {
                buttonScale = 1
            }
        }
        .onDisappear {
            // Reset the scale to make the animation apeare again with onAppear
            scale = 0.001
            buttonScale = 0.5
        }
    }
    
    private func _permissionButtonAction() {
        withAnimation {
            // TODO: Ask for real access
            didAskedForAccess = true
            didGetAccess = true
        }
    }
}
