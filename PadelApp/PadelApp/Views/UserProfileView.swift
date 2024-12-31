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
            loadUserProfile()
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
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let user = try? document?.data(as: User.self) {
                self.firstName = user.firstName
                self.lastName = user.lastName
                self.phoneNumber = user.phoneNumber
                self.gender = user.gender
                self.age = String(user.age)
                self.user = user
            }
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
            }
        }
    }
}

#Preview {
    UserProfileView()
} 