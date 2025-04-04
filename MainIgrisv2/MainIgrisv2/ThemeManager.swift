import SwiftUI
import UIKit

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
    
    // Text colors - UPDATED for better visibility
    let textPrimary = Color.white                   // Pure white for maximum contrast
    let textSecondary = Color(hexCode: "D0D0E2")    // Lighter gray text (brightened from A0A0B2)
    
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
    
    // MARK: - UI Element Styling
    
    // Configure action sheets and alerts for better text visibility
    func configureAlertAppearance() {
        // Force dark mode for all alerts and action sheets
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).overrideUserInterfaceStyle = .dark
        
        // Make text WHITE in action sheets (changed from default)
        UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).textColor = UIColor.white
        
        // Style buttons in action sheets
        let buttonAppearance = UIButton.appearance(whenContainedInInstancesOf: [UIAlertController.self])
        buttonAppearance.setTitleColor(UIColor(accentColor), for: .normal)
        
        // Make cancel buttons a different color (instead of "destructive" which doesn't exist as a UIControl.State)
        // We use highlighted state to make text red when tapped
        buttonAppearance.setTitleColor(UIColor(errorColor), for: .highlighted)
        
        // Attempt to set background color for action sheets (may not work on all iOS versions)
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).backgroundColor = UIColor(cardBackground)
    }
    
    // Configure tab bar appearance
    func configureTabBarAppearance() {
        // Set unselected tab items to a visible color
        UITabBar.appearance().unselectedItemTintColor = UIColor(textSecondary)
        
        // Set selected tab items to accent color
        UITabBar.appearance().tintColor = UIColor(accentColor)
        
        // Add slight background to tab bar
        UITabBar.appearance().backgroundColor = UIColor(darkBackground.opacity(0.7))
        
        // Make tab bar slightly translucent
        UITabBar.appearance().isTranslucent = true
    }
    
    // Apply theme across app
    func applyGlobalTheme() {
        configureAlertAppearance()
        configureTabBarAppearance()
        
        // Force all views to use dark mode
        UIView.appearance().overrideUserInterfaceStyle = .dark
        
        // Force all pickers to use dark mode with white text
        let pickerAppearance = UIPickerView.appearance()
        pickerAppearance.overrideUserInterfaceStyle = .dark
        
        // Force all alerts and sheet presenters to use dark mode
        let alertAppearance = UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self])
        alertAppearance.overrideUserInterfaceStyle = .dark
        
        // Ensure all pickers and photo pickers have visible text
        UILabel.appearance().textColor = .white
    }
    
    // Custom action sheet method that works with better visibility
    func actionSheet(
        title: String,
        message: String,
        buttons: [ActionSheetButton]
    ) -> ActionSheet {
        // First ensure appearance is configured
        configureAlertAppearance()
        
        // Convert our custom buttons to ActionSheet.Button
        var actionButtons: [ActionSheet.Button] = []
        
        for button in buttons {
            switch button.style {
            case .default:
                actionButtons.append(.default(Text(button.title), action: button.action))
            case .destructive:
                actionButtons.append(.destructive(Text(button.title), action: button.action))
            case .cancel:
                actionButtons.append(.cancel(Text(button.title), action: button.action))
            }
        }
        
        return ActionSheet(
            title: Text(title),
            message: Text(message),
            buttons: actionButtons
        )
    }
    
    // Custom button style for use with action sheets
    struct ActionSheetButton {
        enum Style {
            case `default`
            case destructive
            case cancel
        }
        
        let title: String
        let style: Style
        let action: (() -> Void)?
        
        static func `default`(_ title: String, action: (() -> Void)? = nil) -> ActionSheetButton {
            ActionSheetButton(title: title, style: .default, action: action)
        }
        
        static func destructive(_ title: String, action: (() -> Void)? = nil) -> ActionSheetButton {
            ActionSheetButton(title: title, style: .destructive, action: action)
        }
        
        static func cancel(_ title: String = "Cancel", action: (() -> Void)? = nil) -> ActionSheetButton {
            ActionSheetButton(title: title, style: .cancel, action: action)
        }
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

// MARK: - UIColor Extension for SwiftUI Color Conversion
extension UIColor {
    convenience init(_ color: Color) {
        if let cgColor = color.cgColor {
            self.init(cgColor: cgColor)
        } else {
            // Fallback to a visible color in case conversion fails
            self.init(white: 0.8, alpha: 1.0)
        }
    }
}
