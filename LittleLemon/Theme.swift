import SwiftUI

// MARK: - Brand Fonts
extension Font {
    // Markazi Text — display/headline use
    static func markaziText(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .bold, .heavy, .black:      name = "MarkaziText-Bold"
        case .medium, .semibold:         name = "MarkaziText-Medium"
        default:                         name = "MarkaziText-Regular"
        }
        return .custom(name, size: size)
    }

    // Karla — body / UI text
    static func karla(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .black, .heavy:             name = "Karla-ExtraBold"
        case .bold:                      name = "Karla-Bold"
        case .semibold:                  name = "Karla-SemiBold"
        case .medium:                    name = "Karla-Medium"
        default:                         name = "Karla-Regular"
        }
        return .custom(name, size: size)
    }
}
