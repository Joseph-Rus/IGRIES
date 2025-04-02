import SwiftUI

// Custom Shadow Modifier
struct Shadow: ViewModifier {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius, x: x, y: y)
    }
}

// Global theme manager for consistent styling
final class ThemeManager {
    // Singleton instance
    static let shared = ThemeManager()
    
    // MARK: - Colors
    // Main accent colors
    let accentColor = Color(hexCode: "6C5CE7")      // Primary purple
    let secondaryAccent = Color(hexCode: "A29BFE")  // Lighter purple
    
    // Background colors
    let darkBackground = Color(hexCode: "0F1120")   // Deep dark background
    let cardBackground = Color(hexCode: "1A1B2E")   // Card background
    let cardBackgroundAlt = Color(hexCode: "1D1E33") // Alternate card background
    
    // Text colors
    let textPrimary = Color(hexCode: "FFFFFF")      // White text
    let textSecondary = Color(hexCode: "A0A0B2")    // Gray text
    
    // Semantic colors
    let errorColor = Color(hexCode: "FF4757")       // Red for errors/overdue
    let successColor = Color(hexCode: "1DD1A1")     // Green for success/future
    let warningColor = Color(hexCode: "FFA41B")     // Orange for warnings/due today
    
    // Additional colors from HomeView
    let progressBackground = Color(hexCode: "2D2E45") // Progress bar background
    
    // MARK: - Gradients
    var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                darkBackground,
                Color(hexCode: "151937")
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var taskButtonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hexCode: "6C5CE7"), // accentColor
                Color(hexCode: "4834D4")  // Darker purple
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var cardGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hexCode: "1D1E33"), // cardBackgroundAlt
                Color(hexCode: "222339")  // Slightly lighter
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Corner Radius
    let cornerRadiusSmall: CGFloat = 8
    let cornerRadiusMedium: CGFloat = 16
    let cornerRadiusLarge: CGFloat = 20
    
    // MARK: - Shadow
    func standardShadow(radius: CGFloat = 15, x: CGFloat = 0, y: CGFloat = 5) -> some ViewModifier {
        return Shadow(
            color: Color.black.opacity(0.15),
            radius: radius,
            x: x,
            y: y
        )
    }
    
    func buttonShadow() -> some ViewModifier {
        return Shadow(
            color: Color.black.opacity(0.2),
            radius: 10,
            x: 0,
            y: 5
        )
    }
    
    // MARK: - Typography
    func titleFont(size: CGFloat = 18) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    
    func bodyFont(size: CGFloat = 16) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
    
    func captionFont(size: CGFloat = 14) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
    
    // Private initializer for singleton
    private init() {}
}

// MARK: - Color Extension with unique name
extension Color {
    init(hexCode: String) {
        let hex = hexCode.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
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
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
