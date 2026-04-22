import SwiftUI
import CoreData

struct Home: View {
    @AppStorage(userIsLoggedInKey) private var isLoggedIn = false
    let persistence = PersistenceController.shared

    var body: some View {
        Menu(onLogout: handleLogout)
            .environment(\.managedObjectContext, persistence.container.viewContext)
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
