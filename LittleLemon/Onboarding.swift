import SwiftUI

// MARK: - User Storage Keys
let userFirstNameKey = "first name key"
let userLastNameKey = "last name key"
let userEmailKey = "email key"
let userIsLoggedInKey = "kIsLoggedIn"

struct Onboarding: View {
    @AppStorage(userIsLoggedInKey) private var isLoggedIn = false

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                hero
                form
            }
        }
    }

    // MARK: - Header

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
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - Hero

    private var hero: some View {
        ZStack {
            Color(red: 0.29, green: 0.37, blue: 0.35)
            VStack(alignment: .leading, spacing: 4) {
                Text("Little Lemon")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 1.0, green: 0.80, blue: 0.0))
                Text("Chicago")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.bottom, 4)
                Text("We are a family owned Mediterranean restaurant, focused on traditional recipes served with a modern twist.")
                    .font(.callout)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }

    // MARK: - Form

    private var form: some View {
        VStack(alignment: .leading, spacing: 20) {
            formField(label: "First name *", text: $firstName)
            formField(label: "Last name *", text: $lastName)
            formField(label: "Email *", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            Button("Create account") {
                saveAndLogin()
            }
            .disabled(!isFormValid)
            .font(.headline)
            .foregroundColor(isFormValid ? .black : .white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isFormValid ? Color(red: 1.0, green: 0.80, blue: 0.0) : Color(UIColor.systemGray4))
            .cornerRadius(10)
            .padding(.top, 8)
        }
        .padding()
    }

    private func formField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            TextField("", text: text)
                .padding(12)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(UIColor.systemGray4), lineWidth: 1))
        }
    }

    // MARK: - Validation & Actions

    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        isValidEmail(email)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }

    private func saveAndLogin() {
        let d = UserDefaults.standard
        d.set(firstName.trimmingCharacters(in: .whitespaces), forKey: userFirstNameKey)
        d.set(lastName.trimmingCharacters(in: .whitespaces),  forKey: userLastNameKey)
        d.set(email,                                           forKey: userEmailKey)
        isLoggedIn = true
    }
}

#Preview {
    Onboarding()
}
