import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserSetupView: View {
    @Binding var userIsLoggedIn: Bool
    @Binding var showUserSetup: Bool
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @State private var gender = User.Gender.male
    @State private var age = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showPlayerAssessment = false
    
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
                Button("Next") {
                    proceedToAssessment()
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
        .fullScreenCover(isPresented: $showPlayerAssessment) {
            PlayerAssessmentView(
                userIsLoggedIn: $userIsLoggedIn,
                showUserSetup: $showUserSetup,
                userBasicInfo: createUserBasicInfo()
            )
        }
    }
    
    private func createUserBasicInfo() -> [String: Any] {
        return [
            "email": Auth.auth().currentUser?.email ?? "",
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber,
            "gender": gender.rawValue,
            "age": Int(age) ?? 0,
            "userType": User.UserType.player.rawValue,
            "dateJoined": Timestamp(date: Date())
        ]
    }
    
    private func proceedToAssessment() {
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
        
        showPlayerAssessment = true
    }
}

#Preview {
    UserSetupView(userIsLoggedIn: .constant(false), showUserSetup: .constant(true))
} 