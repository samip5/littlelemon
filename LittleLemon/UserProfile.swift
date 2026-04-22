import SwiftUI

struct UserProfile: View {
    let firstName = UserDefaults.standard.string(forKey: userFirstNameKey)
    let lastName = UserDefaults.standard.string(forKey: userLastNameKey)
    let email = UserDefaults.standard.string(forKey: userEmailKey)
    
    // This gets called when user wants to log out
    var onLogout: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 20) {
            buildTitle()
            buildProfileImage()
            buildUserInformation()
            buildLogoutButton()
            Spacer()
        }
        .padding()
    }
    
    // MARK: - View Components
    
    private func buildTitle() -> some View {
        Text("Personal information")
            .font(.title2)
            .fontWeight(.semibold)
    }
    
    private func buildProfileImage() -> some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .foregroundColor(.gray)
    }
    
    private func buildUserInformation() -> some View {
        VStack(spacing: 10) {
            buildInfoRow(label: "First Name", value: firstName)
            buildInfoRow(label: "Last Name", value: lastName)
            buildInfoRow(label: "Email", value: email)
        }
        .padding(.vertical)
    }
    
    private func buildInfoRow(label: String, value: String?) -> some View {
        HStack {
            Text(label)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Spacer()
            Text(value ?? "Not set")
                .foregroundColor(.primary)
        }
        .padding(.horizontal)
    }
    
    private func buildLogoutButton() -> some View {
        Button {
            onLogout()
        } label: {
            Text("Logout")
                .font(.headline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
}

#Preview {
    UserProfile()
}
