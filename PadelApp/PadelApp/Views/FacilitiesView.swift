import SwiftUI
import FirebaseFirestore

struct FacilitiesView: View {
    @State private var facilities: [Facility] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if facilities.isEmpty {
                VStack {
                    Text("No Facilities Available")
                        .font(.headline)
                    Button("Add Sample Facilities") {
                        print("Button tapped!")
                        SampleDataManager.addSampleFacilities()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            loadFacilities()
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
            } else {
                List(facilities) { facility in
                    NavigationLink(destination: FacilityDetailView(facility: facility)) {
                        FacilityRowView(facility: facility)
                    }
                }
            }
        }
        .navigationTitle("Padel App")
        .alert("Error", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            loadFacilities()
        }
    }
    
    private func loadFacilities() {
        print("Loading facilities...")
        isLoading = true
        
        let db = Firestore.firestore()
        db.collection("facilities").getDocuments { snapshot, error in
            isLoading = false
            
            if let error = error {
                print("Error loading facilities: \(error)")
                errorMessage = error.localizedDescription
                showError = true
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No facilities found")
                return
            }
            
            print("Found \(documents.count) facilities")
            self.facilities = documents.compactMap { document in
                do {
                    let facility = try Facility(
                        id: document.documentID,
                        name: document.get("name") as? String ?? "",
                        address: document.get("address") as? String ?? "",
                        phoneNumber: document.get("phoneNumber") as? String ?? "",
                        email: document.get("email") as? String ?? "",
                        numberOfCourts: document.get("numberOfCourts") as? Int ?? 0,
                        openingHour: document.get("openingHour") as? Int ?? 0,
                        closingHour: document.get("closingHour") as? Int ?? 0,
                        imageURL: document.get("imageURL") as? String,
                        isActive: document.get("isActive") as? Bool ?? true,
                        pricePerHour: document.get("pricePerHour") as? Double ?? 0.0
                    )
                    print("Successfully parsed facility: \(facility.name)")
                    return facility
                } catch {
                    print("Error parsing facility: \(error)")
                    return nil
                }
            }
        }
    }
}

struct FacilityRowView: View {
    let facility: Facility
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(facility.name)
                .font(.headline)
            
            Text(facility.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "sportscourt")
                Text("\(facility.numberOfCourts) courts")
                
                Spacer()
                
                Text("$\(facility.pricePerHour, specifier: "%.2f")/hr")
                    .fontWeight(.semibold)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    FacilitiesView()
} 