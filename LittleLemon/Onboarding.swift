import SwiftUI

let userFirstNameKey = "first name key"
let userLastNameKey = "last name key"
let userEmailKey = "email key"
let userIsLoggedInKey = "kIsLoggedIn"

struct Onboarding: View {
    @AppStorage(userIsLoggedInKey) private var isLoggedIn = false

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var page = 0

    var body: some View {
        VStack(spacing: 0) {
            header
            hero
            formArea
            Spacer()
        }
    }

    private var header: some View {
        HStack {
            Spacer()
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 40)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }

    private var hero: some View {
        ZStack {
            Color.llGreen
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Little Lemon")
                        .font(.markaziText(64, weight: .medium))
                        .foregroundColor(.llYellow)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Chicago")
                        .font(.markaziText(40))
                        .foregroundColor(.white)
                    Text("We are a family owned Mediterranean restaurant, focused on traditional recipes served with a modern twist.")
                        .font(.karla(18, weight: .medium))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)
                }
                .layoutPriority(1)

                Image("restaurantFood")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 130, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
    }

    private var formArea: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepIndicator

            if page == 0 {
                fieldBlock(label: "First name *", text: $firstName)
                actionButton(title: "Next",
                             enabled: !firstName.trimmingCharacters(in: .whitespaces).isEmpty) {
                    withAnimation { page = 1 }
                }
            } else if page == 1 {
                fieldBlock(label: "Last name *", text: $lastName)
                actionButton(title: "Next",
                             enabled: !lastName.trimmingCharacters(in: .whitespaces).isEmpty) {
                    withAnimation { page = 2 }
                }
            } else {
                emailBlock
                actionButton(title: "Create account", enabled: isValidEmail(email)) {
                    saveAndLogin()
                }
            }
        }
        .padding()
        .animation(.easeInOut, value: page)
    }

    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(i == page ? Color.llGreen : Color.llCloud)
                    .frame(width: 8, height: 8)
            }
            Spacer()
            Text("Step \(page + 1) of 3")
                .font(.karla(13))
                .foregroundColor(.secondary)
        }
    }

    private func fieldBlock(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.karla(16, weight: .semibold))
                .foregroundColor(.secondary)
            TextField("", text: text)
                .font(.karla(16))
                .padding(12)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.llCloud, lineWidth: 1.5))
        }
    }

    private var emailBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Email *")
                .font(.karla(16, weight: .semibold))
                .foregroundColor(.secondary)
            TextField("", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.karla(16))
                .padding(12)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.llCloud, lineWidth: 1.5))
        }
    }

    private func actionButton(title: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .disabled(!enabled)
            .font(.karla(18, weight: .bold))
            .foregroundColor(enabled ? .llDark : .white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(enabled ? Color.llYellow : Color.llCloud)
            .cornerRadius(10)
            .padding(.top, 8)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }

    private func saveAndLogin() {
        let d = UserDefaults.standard
        d.set(firstName.trimmingCharacters(in: .whitespaces), forKey: userFirstNameKey)
        d.set(lastName.trimmingCharacters(in: .whitespaces), forKey: userLastNameKey)
        d.set(email, forKey: userEmailKey)
        isLoggedIn = true
    }
}

#Preview {
    Onboarding()
}
