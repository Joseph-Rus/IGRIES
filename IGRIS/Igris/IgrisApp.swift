@main
struct IgrisApp: App {
    // Use UIApplicationDelegateAdaptor to hook into AppDelegate (for Firebase)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var sessionManager = SessionManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sessionManager)
        }
    }
}

// ✅ Move `.onOpenURL` inside a `View`
struct RootView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        Group {
            if sessionManager.isAuthenticated {
                MainChat()
            } else {
                AuthView()
            }
        }
        .onOpenURL { url in
            // This is critical for Google Sign-In to complete its redirect
            GIDSignIn.sharedInstance.handle(url)
        }
    }
}
