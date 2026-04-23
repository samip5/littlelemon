import SwiftUI
import CoreData

struct Home: View {
    @AppStorage(userIsLoggedInKey) private var isLoggedIn = false
    let persistence = PersistenceController.shared

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Menu(onLogout: handleLogout, onProfileTap: { selectedTab = 1 })
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .tabItem { Label("Menu", systemImage: "fork.knife") }
                .tag(0)

            UserProfile(onLogout: handleLogout)
                .tabItem { Label("Profile", systemImage: "person") }
                .tag(1)
        }
    }

    private func handleLogout() {
        let d = UserDefaults.standard
        [userFirstNameKey, userLastNameKey, userEmailKey,
         userPhoneKey, userOrderStatusNotifKey, userPasswordChangesNotifKey,
         userSpecialOffersNotifKey, userNewsletterNotifKey, "user_avatar_data"]
            .forEach { d.removeObject(forKey: $0) }
        isLoggedIn = false
    }
}

#Preview {
    Home()
}
