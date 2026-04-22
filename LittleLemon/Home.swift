//
//  Home.swift
//  LittleLemon
//
//  Created by Skyler on 22.4.2026.
//

import SwiftUI
import CoreData

struct Home: View {
    @Binding var isLoggedIn: Bool
    let persistence = PersistenceController.shared
    
    var body: some View {
        TabView {
            buildMenuTab()
            buildProfileTab()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Tab Components
    
    private func buildMenuTab() -> some View {
        Menu()
            .environment(\.managedObjectContext, persistence.container.viewContext)
            .tabItem {
                Label("Menu", systemImage: "list.dash")
            }
    }
    
    private func buildProfileTab() -> some View {
        UserProfile(onLogout: handleLogout)
            .tabItem {
                Label("Profile", systemImage: "square.and.pencil")
            }
    }
    
    // MARK: - Actions
    
    private func handleLogout() {
        UserDefaults.standard.set(false, forKey: userIsLoggedInKey)
        isLoggedIn = false
    }
}

#Preview {
    Home(isLoggedIn: .constant(true))
}
