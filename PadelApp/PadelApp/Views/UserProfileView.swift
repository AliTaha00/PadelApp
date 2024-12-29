import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserProfileView: View {
    @State private var user: User?
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @State private var gender = User.Gender.male
    @State private var age = ""
    @State private var isLoading = false
    
    var body: some View {
        Form {
            Section(header: Text("Profile Information")) {
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
            
            Section {
                Button(action: saveProfile) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Save Changes")
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .onAppear(perform: loadUserProfile)
    }
    
    private func loadUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            isLoading = false
            if let document = document, document.exists {
                // Handle existing user data
                if let data = document.data() {
                    firstName = data["firstName"] as? String ?? ""
                    lastName = data["lastName"] as? String ?? ""
                    phoneNumber = data["phoneNumber"] as? String ?? ""
                    age = String(data["age"] as? Int ?? 0)
                    if let genderString = data["gender"] as? String {
                        gender = User.Gender(rawValue: genderString) ?? .male
                    }
                }
            } else {
                // New user
                user = User(
                    id: userId,
                    email: Auth.auth().currentUser?.email ?? "",
                    firstName: "",
                    lastName: "",
                    phoneNumber: "",
                    gender: .male,
                    age: 0,
                    userType: .player,
                    dateJoined: Date()
                )
            }
        }
    }
    
    private func saveProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        let userData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber,
            "gender": gender.rawValue,
            "age": Int(age) ?? 0,
            "userType": "player",
            "dateJoined": FieldValue.serverTimestamp()
        ]
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData(userData, merge: true) { error in
            isLoading = false
            if let error = error {
                print("Error saving profile: \(error)")
            }
        }
    }
}

#Preview {
    UserProfileView()
} 