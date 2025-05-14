import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserProfileView: View {
    @Binding var userIsLoggedIn: Bool
    @Binding var showUserSetup: Bool
    
    @State private var user: User?
    @State private var isLoading = false
    @State private var showingEditProfile = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemBackground), Color.blue.opacity(0.1)]), 
                          startPoint: .top, 
                          endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            if isLoading && user == nil {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    
                    Text("Loading profile...")
                        .foregroundColor(.secondary)
                        .padding(.top, 10)
                }
            } else if let user = user {
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        VStack(spacing: 20) {
                            // Avatar and name
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 110, height: 110)
                                    
                                    Text("\(String(user.firstName.prefix(1)))\(String(user.lastName.prefix(1)))")
                                        .font(.system(size: 40, weight: .semibold))
                                        .foregroundColor(.blue)
                                }
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                                )
                                
                                VStack(spacing: 4) {
                                    Text("\(user.firstName) \(user.lastName)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.top, 10)
                            
                            // Quick stats
                            HStack(spacing: 30) {
                                // Rating
                                VStack {
                                    ZStack {
                                        Circle()
                                            .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                                            .frame(width: 70, height: 70)
                                        
                                        Circle()
                                            .trim(from: 0, to: CGFloat(min(user.numericRating / 10, 1.0)))
                                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                            .frame(width: 70, height: 70)
                                            .rotationEffect(.degrees(-90))
                                        
                                        VStack(spacing: 0) {
                                            Text(String(format: "%.1f", user.numericRating))
                                                .font(.system(size: 24, weight: .bold))
                                                .foregroundColor(.blue)
                                            
                                            Text("/10")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Text("Rating")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 4)
                                }
                                
                                Divider()
                                    .frame(height: 50)
                                
                                // Experience level
                                ProfileStatItem(
                                    value: experienceText(user.padelExperience),
                                    label: "Experience",
                                    icon: "figure.tennis"
                                )
                                
                                Divider()
                                    .frame(height: 50)
                                
                                // Frequency
                                ProfileStatItem(
                                    value: frequencyText(user.playingFrequency),
                                    label: "Frequency",
                                    icon: "calendar"
                                )
                            }
                            .padding(.vertical, 15)
                            .padding(.horizontal)
                            .background(Color(UIColor.secondarySystemBackground).opacity(0.7))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // Player details section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Player Details")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                // Playing Style Row
                                HStack {
                                    ProfileDetailItem(
                                        icon: "hand.raised.fill",
                                        title: "Playing Hand",
                                        value: user.playingHand.rawValue
                                    )
                                    
                                    Spacer()
                                    
                                    ProfileDetailItem(
                                        icon: "sportscourt.fill",
                                        title: "Court Position",
                                        value: user.preferredPosition.rawValue
                                    )
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                
                                Divider()
                                    .padding(.horizontal)
                                
                                // Personal Info Row
                                HStack {
                                    ProfileDetailItem(
                                        icon: "person.fill",
                                        title: "Gender",
                                        value: user.gender.rawValue
                                    )
                                    
                                    Spacer()
                                    
                                    ProfileDetailItem(
                                        icon: "number",
                                        title: "Age",
                                        value: "\(user.age) years"
                                    )
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                
                                Divider()
                                    .padding(.horizontal)
                                
                                // Contact Info Row
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "phone.fill")
                                            .foregroundColor(.blue)
                                            .frame(width: 24)
                                        
                                        Text("Phone Number")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text(user.phoneNumber)
                                        .font(.body)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(UIColor.secondarySystemBackground))
                            }
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                        
                        // Action Buttons
                        VStack(spacing: 16) {
                            Button(action: { showingEditProfile = true }) {
                                HStack {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 16, weight: .semibold))
                                    
                                    Text("Edit Profile")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            Button(action: signOut) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.system(size: 16, weight: .semibold))
                                    
                                    Text("Sign Out")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.9))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.top, 15)
                }
            } else {
                VStack {
                    Text("Profile not available")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Button("Reload", action: loadUserProfile)
                        .padding(.top, 10)
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
    
    private func experienceText(_ experience: User.ExperienceLevel) -> String {
        switch experience {
        case .none:
            return "New"
        case .lessThanYear:
            return "Novice"
        case .oneToTwo:
            return "Intermediate"
        case .twoToFive:
            return "Advanced"
        case .moreThanFive:
            return "Expert"
        }
    }
    
    private func frequencyText(_ frequency: User.PlayingFrequency) -> String {
        switch frequency {
        case .rarely:
            return "Casual"
        case .occasionally:
            return "Regular"
        case .regularly:
            return "Frequent"
        case .frequently:
            return "Dedicated"
        }
    }
    
    private func loadUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
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

struct ProfileStatItem: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
            }
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ProfileDetailItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
            }
        }
    }
}

#Preview {
    UserProfileView(userIsLoggedIn: .constant(true), showUserSetup: .constant(false))
} 