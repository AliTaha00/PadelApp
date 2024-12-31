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
    @State private var isEditing = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section(header: Text("Profile Information")) {
                if isLoading && user == nil {
                    ProgressView()
                } else {
                    TextField("First Name", text: $firstName)
                        .disabled(!isEditing)
                    TextField("Last Name", text: $lastName)
                        .disabled(!isEditing)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .disabled(!isEditing)
                    
                    Picker("Gender", selection: $gender) {
                        Text("Male").tag(User.Gender.male)
                        Text("Female").tag(User.Gender.female)
                        Text("Other").tag(User.Gender.other)
                    }
                    .disabled(!isEditing)
                    
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                        .disabled(!isEditing)
                }
            }
            
            if isEditing {
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
            
            Section {
                Button(action: signOut) {
                    HStack {
                        Spacer()
                        Text("Sign Out")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if isEditing {
                        // Cancel changes by reloading the current values
                        loadUserProfile()
                    }
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "Cancel" : "Edit")
                }
            }
        }
        .onAppear {
            if user == nil {
                loadUserProfile()
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
                    self.firstName = data["firstName"] as? String ?? ""
                    self.lastName = data["lastName"] as? String ?? ""
                    self.phoneNumber = data["phoneNumber"] as? String ?? ""
                    if let genderString = data["gender"] as? String {
                        self.gender = User.Gender(rawValue: genderString) ?? .male
                    }
                    self.age = String(data["age"] as? Int ?? 0)
                    
                    // Create user object
                    self.user = User(
                        id: userId,
                        email: data["email"] as? String ?? "",
                        firstName: self.firstName,
                        lastName: self.lastName,
                        phoneNumber: self.phoneNumber,
                        gender: self.gender,
                        age: Int(self.age) ?? 0,
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
    
    private func saveProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let ageInt = Int(age), ageInt > 0 else { return }
        
        isLoading = true
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData([
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber,
            "gender": gender.rawValue,
            "age": ageInt
        ]) { error in
            isLoading = false
            if error == nil {
                isEditing = false // Exit edit mode after successful save
                loadUserProfile() // Reload the profile after saving
            }
        }
    }
}

#Preview {
    UserProfileView()
} 