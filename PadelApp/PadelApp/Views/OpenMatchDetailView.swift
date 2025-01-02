import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct OpenMatchDetailView: View {
    let match: OpenMatch
    @Environment(\.presentationMode) var presentationMode
    @State private var showCancelAlert = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        Form {
            Section(header: Text("Match Details")) {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text(match.facilityName)
                }
                
                HStack {
                    Image(systemName: "calendar")
                    Text(match.date.formatted(date: .long, time: .omitted))
                }
                
                HStack {
                    Image(systemName: "clock")
                    Text("\(match.timeSlot.formatted(date: .omitted, time: .shortened)) (\(match.duration) min)")
                }
                
                HStack {
                    Image(systemName: "person.2")
                    Text(match.matchType)
                }
                
                HStack {
                    Image(systemName: "figure.2.and.child.holdinghands")
                    Text(match.genderPreference)
                }
            }
            
            Section(header: Text("Players")) {
                Text("\(match.players.count)/4 Players")
            }
            
            if match.creatorId == Auth.auth().currentUser?.uid {
                Section {
                    Button(action: { showCancelAlert = true }) {
                        HStack {
                            Spacer()
                            Text("Cancel Match")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                    .disabled(isLoading)
                }
            }
        }
        .navigationTitle("Match Details")
        .alert("Error", isPresented: $showError) {
            Button("OK") { errorMessage = "" }
        } message: {
            Text(errorMessage)
        }
        .alert("Cancel Match", isPresented: $showCancelAlert) {
            Button("No", role: .cancel) { }
            Button("Yes", role: .destructive) {
                cancelMatch()
            }
        } message: {
            Text("Are you sure you want to cancel this match?")
        }
    }
    
    private func cancelMatch() {
        guard let matchId = match.id else { return }
        isLoading = true
        
        let db = Firestore.firestore()
        db.collection("openMatches").document(matchId).updateData([
            "status": "cancelled"
        ]) { error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
} 