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
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient - already matches TodoListView
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.7),
                        Color.purple.opacity(0.7)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Content
                ScrollView {
                    VStack(spacing: 25) {
                        // Profile header
                        VStack(spacing: 20) {
                            // Profile image with edit button
                            ZStack(alignment: .bottomTrailing) {
                                // Profile image
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
                                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                .shadow(color: Color.black.opacity(0.2), radius: 5)
                                .padding(5)
                                
                                // Edit button
                                Button(action: {
                                    showingImageSourceOptions = true
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 36, height: 36)
                                        
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.white)
                                    }
                                }
                                .offset(x: 5, y: 5)
                            }
                            .padding(.top, 20)
                            
                            // User name (editable)
                            TextField("Enter your name", text: $userName)
                                .font(.title2.bold())
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .submitLabel(.done)
                                .onSubmit {
                                    saveUserName()
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 5)
                        }
                        .padding()
                        
                        // Profile details card - updated to match TodoListView style
                        VStack(spacing: 20) {
                            // User info section
                            infoSection(title: "Personal Information") {
                                infoField(icon: "envelope.fill", title: "Email", value: userEmail)
                                infoField(icon: "calendar", title: "Joined", value: userJoinDate)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2)) // Updated to match TodoListView transparency
                        .cornerRadius(10) // Updated to match TodoListView corner radius
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2) // Updated to match TodoListView shadow
                        .padding(.horizontal)
                        
                        Spacer(minLength: 30)
                        
                        // Logout button
                        Button(action: {
                            showingLogoutAlert = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Logout")
                            }
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.red.opacity(0.8), .orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(10) // Updated to match TodoListView corner radius
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2) // Updated to match TodoListView shadow
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
                Text("Username saved successfully")
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveUserName) {
                        Text("Save")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .preferredColorScheme(.dark) // Added to match TodoListView
    }
    
    private func infoSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white) // Updated to always use white to match TodoListView
                .padding(.horizontal)
            
            content()
        }
    }
    
    private func infoField(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white) // Updated to white to match TodoListView
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7)) // Updated to match TodoListView
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.white) // Updated to always use white to match TodoListView
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.2)) // Updated to match TodoListView
        .cornerRadius(10) // Updated to match TodoListView
        .padding(.horizontal)
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
    
    // 3. Optimize the image picking with these changes to PhotoPicker Coordinator:
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(SessionManager())
            .preferredColorScheme(.dark) // Added to match TodoListView
    }
}
