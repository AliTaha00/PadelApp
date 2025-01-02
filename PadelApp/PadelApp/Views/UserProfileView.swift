import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserProfileView: View {
    @State private var user: User?
    @State private var isLoading = false
    @State private var showingEditProfile = false
    @Binding var userIsLoggedIn: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading && user == nil {
                ProgressView()
            } else if let user = user {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        // Basic Info
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
                        
                        // Playing Style
                        GroupBox(label: Text("Playing Style").font(.headline)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Playing Hand: \(user.playingHand.rawValue)")
                                Text("Preferred Position: \(user.preferredPosition.rawValue)")
                                Text("Current Rating: \(user.numericRating, specifier: "%.1f")")
                            }
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                        
                        // Experience
                        GroupBox(label: Text("Experience").font(.headline)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Padel: \(user.padelExperience.rawValue)")
                                Text("Other Racket Sports: \(user.racketSportsExperience.rawValue)")
                                Text("Playing Frequency: \(user.playingFrequency.rawValue)")
                            }
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                        
                        // Buttons
                        VStack(spacing: 12) {
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
                        }
                        .padding(.horizontal)
                    }
                }
            }
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
                    self.user = User(
                        id: userId,
                        email: data["email"] as? String ?? "",
                        firstName: data["firstName"] as? String ?? "",
                        lastName: data["lastName"] as? String ?? "",
                        phoneNumber: data["phoneNumber"] as? String ?? "",
                        gender: User.Gender(rawValue: data["gender"] as? String ?? "male") ?? .male,
                        age: data["age"] as? Int ?? 0,
                        userType: User.UserType(rawValue: data["userType"] as? String ?? "player") ?? .player,
                        dateJoined: (data["dateJoined"] as? Timestamp)?.dateValue() ?? Date(),
                        numericRating: data["numericRating"] as? Double ?? 1.0,
                        playingHand: User.PlayingHand(rawValue: data["playingHand"] as? String ?? "Right") ?? .right,
                        preferredPosition: User.CourtPosition(rawValue: data["preferredPosition"] as? String ?? "Both") ?? .both,
                        padelExperience: User.ExperienceLevel(rawValue: data["padelExperience"] as? String ?? "No Experience") ?? .none,
                        racketSportsExperience: User.ExperienceLevel(rawValue: data["racketSportsExperience"] as? String ?? "No Experience") ?? .none,
                        playingFrequency: User.PlayingFrequency(rawValue: data["playingFrequency"] as? String ?? "Less than once a month") ?? .rarely
                    )
                    print("Successfully loaded user profile")
                }
            }
            isLoading = false
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            userIsLoggedIn = false
        } catch {
            print("Error signing out: \(error)")
        }
    }
}

#Preview {
    UserProfileView(userIsLoggedIn: .constant(true))
} 