import SwiftUI

@main
struct LittleLemonApp: App {
    @AppStorage(userIsLoggedInKey) private var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                Home()
            } else {
                Onboarding()
            }
        }
    }
}
