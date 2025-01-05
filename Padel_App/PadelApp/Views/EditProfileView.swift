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
    @State private var playingHand: User.PlayingHand
    @State private var preferredPosition: User.CourtPosition
    @State private var padelExperience: User.ExperienceLevel
    @State private var racketSportsExperience: User.ExperienceLevel
    @State private var playingFrequency: User.PlayingFrequency
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
        _playingHand = State(initialValue: user.playingHand)
        _preferredPosition = State(initialValue: user.preferredPosition)
        _padelExperience = State(initialValue: user.padelExperience)
        _racketSportsExperience = State(initialValue: user.racketSportsExperience)
        _playingFrequency = State(initialValue: user.playingFrequency)
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
            
            Section(header: Text("Playing Style")) {
                Picker("Playing Hand", selection: $playingHand) {
                    Text("Right").tag(User.PlayingHand.right)
                    Text("Left").tag(User.PlayingHand.left)
                }
                
                Picker("Preferred Position", selection: $preferredPosition) {
                    Text("Backhand").tag(User.CourtPosition.backhand)
                    Text("Forehand").tag(User.CourtPosition.forehand)
                    Text("Both").tag(User.CourtPosition.both)
                }
            }
            
            Section(header: Text("Experience")) {
                Picker("Padel Experience", selection: $padelExperience) {
                    ForEach([User.ExperienceLevel.none,
                            .lessThanYear,
                            .oneToTwo,
                            .twoToFive,
                            .moreThanFive], id: \.id) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                
                Picker("Other Racket Sports", selection: $racketSportsExperience) {
                    ForEach([User.ExperienceLevel.none,
                            .lessThanYear,
                            .oneToTwo,
                            .twoToFive,
                            .moreThanFive], id: \.id) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                
                Picker("Playing Frequency", selection: $playingFrequency) {
                    ForEach([User.PlayingFrequency.rarely,
                            .occasionally,
                            .regularly,
                            .frequently], id: \.id) { frequency in
                        Text(frequency.rawValue).tag(frequency)
                    }
                }
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarItems(trailing: Button("Save", action: saveProfile))
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func saveProfile() {
        guard let ageInt = Int(age), ageInt > 0 else {
            errorMessage = "Please enter a valid age"
            showError = true
            return
        }
        
        isLoading = true
        
        guard let userId = user.id else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData([
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber,
            "gender": gender.rawValue,
            "age": ageInt,
            "playingHand": playingHand.rawValue,
            "preferredPosition": preferredPosition.rawValue,
            "padelExperience": padelExperience.rawValue,
            "racketSportsExperience": racketSportsExperience.rawValue,
            "playingFrequency": playingFrequency.rawValue
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
                    dateJoined: user.dateJoined,
                    numericRating: user.numericRating,
                    playingHand: playingHand,
                    preferredPosition: preferredPosition,
                    padelExperience: padelExperience,
                    racketSportsExperience: racketSportsExperience,
                    playingFrequency: playingFrequency
                )
                onUpdate(updatedUser)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
} 