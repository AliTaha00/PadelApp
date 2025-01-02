import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ChoiceButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct PlayerAssessmentView: View {
    @Binding var userIsLoggedIn: Bool
    @Binding var showUserSetup: Bool
    
    let userBasicInfo: [String: Any]
    
    @State private var playingHand = User.PlayingHand.right
    @State private var preferredPosition = User.CourtPosition.both
    @State private var padelExperience = User.ExperienceLevel.none
    @State private var racketSportsExperience = User.ExperienceLevel.none
    @State private var playingFrequency = User.PlayingFrequency.rarely
    
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Playing Hand Section
                    GroupBox(label: Text("Which hand do you play with?").font(.headline)) {
                        HStack(spacing: 10) {
                            ForEach([User.PlayingHand.right, .left], id: \.rawValue) { hand in
                                Button(hand.rawValue) {
                                    playingHand = hand
                                }
                                .buttonStyle(ChoiceButtonStyle(isSelected: playingHand == hand))
                            }
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                    
                    // Court Position Section
                    GroupBox(label: Text("Preferred Court Position").font(.headline)) {
                        VStack(spacing: 10) {
                            ForEach([User.CourtPosition.backhand, .forehand, .both], id: \.rawValue) { position in
                                Button(position.rawValue) {
                                    preferredPosition = position
                                }
                                .buttonStyle(ChoiceButtonStyle(isSelected: preferredPosition == position))
                            }
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                    
                    // Padel Experience Section
                    GroupBox(label: Text("How long have you played Padel?").font(.headline)) {
                        VStack(spacing: 10) {
                            ForEach([User.ExperienceLevel.none,
                                   .lessThanYear,
                                   .oneToTwo,
                                   .twoToFive,
                                   .moreThanFive], id: \.id) { level in
                                Button(level.rawValue) {
                                    padelExperience = level
                                }
                                .buttonStyle(ChoiceButtonStyle(isSelected: padelExperience == level))
                            }
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                    
                    // Other Racket Sports Experience
                    GroupBox(label: Text("Experience in other racket sports?").font(.headline)) {
                        VStack(spacing: 10) {
                            ForEach([User.ExperienceLevel.none,
                                   .lessThanYear,
                                   .oneToTwo,
                                   .twoToFive,
                                   .moreThanFive], id: \.id) { level in
                                Button(level.rawValue) {
                                    racketSportsExperience = level
                                }
                                .buttonStyle(ChoiceButtonStyle(isSelected: racketSportsExperience == level))
                            }
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                    
                    // Playing Frequency Section
                    GroupBox(label: Text("How often do you play?").font(.headline)) {
                        VStack(spacing: 10) {
                            ForEach([User.PlayingFrequency.rarely,
                                   .occasionally,
                                   .regularly,
                                   .frequently], id: \.id) { frequency in
                                Button(frequency.rawValue) {
                                    playingFrequency = frequency
                                }
                                .buttonStyle(ChoiceButtonStyle(isSelected: playingFrequency == frequency))
                            }
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Player Assessment")
            .navigationBarItems(trailing: 
                Button("Complete") {
                    completeAssessment()
                }
                .disabled(isLoading)
            )
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .interactiveDismissDisabled()
    }
    
    private func calculateInitialRating() -> Double {
        // Padel experience is weighted more heavily (60%)
        let padelContribution = padelExperience.ratingContribution * 0.6
        
        // Racket sports experience (25%)
        let racketSportsContribution = racketSportsExperience.ratingContribution * 0.25
        
        // Playing frequency (15%)
        let frequencyContribution = playingFrequency.ratingContribution * 0.15
        
        let baseRating = padelContribution + racketSportsContribution + frequencyContribution
        print("Calculated rating: \(baseRating)")
        return (baseRating * 100).rounded() / 100  // Round to 2 decimal places
    }
    
    private func completeAssessment() {
        isLoading = true
        
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User authentication error"
            showError = true
            isLoading = false
            return
        }
        
        var userData = userBasicInfo
        userData["playingHand"] = playingHand.rawValue
        userData["preferredPosition"] = preferredPosition.rawValue
        userData["padelExperience"] = padelExperience.rawValue
        userData["racketSportsExperience"] = racketSportsExperience.rawValue
        userData["playingFrequency"] = playingFrequency.rawValue
        userData["numericRating"] = calculateInitialRating()
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData(userData) { error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    print("Error saving user data: \(error.localizedDescription)")
                    errorMessage = "Failed to save profile: \(error.localizedDescription)"
                    showError = true
                } else {
                    print("Successfully saved user data")
                    showUserSetup = false
                    userIsLoggedIn = true
                }
            }
        }
    }
}