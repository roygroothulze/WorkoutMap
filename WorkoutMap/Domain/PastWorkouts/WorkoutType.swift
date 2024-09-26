//
//  WorkoutType.swift
//  WorkoutMap
//
//  Created by Roy Groot Hulze on 26/09/2024.
//

import Foundation
import SwiftUICore

enum WorkoutType: String {
    case running = "Running"
    case walking = "Walking"
    case cycling = "Cycling"
    
    func getImage() -> Image {
        switch self {
        case .running: Image.running
        case .walking: Image.walking
        case .cycling: Image.cycle
        }
    }
}
