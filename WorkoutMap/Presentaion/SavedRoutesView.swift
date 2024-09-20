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
                        Text(route.name)
                    }
                }
                .onDelete(perform: delete)
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("Saved Routes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button(action: {
                                    if sortOption == option {
                                        sortDirection = sortDirection.reverse()
                                    } else {
                                        sortDirection = .ascending
                                    }
                                    // Update the sort option regardless
                                    sortOption = option
                                }) {
                                    Label(option.getTitle(), systemImage: sortOption == option ? (sortDirection == .ascending ? "chevron.up" : "chevron.down") : "")
                                }
                            }
                        } label: {
                            Label("Sort By", systemImage: "arrow.up.arrow.down")
                        }
                        
                        Button {
                            editMode = editMode == .active ? .inactive : .active
                        } label: {
                            Label(editMode == .active ? "Done" : "Edit", systemImage: "pencil")
                        }
                    } label: {
                        Label("Options", systemImage: "ellipsis")
                    }
                }
            }
        } detail: {
            Text("Start by selecting a route to view its details.")
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
