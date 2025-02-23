import SwiftUI

struct AuthView: View {
    @State private var isLogin = true

    var body: some View {
        NavigationView {
            VStack {
                if isLogin {
                    LoginView(isLogin: $isLogin)
                } else {
                    SignUpView(isLogin: $isLogin)
                }
            }
        }
    }
}
