import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color.knightGray // Consistent with your app’s theme
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("MainKnight") // Your app’s logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120) // Smaller size for efficiency
                    .clipShape(Circle())
                
                Text("IGRIS")
                    .font(.title) // Slightly smaller font for faster rendering
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
