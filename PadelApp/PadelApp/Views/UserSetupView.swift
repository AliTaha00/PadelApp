import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserSetupView: View {
    @Binding var userIsLoggedIn: Bool
    @Binding var showUserSetup: Bool
    @Environment(\.dismiss) var dismiss
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @State private var gender = User.Gender.male
    @State private var age = ""
    @State private var skillLevel = User.SkillLevel.beginner
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    
                    Picker("Gender", selection: $gender) {
                        Text("Male").tag(User.Gender.male)
                        Text("Female").tag(User.Gender.female)
                        Text("Other").tag(User.Gender.other)
                    }
                    
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Skill Level")) {
                    Picker("Skill Level", selection: $skillLevel) {
                        Text("Beginner").tag(User.SkillLevel.beginner)
                        Text("Intermediate").tag(User.SkillLevel.intermediate)
                        Text("Advanced").tag(User.SkillLevel.advanced)
                        Text("Expert").tag(User.SkillLevel.expert)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Text("Rating will start at: \(skillLevel.baseRating, specifier: "%.1f")")
                        .foregroundColor(.secondary)
                }
                
                if isLoading {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Complete Profile")
            .navigationBarItems(trailing: 
                Button("Complete Setup") {
                    completeSetup()
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
    
    private func completeSetup() {
        // Validate inputs
        guard let ageInt = Int(age), ageInt > 0 else {
            errorMessage = "Please enter a valid age"
            showError = true
            return
        }
        
        guard !firstName.isEmpty && !lastName.isEmpty && !phoneNumber.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        isLoading = true
        
        guard let userId = Auth.auth().currentUser?.uid,
              let userEmail = Auth.auth().currentUser?.email else {
            errorMessage = "User authentication error"
            showError = true
            isLoading = false
            return
        }
        
        let userData: [String: Any] = [
            "email": userEmail,
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber,
            "gender": gender.rawValue,
            "age": Int(age) ?? 0,
            "userType": User.UserType.player.rawValue,
            "dateJoined": Timestamp(date: Date()),
            "skillLevel": skillLevel.rawValue,
            "numericRating": skillLevel.baseRating
        ]
        
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

#Preview {
    UserSetupView(userIsLoggedIn: .constant(false), showUserSetup: .constant(true))
} 