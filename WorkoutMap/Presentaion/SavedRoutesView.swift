//
//  SavedRoutesView.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 05/09/2024.
//

import SwiftUI
import SwiftData

struct SavedRoutesView: View {
    @Query var routes: [Route]
    @Environment(\.modelContext) var context
    
    @State var editMode: EditMode = .inactive
    @State private var selectedRoute: Route?
    @State private var sortOption: SortOption = .name
    @State private var sortDirection: SortDirection = .ascending
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(sortedRoutes) { route in
                    NavigationLink {
                        SavedRouteDetailView(route: route)
                            .id(route.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(route.name)
                                .font(.headline)
                            Text("\(route.getDistance().to2Decimals()) km")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: delete)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Saved Routes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("Sort By") {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button {
                                    if sortOption == option {
                                        sortDirection = sortDirection.reverse()
                                    } else {
                                        sortDirection = .ascending
                                    }
                                    sortOption = option
                                } label: {
                                    Label(
                                        option.getTitle(),
                                        systemImage: sortOption == option ? 
                                            (sortDirection == .ascending ? "chevron.up" : "chevron.down") : ""
                                    )
                                }
                            }
                        }
                        
                        Section {
                            Button {
                                editMode = editMode == .active ? .inactive : .active
                            } label: {
                                Label(editMode == .active ? "Done" : "Edit List", 
                                      systemImage: editMode == .active ? "checkmark" : "pencil")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                    }
                }
            }
        } detail: {
            Text("Select a route to view details")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
    }
    
    var sortedRoutes: [Route] {
        switch sortOption {
        case .name:
            return sortDirection == .ascending ? routes.sorted { $0.name < $1.name } : routes.sorted { $0.name > $1.name }
        case .distance:
            return sortDirection == .ascending ? routes.sorted { $0.getDistance() < $1.getDistance() } : routes.sorted { $0.getDistance() > $1.getDistance() }
        }
    }
    
    func delete(at offsets: IndexSet) {
        let routesToDelete = offsets.map { self.routes[$0] }
        routesToDelete.forEach { route in
            context.delete(route)
        }
        
        try? context.save()
    }
}

enum SortOption: CaseIterable, Identifiable {
    case name
    case distance
    
    var id: Self { self }
    
    func getTitle() -> String {
        switch self {
        case .name:
            return "Name"
        case .distance:
            return "Distance"
        }
    }
}

enum SortDirection {
    case ascending
    case descending
    
    func reverse() -> SortDirection {
        switch self {
        case .ascending:
            return .descending
        case .descending:
            return .ascending
        }
    }
}
