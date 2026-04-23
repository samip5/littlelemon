import SwiftUI

struct NavigationHeader: View {
    @AppStorage("user_avatar_data") private var avatarData: Data = Data()

    var showBackButton: Bool = false
    var onBack: () -> Void = {}
    var avatarAction: () -> Void = {}

    private var avatarImage: UIImage? {
        avatarData.isEmpty ? nil : UIImage(data: avatarData)
    }

    var body: some View {
        HStack(spacing: 0) {
            Group {
                if showBackButton {
                    Button(action: onBack) {
                        ZStack {
                            Circle()
                                .fill(Color.llGreen)
                                .frame(width: 40, height: 40)
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                } else {
                    Color.clear.frame(width: 40, height: 40)
                }
            }

            Spacer()

            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 40)

            Spacer()

            Button(action: avatarAction) {
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
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            }
            .disabled(showBackButton)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
}

#Preview {
    VStack {
        NavigationHeader(showBackButton: false)
        Divider()
        NavigationHeader(showBackButton: true)
    }
}
