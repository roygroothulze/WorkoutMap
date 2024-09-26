//
//  Helper.swift
//  WorkoutMap
//
//  Created by Roy Groot Hulze on 26/09/2024.
//

import UIKit

struct Helper {
    static func openAppSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }
    }
}
