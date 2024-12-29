import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserSetupView: View {
    @Binding var userIsLoggedIn: Bool
    @Environment(\.dismiss) var dismiss
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @State private var gender = User.Gender.male
    @State private var age = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                        .autocapitalization(.words)
                    
                    TextField("Last Name", text: $lastName)
                        .autocapitalization(.words)
                    
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
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: saveUserInfo) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Complete Setup")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.blue : Color.gray)
                    .cornerRadius(10)
                    .disabled(!isFormValid || isLoading)
                }
            }
            .navigationTitle("Complete Your Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Complete Your Profile")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .disabled(isLoading)
            .interactiveDismissDisabled(true)
        }
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !phoneNumber.isEmpty &&
        !age.isEmpty &&
        Int(age) != nil &&
        Int(age) ?? 0 > 0
    }
    
    private func saveUserInfo() {
        guard let ageInt = Int(age), ageInt > 0 else {
            errorMessage = "Please enter a valid age"
            return
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "No user found"
            return
        }
        
        isLoading = true
        
        let userData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber,
            "gender": gender.rawValue,
            "age": ageInt,
            "userType": "player",
            "dateJoined": FieldValue.serverTimestamp(),
            "email": Auth.auth().currentUser?.email ?? ""
        ]
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData(userData) { error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                userIsLoggedIn = true
            }
        }
    }
}

#Preview {
    UserSetupView(userIsLoggedIn: .constant(false))
} 