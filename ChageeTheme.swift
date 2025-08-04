import SwiftUI

// MARK: - Chagee Design System
struct ChageeTheme {
    
    // MARK: - Colors
    struct Colors {
        // Primary Brand Colors
        static let primaryGreen = Color(hex: "2A5A3E") // Deep forest green
        static let accentGold = Color(hex: "D4A574") // Warm gold
        static let cream = Color(hex: "F5F2E8") // Light cream background
        
        // UI Colors
        static let background = Color(hex: "FAFAF8")
        static let surface = Color.white
        static let text = Color(hex: "1A1A1A")
        static let textSecondary = Color(hex: "666666")
        static let divider = Color(hex: "E5E5E5")
        
        // Semantic Colors
        static let success = Color(hex: "4CAF50")
        static let warning = Color(hex: "FF9800")
        static let error = Color(hex: "F44336")
        
        // Gradient
        static let premiumGradient = LinearGradient(
            colors: [primaryGreen, primaryGreen.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .rounded)
        static let callout = Font.system(size: 16, weight: .medium, design: .rounded)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
        static let price = Font.system(size: 24, weight: .bold, design: .rounded).monospacedDigit()
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Radius
    struct Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let full: CGFloat = 9999
    }
    
    // MARK: - Shadow
    struct Shadow {
        static let sm = (color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        static let md = (color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        static let lg = (color: Color.black.opacity(0.1), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Custom View Modifiers
struct ChageeCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(ChageeTheme.Colors.surface)
            .cornerRadius(ChageeTheme.Radius.md)
            .shadow(
                color: ChageeTheme.Shadow.sm.color,
                radius: CGFloat(ChageeTheme.Shadow.sm.radius),
                x: CGFloat(ChageeTheme.Shadow.sm.x),
                y: CGFloat(ChageeTheme.Shadow.sm.y)
            )
    }
}

struct ChageePrimaryButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(ChageeTheme.Typography.callout)
            .foregroundColor(.white)
            .padding(.horizontal, ChageeTheme.Spacing.lg)
            .padding(.vertical, ChageeTheme.Spacing.md)
            .background(ChageeTheme.Colors.primaryGreen)
            .cornerRadius(ChageeTheme.Radius.full)
    }
}

struct ChageeSecondaryButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(ChageeTheme.Typography.callout)
            .foregroundColor(ChageeTheme.Colors.primaryGreen)
            .padding(.horizontal, ChageeTheme.Spacing.lg)
            .padding(.vertical, ChageeTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: ChageeTheme.Radius.full)
                    .stroke(ChageeTheme.Colors.primaryGreen, lineWidth: 1.5)
            )
    }
}

// MARK: - View Extensions
extension View {
    func chageeCard() -> some View {
        modifier(ChageeCardStyle())
    }
    
    func chageePrimaryButton() -> some View {
        modifier(ChageePrimaryButton())
    }
    
    func chageeSecondaryButton() -> some View {
        modifier(ChageeSecondaryButton())
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}