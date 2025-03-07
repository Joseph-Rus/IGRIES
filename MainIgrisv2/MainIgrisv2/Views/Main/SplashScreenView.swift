import SwiftUI

struct SplashScreenView: View {
    // Animation states
    @State private var isAnimating = false
    @State private var showLogo = false
    @State private var showTitle = false
    @State private var showTagline = false
    @State private var logoScale: CGFloat = 0.8
    @State private var rotation: Double = 0
    
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
            // Background gradient - matched with TodoListView
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.7),
                    Color.purple.opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated circles in background
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 200)
                    .offset(x: -40, y: -100)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 150)
                    .offset(x: 100, y: 50)
                    .scaleEffect(isAnimating ? 1.0 : 0.6)
                
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 250)
                    .offset(x: 50, y: 200)
                    .scaleEffect(isAnimating ? 1.1 : 0.7)
            }
            .blur(radius: 30)
            
            // Floating college-themed objects animation
            ZStack {
                ForEach(floatingObjects.indices, id: \.self) { index in
                    FloatingObjectView(object: $floatingObjects[index])
                }
            }
            
            VStack(spacing: 30) {
                // Logo with glow and rotation
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.clear]),
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 150, height: 150)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .opacity(showLogo ? 1 : 0)
                    
                    Image("MainKnight")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .scaleEffect(logoScale)
                        .rotationEffect(.degrees(rotation))
                        .opacity(showLogo ? 1 : 0)
                }
                
                VStack(spacing: 15) {
                    // App title with scale animation
                    Text("IGRIS")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                        .scaleEffect(showTitle ? 1 : 0.5)
                        .opacity(showTitle ? 1 : 0)
                    
                    // Tagline with fade animation
                    Text("Your College Companion")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.9))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                        )
                        .opacity(showTagline ? 1 : 0)
                        .offset(y: showTagline ? 0 : 20)
                }
            }
            
            // Progress bar at bottom
            VStack {
                Spacer()
                ProgressBarView()
                    .frame(width: 200, height: 4)
                    .padding(.bottom, 50)
                    .opacity(isAnimating ? 1 : 0)
            }
        }
        .preferredColorScheme(.dark) // Match TodoListView dark mode
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
    
    var body: some View {
        Image(systemName: object.icon)
            .font(.system(size: 24 * object.scale))
            .foregroundColor(.white.opacity(0.5))
            .position(object.position)
            .offset(object.offset)
            .rotationEffect(.degrees(object.rotation + object.currentRotation))
    }
}

// Progress bar animation (more modern than dots)
struct ProgressBarView: View {
    @State private var progress: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.2))
                .frame(height: 4)
            
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 200 * progress, height: 4)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                progress = 1.0
            }
        }
    }
}

// Particle Effect (additional animation)
struct ParticleEffect: View {
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles.indices, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(particles[index].opacity))
                    .frame(width: particles[index].size, height: particles[index].size)
                    .position(particles[index].position)
            }
        }
        .onAppear {
            // Generate particles
            for _ in 0..<20 {
                let particle = Particle(
                    position: CGPoint(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    ),
                    size: CGFloat.random(in: 2...5),
                    opacity: Double.random(in: 0.3...0.7)
                )
                particles.append(particle)
            }
        }
    }
    
    struct Particle {
        var position: CGPoint
        var size: CGFloat
        var opacity: Double
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
            .preferredColorScheme(.dark)
    }
}
