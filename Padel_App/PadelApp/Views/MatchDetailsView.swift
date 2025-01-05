import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MatchDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var showMatchCreation: Bool
    @Binding var selectedTab: Int
    
    let facility: Facility
    let date: Date
    let timeSlot: Date
    let duration: Int
    
    @State private var matchType = MatchType.friendly
    @State private var genderPreference = GenderPreference.all
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    enum MatchType: String, CaseIterable {
        case friendly = "Friendly Match"
        case competitive = "Competitive Match"
    }
    
    enum GenderPreference: String, CaseIterable {
        case all = "All Players"
        case mixed = "Mixed Teams"
        case menOnly = "Men Only"
        case womenOnly = "Women Only"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Match Type")) {
                    Picker("Match Type", selection: $matchType) {
                        ForEach(MatchType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Player Preferences")) {
                    Picker("Gender Preference", selection: $genderPreference) {
                        ForEach(GenderPreference.allCases, id: \.self) { preference in
                            Text(preference.rawValue).tag(preference)
                        }
                    }
                }
                
                Section(header: Text("Match Details")) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text(facility.name)
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                        Text(date.formatted(date: .long, time: .omitted))
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                        Text("\(timeSlot.formatted(date: .omitted, time: .shortened)) (\(duration) min)")
                    }
                }
            }
            .navigationTitle("Match Details")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showMatchCreation = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createOpenMatch()
                    }
                    .disabled(isLoading)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK") {
                    showMatchCreation = false
                }
            } message: {
                Text("Open match created successfully!")
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
    
    private func createOpenMatch() {
        isLoading = true
        print("Starting to create match...")
        
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            showError = true
            isLoading = false
            print("Error: No user ID found")
            return
        }
        
        let db = Firestore.firestore()
        print("Creating match data for user: \(userId)")
        
        let matchData: [String: Any] = [
            "creatorId": userId,
            "facilityId": facility.id ?? "",
            "facilityName": facility.name,
            "date": Timestamp(date: date),
            "timeSlot": Timestamp(date: timeSlot),
            "duration": duration,
            "matchType": matchType.rawValue,
            "genderPreference": genderPreference.rawValue,
            "status": "open",
            "players": [userId],
            "createdAt": Timestamp(date: Date())
        ]
        
        print("Match data prepared: \(matchData)")
        
        db.collection("openMatches").addDocument(data: matchData) { error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    print("Error creating match: \(error.localizedDescription)")
                    errorMessage = "Failed to create match: \(error.localizedDescription)"
                    showError = true
                } else {
                    print("Match created successfully!")
                    showMatchCreation = false
                    selectedTab = 1
                }
            }
        }
    }
}

// Add this extension to enable programmatic navigation
extension View {
    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
        NavigationStack {
            self
                .navigationDestination(isPresented: binding) {
                    view
                }
        }
    }
} 