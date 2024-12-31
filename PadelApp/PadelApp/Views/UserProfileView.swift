import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserProfileView: View {
    @State private var user: User?
    @State private var isLoading = false
    @State private var showingEditProfile = false
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading && user == nil {
                ProgressView()
            } else if let user = user {
                // Profile Summary
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("\(user.firstName) \(user.lastName)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(user.email)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    
                    Button(action: { showingEditProfile = true }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit Profile")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Button(action: signOut) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
        }
        .navigationTitle("Profile")
        .onAppear {
            if user == nil {
                loadUserProfile()
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            NavigationView {
                EditProfileView(user: user!) { updatedUser in
                    self.user = updatedUser
                }
            }
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error)")
        }
    }
    
    private func loadUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        print("Loading user profile for ID: \(userId)")
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error loading user profile: \(error)")
                isLoading = false
                return
            }
            
            if let document = document, document.exists, let data = document.data() {
                DispatchQueue.main.async {
                    // Create user object
                    self.user = User(
                        id: userId,
                        email: data["email"] as? String ?? "",
                        firstName: data["firstName"] as? String ?? "",
                        lastName: data["lastName"] as? String ?? "",
                        phoneNumber: data["phoneNumber"] as? String ?? "",
                        gender: User.Gender(rawValue: data["gender"] as? String ?? "male") ?? .male,
                        age: data["age"] as? Int ?? 0,
                        userType: User.UserType(rawValue: data["userType"] as? String ?? "player") ?? .player,
                        dateJoined: (data["dateJoined"] as? Timestamp)?.dateValue() ?? Date()
                    )
                    print("Successfully loaded user profile")
                }
            } else {
                print("No user document found")
            }
            
            isLoading = false
        }
    }
}

#Preview {
    UserProfileView()
} 