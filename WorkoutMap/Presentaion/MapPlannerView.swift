//
//  MapPlannerView.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 05/09/2024.
//

import SwiftUI
import StoreKit

struct MapPlannerView: View {
    @Environment(\.requestReview) private var requestReview
    @Environment(\.modelContext) private var context
    
    @State private var route: Route = .empty()
    @State private var showConfirmDeleteDialog = false
    @State private var showSaveRouteDialog = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Main Map View
                MapView(route: $route, allowEditingRoute: true)
                    .ignoresSafeArea()
                
                // Bottom Action Bar
                HStack(spacing: 12) {
                    // Undo Button
                    ActionButton(
                        icon: "arrow.uturn.backward",
                        title: "Undo",
                        style: .primary,
                        action: route.removeLastLocation
                    )
                    .disabled(route.parts?.isEmpty ?? true)
                    
                    // New Route Button
                    ActionButton(
                        icon: "trash",
                        title: "Clear",
                        style: .destructive,
                        role: .destructive
                    ) {
                        showConfirmDeleteDialog.toggle()
                    }
                    .disabled(route.parts?.isEmpty ?? true)
                    
                    Spacer()
                    
                    // Save Button
                    ActionButton(
                        icon: "square.and.arrow.down",
                        title: "Save",
                        style: .primary
                    ) {
                        route.name = "Route of \(route.getDistance().to2Decimals())km"
                        showSaveRouteDialog.toggle()
                    }
                    .disabled(route.parts?.isEmpty ?? true)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background {
                    Rectangle()
                        .fill(.background)
                        .shadow(color: .black.opacity(0.1), radius: 8, y: -4)
                        .ignoresSafeArea()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    NavigationBarStats(
                        distance: route.getDistance(),
                        pinCount: route.pinLocations?.count ?? 0
                    )
                }
            }
            .alert("Save Route", isPresented: $showSaveRouteDialog) {
                VStack(spacing: 12) {
                    TextField("Route Name", text: $route.name)
                        .textFieldStyle(.roundedBorder)
                    
                    HStack {
                        Button("Cancel", role: .cancel) { }
                        Button("Save") {
                            _saveAsNewRoute()
                        }
                        .disabled(route.name.isEmpty)
                    }
                }
            } message: {
                Text("Give your route a memorable name")
            }
            .confirmationDialog(
                "Start New Route?",
                isPresented: $showConfirmDeleteDialog,
                actions: {
                    Button("Clear Route", role: .destructive) {
                        withAnimation {
                            route = .empty()
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                },
                message: {
                    Text("This will clear your current route. This action cannot be undone.")
                }
            )
        }
    }
    
    private func _saveAsNewRoute() {
        context.insert(route)
        try? context.save()
        requestReview()
    }
}

// MARK: - Supporting Views
struct NavigationBarStats: View {
    let distance: Double
    let pinCount: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Distance
            HStack(spacing: 4) {
                Image(systemName: "figure.walk")
                    .foregroundStyle(.blue)
                Text("\(distance.to2Decimals()) km")
                    .fontWeight(.medium)
            }
            
            // Divider
            Rectangle()
                .fill(.secondary.opacity(0.3))
                .frame(width: 1, height: 16)
            
            // Waypoints
            HStack(spacing: 4) {
                Image(systemName: "mappin")
                    .foregroundStyle(.red)
                Text("\(pinCount)")
                    .fontWeight(.medium)
            }
        }
        .font(.callout)
    }
}

// MARK: - Action Button Styles
enum ActionButtonStyleState {
    case primary
    case destructive
}

struct ActionButton: View {
    let icon: String
    let title: String
    var style: ActionButtonStyleState
    var role: ButtonRole? = nil
    let action: () -> Void
    
    var body: some View {
        Button(role: role, action: action) {
            VStack(spacing: 1) {
                Image(systemName: icon)
                    .renderingMode(.template)
                    .font(.system(size: 20))
                    .tint(.cyan)
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .frame(minWidth: style == .primary ? 70 : 50)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
            .foregroundStyle(foregroundColor)
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .primary
        case .destructive:
            return .red
        }
    }
}

