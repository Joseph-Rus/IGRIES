import SwiftUI

struct SplashScreenView: View {
    // Animation states
    @State private var isAnimating = false
    @State private var showLogo = false
    @State private var showTitle = false
    @State private var showTagline = false
    @State private var logoScale: CGFloat = 0.8
    @State private var rotation: Double = 0
    
    // Modern dark theme colors
    private let accentColor = Color(hexString: "6C5CE7")
    private let secondaryAccent = Color(hexString: "A29BFE")
    private let darkBackground = Color(hexString: "0F1120")
    private let cardBackground = Color(hexString: "1A1B2E")
    private let textPrimary = Color(hexString: "FFFFFF")
    private let textSecondary = Color(hexString: "A0A0B2")
    
    // College-themed floating objects animation
    @State private var floatingObjects: [FloatingObject] = [
        FloatingObject(icon: "book.fill", position: CGPoint(x: 50, y: 200), scale: 0.8, rotation: 15),
        FloatingObject(icon: "pencil", position: CGPoint(x: 300, y: 150), scale: 1.2, rotation: -20),
        FloatingObject(icon: "laptopcomputer", position: CGPoint(x: 120, y: 400), scale: 1.0, rotation: 10),
        FloatingObject(icon: "graduationcap.fill", position: CGPoint(x: 250, y: 300), scale: 0.9, rotation: -10),
        FloatingObject(icon: "calendar", position: CGPoint(x: 80, y: 350), scale: 0.7, rotation: 25),
        FloatingObject(icon: "clock.fill", position: CGPoint(x: 320, y: 420), scale: 0.6, rotation: -5),
        FloatingObject(icon: "lightbulb.fill", position: CGPoint(x: 180, y: 120), scale: 0.8, rotation: 30)
    ]
    
    var body: some View {
        ZStack {
            // Background gradient - modern dark
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hexString: "0F1120"),
                    Color(hexString: "151937")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Animated circles in background
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.05))
                    .frame(width: 220)
                    .offset(x: -40, y: -100)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                
                Circle()
                    .fill(secondaryAccent.opacity(0.05))
                    .frame(width: 180)
                    .offset(x: 100, y: 50)
                    .scaleEffect(isAnimating ? 1.0 : 0.6)
                
                Circle()
                    .fill(accentColor.opacity(0.07))
                    .frame(width: 280)
                    .offset(x: 50, y: 200)
                    .scaleEffect(isAnimating ? 1.1 : 0.7)
            }
            .blur(radius: 30)
            
            // Floating college-themed objects animation
            ZStack {
                ForEach(floatingObjects.indices, id: \.self) { index in
                    FloatingObjectView(object: $floatingObjects[index], accentColor: accentColor, secondaryAccent: secondaryAccent)
                }
            }
            
            VStack(spacing: 35) {
                // Logo with glow and rotation
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [accentColor.opacity(0.3), Color.clear]),
                                center: .center,
                                startRadius: 20,
                                endRadius: 120
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .opacity(showLogo ? 1 : 0)
                    
                    Image("MainKnight")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(accentColor, lineWidth: 3))
                        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
                        .scaleEffect(logoScale)
                        .rotationEffect(.degrees(rotation))
                        .opacity(showLogo ? 1 : 0)
                }
                
                VStack(spacing: 18) {
                    // App title with scale animation
                    Text("IGRIS")
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundColor(textPrimary)
                        .shadow(color: accentColor.opacity(0.6), radius: 8, x: 0, y: 4)
                        .scaleEffect(showTitle ? 1 : 0.5)
                        .opacity(showTitle ? 1 : 0)
                    
                    // Tagline with fade animation
                    Text("Your College Companion")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(textSecondary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(cardBackground)
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(accentColor.opacity(0.3), lineWidth: 1.5)
                        )
                        .opacity(showTagline ? 1 : 0)
                        .offset(y: showTagline ? 0 : 20)
                }
            }
            
            // Progress bar at bottom
            VStack {
                Spacer()
                ModernProgressBarView(accentColor: accentColor, secondaryAccent: secondaryAccent)
                    .frame(width: 220, height: 4)
                    .padding(.bottom, 60)
                    .opacity(isAnimating ? 1 : 0)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // Start animation sequence
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                showLogo = true
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.5)) {
                logoScale = 1.0
            }
            
            withAnimation(.easeOut(duration: 1.5).delay(0.2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            
            withAnimation(.easeInOut(duration: 0.8).delay(0.8)) {
                showTitle = true
            }
            
            withAnimation(.easeInOut(duration: 0.6).delay(1.2)) {
                showTagline = true
            }
            
            // Subtle rotation animation
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            // Animate floating objects
            for index in floatingObjects.indices {
                startFloatingAnimation(for: index)
            }
        }
    }
    
    // Function to animate floating objects
    private func startFloatingAnimation(for index: Int) {
        let randomDuration = Double.random(in: 8...15)
        let randomDelay = Double.random(in: 0...2)
        
        // Start with a random offset
        let startX = Double.random(in: -30...30)
        let startY = Double.random(in: -30...30)
        
        // Animate to a random position
        withAnimation(.easeInOut(duration: randomDuration).repeatForever(autoreverses: true).delay(randomDelay)) {
            floatingObjects[index].offset = CGSize(width: startX, height: startY)
        }
        
        // Animate rotation
        withAnimation(.linear(duration: Double.random(in: 10...20)).repeatForever(autoreverses: false).delay(randomDelay)) {
            floatingObjects[index].currentRotation = Double.random(in: -360...360)
        }
    }
}

// Model for floating objects
struct FloatingObject {
    let icon: String
    let position: CGPoint
    let scale: CGFloat
    let rotation: Double
    var offset: CGSize = .zero
    var currentRotation: Double = 0
}

// View for floating college-themed objects
struct FloatingObjectView: View {
    @Binding var object: FloatingObject
    var accentColor: Color
    var secondaryAccent: Color
    
    var body: some View {
        Image(systemName: object.icon)
            .font(.system(size: 24 * object.scale))
            .foregroundColor(
                [accentColor.opacity(0.3), secondaryAccent.opacity(0.3)].randomElement()!
            )
            .position(object.position)
            .offset(object.offset)
            .rotationEffect(.degrees(object.rotation + object.currentRotation))
            .shadow(color: accentColor.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}

// Modern progress bar animation
struct ModernProgressBarView: View {
    @State private var progress: CGFloat = 0
    var accentColor: Color
    var secondaryAccent: Color
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hexString: "2D2E45"))
                .frame(height: 6)
            
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [accentColor, secondaryAccent]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 220 * progress, height: 6)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                progress = 1.0
            }
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
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

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
            .preferredColorScheme(.dark)
    }
}
