import SwiftUI
import FirebaseAuth
import PhotosUI
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    // Access ThemeManager
    private let theme = ThemeManager.shared
    
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAccountAlert = false
    @State private var showingDeleteConfirmationAlert = false
    @State private var userEmail: String = ""
    @State private var userName: String = ""
    @State private var userJoinDate: String = "Unknown"
    @State private var showingNameSavedAlert = false
    
    // Photo picking states
    @State private var profileImage: UIImage?
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Use theme's background gradient
                theme.backgroundGradient
                    .ignoresSafeArea()
                
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
                            .overlay(Circle().stroke(theme.accentColor, lineWidth: 3))
                            .shadow(color: Color.black.opacity(0.2), radius: 8)
                            .padding(5)
                            .onTapGesture {
                                showingImagePicker = true
                            }
                            
                            // User name (editable)
                            TextField("Enter your name", text: $userName)
                                .font(theme.titleFont(size: 22))
                                .multilineTextAlignment(.center)
                                .foregroundColor(theme.textPrimary)
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
                            RoundedRectangle(cornerRadius: theme.cornerRadiusLarge)
                                .fill(theme.cardBackground)
                                .modifier(theme.standardShadow())
                        )
                        .padding(.horizontal)
                        
                        Spacer(minLength: 30)
                        
                        VStack(spacing: 16) {
                            // Logout button
                            Button(action: {
                                theme.configureAlertAppearance()
                                showingLogoutAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Logout")
                                        .font(theme.bodyFont(size: 16))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [theme.errorColor, Color(hexCode: "FF6B81")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(theme.cornerRadiusMedium)
                                .shadow(color: theme.errorColor.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            
                            // Delete account button
                            Button(action: {
                                theme.configureAlertAppearance()
                                showingDeleteAccountAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Delete Account")
                                        .font(theme.bodyFont(size: 16))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    Color(hexCode: "2C2C4A")
                                )
                                .cornerRadius(theme.cornerRadiusMedium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: theme.cornerRadiusMedium)
                                        .stroke(theme.errorColor, lineWidth: 1)
                                )
                            }
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
            .alert("Delete Account", isPresented: $showingDeleteAccountAlert, actions: {
                Button("Delete", role: .destructive) {
                    showingDeleteConfirmationAlert = true
                }
                Button("Cancel", role: .cancel) {}
            }, message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            })
            .alert("Confirm Deletion", isPresented: $showingDeleteConfirmationAlert, actions: {
                Button("Confirm Delete", role: .destructive) {
                    deleteUserAccount()
                }
                Button("Cancel", role: .cancel) {}
            }, message: {
                Text("This will permanently delete your account and all associated data. Type your password to confirm.")
            })
            .alert("Success", isPresented: $showingNameSavedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Profile updated successfully")
            }
            .sheet(isPresented: $showingImagePicker) {
                PhotoPicker(selectedImage: $profileImage)
            }
            .onAppear {
                loadUserData()
                loadProfileImage()
                
                // Configure alert appearance once at view appear
                theme.configureAlertAppearance()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(theme.titleFont(size: 18))
                        .foregroundColor(theme.textPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveUserName) {
                        Text("Save")
                            .font(theme.bodyFont(size: 16))
                            .foregroundColor(theme.accentColor)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func infoSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title)
                .font(theme.titleFont(size: 18))
                .foregroundColor(theme.textPrimary)
                .padding(.horizontal, 4)
            
            content()
        }
    }
    
    private func infoField(icon: String, title: String, value: String) -> some View {
        HStack {
            ZStack {
                Circle()
                    .fill(theme.accentColor.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(theme.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(theme.captionFont(size: 13))
                    .foregroundColor(theme.textSecondary)
                
                Text(value)
                    .font(theme.bodyFont(size: 16))
                    .foregroundColor(theme.textPrimary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadiusMedium)
                .fill(theme.cardBackgroundAlt)
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
    
    private func deleteUserAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        // First: Delete user data from Firestore database
        let db = Firestore.firestore()
        let userId = user.uid
        
        // Delete user document from users collection
        db.collection("users").document(userId).delete { error in
            if let error = error {
                print("Error removing user document: \(error.localizedDescription)")
            } else {
                print("User document successfully deleted")
            }
        }
        
        // Delete user tasks from tasks collection
        db.collection("tasks").whereField("userId", isEqualTo: userId)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting user tasks: \(error.localizedDescription)")
                } else if let documents = querySnapshot?.documents {
                    // Delete each task document
                    let batch = db.batch()
                    for document in documents {
                        batch.deleteDocument(document.reference)
                    }
                    
                    // Commit the batch delete
                    batch.commit { error in
                        if let error = error {
                            print("Error deleting user tasks: \(error.localizedDescription)")
                        } else {
                            print("User tasks successfully deleted")
                        }
                    }
                }
            }
        
        // Delete user data from UserDefaults
        UserDefaults.standard.removeObject(forKey: "profileImage_\(userId)")
        // Add any other user-specific data cleanup here
        
        // Finally: Delete the user account from Firebase Auth
        user.delete { error in
            if let error = error {
                print("Error deleting user account: \(error.localizedDescription)")
                // You might want to show an error alert here
            } else {
                print("User account successfully deleted")
                
                // Clear session data
                self.sessionManager.signOut()
                
                // Reset to login screen
                DispatchQueue.main.async {
                    self.resetToLogin()
                }
            }
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

// Photo Picker with improved text visibility
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        
        // Apply theme to picker
        ThemeManager.shared.configureAlertAppearance()
        
        // Force dark mode for the picker for better text visibility
        picker.overrideUserInterfaceStyle = .dark
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // Nothing to update
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
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

// Note: Application entry point has been removed from this file
// as it should be in your main App file instead
