import SwiftUI

// MARK: - User Storage Keys
let userFirstNameKey = "first name key"
let userLastNameKey = "last name key"
let userEmailKey = "email key"
let userIsLoggedInKey = "kIsLoggedIn"

struct Onboarding: View {
    // User's registration information
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    
    // Controls whether we navigate to the home screen
    @State private var shouldShowHome = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                buildHeader()
                buildRegistrationForm()
                buildRegisterButton()
                Spacer()
            }
            .onAppear {
                checkIfAlreadyLoggedIn()
            }
            .navigationDestination(isPresented: $shouldShowHome) {
                Home(isLoggedIn: $shouldShowHome)
            }
        }
    }
    
    // MARK: - View Components
    
    private func buildHeader() -> some View {
        VStack(spacing: 10) {
            Text("Little Lemon")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.yellow)
                .padding(.top, 50)
            
            Text("Welcome!")
                .font(.title2)
                .padding(.bottom, 30)
        }
    }
    
    private func buildRegistrationForm() -> some View {
        VStack(spacing: 15) {
            TextField("First Name", text: $firstName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            TextField("Last Name", text: $lastName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .padding(.horizontal)
        }
        .padding(.bottom, 20)
    }
    
    private func buildRegisterButton() -> some View {
        Button {
            handleRegistration()
        } label: {
            Text("Register")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Actions
    
    private func checkIfAlreadyLoggedIn() {
        if UserDefaults.standard.bool(forKey: userIsLoggedInKey) {
            shouldShowHome = true
        }
    }
    
    private func handleRegistration() {
        guard isFormValid else { return }
        
        saveUserInformation()
        navigateToHome()
    }
    
    private func saveUserInformation() {
        UserDefaults.standard.set(firstName, forKey: userFirstNameKey)
        UserDefaults.standard.set(lastName, forKey: userLastNameKey)
        UserDefaults.standard.set(email, forKey: userEmailKey)
        UserDefaults.standard.set(true, forKey: userIsLoggedInKey)
    }
    
    private func navigateToHome() {
        shouldShowHome = true
    }
    
    // MARK: - Validation
    
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        isValidEmail(email)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailPattern)
        return emailTest.evaluate(with: email)
    }
}

#Preview {
    Onboarding()
}
