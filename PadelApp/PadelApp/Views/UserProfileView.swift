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
                    VStack(spacing: 24) {
                        // Basic Info Card
                        VStack(alignment: .leading) {
                            HStack(alignment: .center) {
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
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        
                        // Player Stats Card
                        VStack(spacing: 0) {
                            // Rating Section
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Player Rating")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(String(format: "%.2f", user.numericRating))
                                        .font(.system(size: 44, weight: .bold))
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                                // Rating Circle
                                ZStack {
                                    Circle()
                                        .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                                    Circle()
                                        .trim(from: 0, to: CGFloat(min(user.numericRating / 10, 1.0)))
                                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                        .rotationEffect(.degrees(-90))
                                }
                                .frame(width: 60, height: 60)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            
                            Divider()
                            
                            // Playing Style Section
                            HStack(spacing: 20) {
                                // Hand Preference
                                VStack {
                                    Image(systemName: "figure.tennis")
                                        .font(.system(size: 24))
                                        .foregroundColor(.blue)
                                    Text(user.playingHand.rawValue)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Divider()
                                    .frame(height: 40)
                                
                                // Court Position
                                VStack {
                                    Image(systemName: "sportscourt")
                                        .font(.system(size: 24))
                                        .foregroundColor(.blue)
                                    Text(user.preferredPosition.rawValue)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                        }
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        // Action Buttons
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