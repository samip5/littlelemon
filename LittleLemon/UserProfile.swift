import SwiftUI
import PhotosUI

let userPhoneKey = "phone key"
let userOrderStatusNotifKey = "order status notifications"
let userPasswordChangesNotifKey = "password changes notifications"
let userSpecialOffersNotifKey = "special offers notifications"
let userNewsletterNotifKey = "newsletter notifications"

struct UserProfile: View {
    @State private var firstName: String
    @State private var lastName: String
    @State private var email: String
    @State private var phoneNumber: String
    @State private var orderStatuses: Bool
    @State private var passwordChanges: Bool
    @State private var specialOffers: Bool
    @State private var newsletter: Bool

    var onLogout: () -> Void

    init(onLogout: @escaping () -> Void = {}) {
        self.onLogout = onLogout
        let d = UserDefaults.standard
        _firstName = State(initialValue: d.string(forKey: userFirstNameKey) ?? "")
        _lastName = State(initialValue: d.string(forKey: userLastNameKey) ?? "")
        _email = State(initialValue: d.string(forKey: userEmailKey) ?? "")
        _phoneNumber = State(initialValue: d.string(forKey: userPhoneKey) ?? "")
        _orderStatuses = State(initialValue: d.object(forKey: userOrderStatusNotifKey) as? Bool ?? true)
        _passwordChanges = State(initialValue: d.object(forKey: userPasswordChangesNotifKey) as? Bool ?? true)
        _specialOffers = State(initialValue: d.object(forKey: userSpecialOffersNotifKey) as? Bool ?? true)
        _newsletter = State(initialValue: d.object(forKey: userNewsletterNotifKey) as? Bool ?? true)
    }

    @Environment(\.dismiss) private var dismiss
    @AppStorage("user_avatar_data") private var avatarData: Data = Data()
    @State private var selectedPhoto: PhotosPickerItem? = nil

    private var avatarImage: UIImage? {
        avatarData.isEmpty ? nil : UIImage(data: avatarData)
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationHeader(showBackButton: false)
            Divider()
            scrollContent
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Personal information")
                    .font(.karla(18, weight: .bold))

                avatarSection
                formSection
                notificationsSection
                logoutButton
                bottomButtons
            }
            .padding()
        }
    }

    private var avatarSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Avatar")
                .font(.karla(13))
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                Group {
                    if let image = avatarImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 72, height: 72)
                .clipShape(Circle())

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Text("Change")
                        .font(.karla(16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.llGreen)
                        .cornerRadius(8)
                }
                .onChange(of: selectedPhoto) {
                    Task {
                        if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                            avatarData = data
                        }
                    }
                }

                Button("Remove") {
                    avatarData = Data()
                    selectedPhoto = nil
                }
                .buttonStyle(OutlinedButtonStyle())
            }
        }
    }

    private var formSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            labeledField("First name", text: $firstName)
            labeledField("Last name", text: $lastName)
            labeledField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            labeledField("Phone number", text: $phoneNumber)
                .keyboardType(.phonePad)
        }
    }

    private func labeledField(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.karla(13))
                .foregroundColor(.secondary)
            TextField(label, text: text)
                .font(.karla(16))
                .padding(12)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.llCloud, lineWidth: 1.5))
        }
    }

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Email notifications")
                .font(.karla(18, weight: .bold))

            Toggle("Order statuses", isOn: $orderStatuses)
                .toggleStyle(CheckboxStyle())
            Toggle("Password changes", isOn: $passwordChanges)
                .toggleStyle(CheckboxStyle())
            Toggle("Special offers", isOn: $specialOffers)
                .toggleStyle(CheckboxStyle())
            Toggle("Newsletter", isOn: $newsletter)
                .toggleStyle(CheckboxStyle())
        }
    }

    private var logoutButton: some View {
        Button {
            onLogout()
        } label: {
            Text("Log out")
                .font(.karla(18, weight: .bold))
                .foregroundColor(.llDark)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.llYellow)
                .cornerRadius(8)
        }
    }

    private var bottomButtons: some View {
        HStack(spacing: 16) {
            Button("Discard changes") { discardChanges() }
                .buttonStyle(OutlinedButtonStyle())
                .frame(maxWidth: .infinity)

            Button("Save changes") { saveChanges() }
                .buttonStyle(FilledButtonStyle())
                .frame(maxWidth: .infinity)
        }
    }

    private func saveChanges() {
        let d = UserDefaults.standard
        d.set(firstName, forKey: userFirstNameKey)
        d.set(lastName, forKey: userLastNameKey)
        d.set(email, forKey: userEmailKey)
        d.set(phoneNumber, forKey: userPhoneKey)
        d.set(orderStatuses, forKey: userOrderStatusNotifKey)
        d.set(passwordChanges, forKey: userPasswordChangesNotifKey)
        d.set(specialOffers, forKey: userSpecialOffersNotifKey)
        d.set(newsletter, forKey: userNewsletterNotifKey)
    }

    private func discardChanges() {
        let d = UserDefaults.standard
        firstName = d.string(forKey: userFirstNameKey) ?? ""
        lastName = d.string(forKey: userLastNameKey) ?? ""
        email = d.string(forKey: userEmailKey) ?? ""
        phoneNumber = d.string(forKey: userPhoneKey) ?? ""
        orderStatuses = d.object(forKey: userOrderStatusNotifKey) as? Bool ?? true
        passwordChanges = d.object(forKey: userPasswordChangesNotifKey) as? Bool ?? true
        specialOffers = d.object(forKey: userSpecialOffersNotifKey) as? Bool ?? true
        newsletter = d.object(forKey: userNewsletterNotifKey) as? Bool ?? true
    }
}

private struct FilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.karla(16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.llGreen)
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

private struct OutlinedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.karla(16, weight: .semibold))
            .foregroundColor(.llDark)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.llCloud, lineWidth: 1.5))
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

private struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(configuration.isOn ? .llGreen : .secondary)
                    .font(.title3)
                configuration.label
                    .foregroundColor(.primary)
                    .font(.karla(16))
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    UserProfile()
}
