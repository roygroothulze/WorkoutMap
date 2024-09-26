//
//  ImageWithOptionalOverlay.swift
//  WorkoutMap
//
//  Created by Roy Groot Hulze on 26/09/2024.
//

import SwiftUI

struct ImageWithOptionalOverlay: View {
    let showOverlay: Bool
    let image: Image
    let overlay: Image
    
    let iconSize: CGFloat = 70
    let iconOpacity: CGFloat = 0.7
    
    var body: some View {
        ZStack {
            image
                .resizable()
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(.accent.gradient)
                .opacity(iconOpacity)
            if showOverlay {
                overlay
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundStyle(.red.gradient)
            }
        }
    }
}
