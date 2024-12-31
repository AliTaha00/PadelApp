import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditProfileView: View {
    let user: User
    let onUpdate: (User) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var firstName: String
    @State private var lastName: String
    @State private var phoneNumber: String
    @State private var gender: User.Gender
    @State private var age: String
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    init(user: User, onUpdate: @escaping (User) -> Void) {
        self.user = user
        self.onUpdate = onUpdate
        _firstName = State(initialValue: user.firstName)
        _lastName = State(initialValue: user.lastName)
        _phoneNumber = State(initialValue: user.phoneNumber)
        _gender = State(initialValue: user.gender)
        _age = State(initialValue: String(user.age))
    }
    
    var body: some View {
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
        }
        .navigationTitle("Edit Profile")
        .navigationBarItems(
            leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            },
            trailing: Button("Save") {
                saveProfile()
            }
        )
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .disabled(isLoading)
    }
    
    private func saveProfile() {
        guard let userId = user.id else { return }
        guard let ageInt = Int(age), ageInt > 0 else {
            errorMessage = "Please enter a valid age"
            showError = true
            return
        }
        
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
            
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else {
                let updatedUser = User(
                    id: user.id,
                    email: user.email,
                    firstName: firstName,
                    lastName: lastName,
                    phoneNumber: phoneNumber,
                    gender: gender,
                    age: ageInt,
                    userType: user.userType,
                    dateJoined: user.dateJoined
                )
                onUpdate(updatedUser)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
} 