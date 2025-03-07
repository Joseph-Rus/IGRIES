import SwiftUI

struct AuthContainerView: View {
    @State private var isLogin = true
    
    var body: some View {
        if isLogin {
            LoginView(isLogin: $isLogin)
        } else {
            SignUpView(isLogin: $isLogin)
        }
    }
}

struct AuthContainerView_Previews: PreviewProvider {
    static var previews: some View {
        AuthContainerView()
    }
}
