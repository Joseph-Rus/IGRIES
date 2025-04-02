import SwiftUI
import FirebaseAuth
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showingLogoutAlert = false
    @State private var userEmail: String = ""
    @State private var userName: String = ""
    @State private var userJoinDate: String = "Unknown"
    @State private var showingNameSavedAlert = false
    
    // Photo picking states
    @State private var profileImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCameraSheet = false
    @State private var showingImageSourceOptions = false
    
    // Modern dark theme colors
    private let accentColor = Color(hex: "6C5CE7")
    private let secondaryAccent = Color(hex: "A29BFE")
    private let darkBackground = Color(hex: "0F1120")
    private let cardBackground = Color(hex: "1A1B2E")
    private let textPrimary = Color(hex: "FFFFFF")
    private let textSecondary = Color(hex: "A0A0B2")
    
    // Background gradient - modern dark
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "0F1120"),
                Color(hex: "151937")
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                // Content
                ScrollView {
                    VStack(spacing: 28) {
                        // Profile header
                        VStack(spacing: 20) {
                            // Profile image without edit button
                            Group {
                                if let profileImage = profileImage {
                                    Image(uiImage: profileImage)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image("MainKnight")
                                        .resizable()
                                        .scaledToFill()
                                }
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(accentColor, lineWidth: 3))
                            .shadow(color: Color.black.opacity(0.2), radius: 8)
                            .padding(5)
                            .onTapGesture {
                                showingImageSourceOptions = true
                            }
                            
                            // User name (editable)
                            TextField("Enter your name", text: $userName)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .foregroundColor(textPrimary)
                                .submitLabel(.done)
                                .onSubmit {
                                    saveUserName()
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 5)
                        }
                        .padding(.top, 20)
                        
                        // Profile details card - modern dark style
                        VStack(spacing: 24) {
                            // User info section
                            infoSection(title: "Personal Information") {
                                infoField(icon: "envelope.fill", title: "Email", value: userEmail)
                                infoField(icon: "calendar", title: "Joined", value: userJoinDate)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(cardBackground)
                                .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                        
                        Spacer(minLength: 30)
                        
                        // Logout button
                        Button(action: {
                            showingLogoutAlert = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Logout")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "FF4757"), Color(hex: "FF6B81")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color(hex: "FF4757").opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                    .padding(.vertical)
                }
            }
            .alert("Logout", isPresented: $showingLogoutAlert, actions: {
                Button("Logout", role: .destructive) {
                    sessionManager.signOut()
                    resetToLogin()
                }
                Button("Cancel", role: .cancel) {}
            }, message: {
                Text("Are you sure you want to logout?")
            })
            .alert("Success", isPresented: $showingNameSavedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Profile updated successfully")
            }
            .actionSheet(isPresented: $showingImageSourceOptions) {
                ActionSheet(
                    title: Text("Select Profile Image"),
                    message: Text("Choose a source"),
                    buttons: [
                        .default(Text("Photo Library")) {
                            showingImagePicker = true
                        },
                        .default(Text("Camera")) {
                            showingCameraSheet = true
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showingImagePicker) {
                PhotoPicker(selectedImage: $profileImage)
            }
            .sheet(isPresented: $showingCameraSheet) {
                CameraView(selectedImage: $profileImage)
            }
            .onAppear {
                loadUserData()
                loadProfileImage()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(textPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveUserName) {
                        Text("Save")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(accentColor)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func infoSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(textPrimary)
                .padding(.horizontal, 4)
            
            content()
        }
    }
    
    private func infoField(icon: String, title: String, value: String) -> some View {
        HStack {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(textSecondary)
                
                Text(value)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(textPrimary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "1D1E33"))
        )
    }
    
    private func loadUserData() {
        userEmail = sessionManager.currentUserEmail ?? "No email"
        userName = sessionManager.currentUserName ?? "User"
        if let user = Auth.auth().currentUser,
           let creationDate = user.metadata.creationDate {
            userJoinDate = DateFormatter.localizedString(from: creationDate, dateStyle: .medium, timeStyle: .none)
        }
    }
    
    private func loadProfileImage() {
        if let userId = sessionManager.currentUserId,
           let imageData = UserDefaults.standard.data(forKey: "profileImage_\(userId)"),
           let savedImage = UIImage(data: imageData) {
            profileImage = savedImage
        }
    }
    
    private func saveProfileImage() {
        // Only save if there's a user ID and image has changed
        guard let userId = sessionManager.currentUserId,
              let image = profileImage else { return }
        
        // Check if we need to save at all
        let imageKey = "profileImage_\(userId)"
        
        // Convert to data only once
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            // Use async operation to avoid blocking the UI thread
            DispatchQueue.global(qos: .background).async {
                UserDefaults.standard.set(imageData, forKey: imageKey)
            }
        }
    }
    
    private func saveUserName() {
        // Only update if name actually changed
        if userName != sessionManager.currentUserName {
            sessionManager.updateUserName(userName)
            showingNameSavedAlert = true
        }
        
        // Save profile image separately only when it changes
        if profileImage != nil {
            saveProfileImage()
        }
    }
    
    private func resetToLogin() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let authView = AuthContainerView()
                .environmentObject(sessionManager)
            window.rootViewController = UIHostingController(rootView: authView)
            window.makeKeyAndVisible()
        }
    }
}

// Photo Picker using PhotosUI
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // Nothing to update
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Optimize the image picking with these changes to PhotoPicker Coordinator:
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let result = results.first else { return }
            
            // Check if the item is a photo
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                    guard let image = object as? UIImage, error == nil else {
                        print("Error loading image: \(error?.localizedDescription ?? "unknown error")")
                        return
                    }
                    
                    // Process image on background thread
                    DispatchQueue.global(qos: .userInitiated).async {
                        // Resize image if too large (optional but recommended)
                        let resizedImage = self?.resizeImageIfNeeded(image, maxDimension: 1000)
                        
                        // Update UI on main thread
                        DispatchQueue.main.async {
                            self?.parent.selectedImage = resizedImage ?? image
                        }
                    }
                }
            }
        }
        
        // Helper method to resize images that are too large
        private func resizeImageIfNeeded(_ image: UIImage, maxDimension: CGFloat) -> UIImage? {
            let originalSize = image.size
            
            // Check if resizing is needed
            if originalSize.width <= maxDimension && originalSize.height <= maxDimension {
                return image
            }
            
            // Calculate new size while maintaining aspect ratio
            let ratio = originalSize.width / originalSize.height
            let newSize: CGSize
            
            if originalSize.width > originalSize.height {
                newSize = CGSize(width: maxDimension, height: maxDimension / ratio)
            } else {
                newSize = CGSize(width: maxDimension * ratio, height: maxDimension)
            }
            
            // Create a new image with the calculated size
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return resizedImage
        }
    }
}

// Camera View for taking photos
struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Nothing to update
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(SessionManager())
            .preferredColorScheme(.dark)
    }
}
