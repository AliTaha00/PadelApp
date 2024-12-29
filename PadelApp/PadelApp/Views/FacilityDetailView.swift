import SwiftUI
import FirebaseFirestore

struct FacilityDetailView: View {
    let facility: Facility
    @State private var courts: [Court] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Facility Information
                VStack(alignment: .leading, spacing: 8) {
                    if let imageURL = facility.imageURL {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                        }
                        .frame(height: 200)
                        .clipped()
                    }
                    
                    Text(facility.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "location")
                        Text(facility.address)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "clock")
                        Text("Open \(facility.openingHour):00 - \(facility.closingHour):00")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "phone")
                        Text(facility.phoneNumber)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                }
                
                // Courts Section
                Text("Available Courts")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if courts.isEmpty {
                    Text("No courts available")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                } else {
                    ForEach(courts) { court in
                        CourtRowView(court: court)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadCourts()
        }
        .alert("Error", isPresented: .constant(!errorMessage.isEmpty)) {
            Button("OK") { errorMessage = "" }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func loadCourts() {
        isLoading = true
        
        let db = Firestore.firestore()
        db.collection("courts")
            .whereField("facilityId", isEqualTo: facility.id)
            .getDocuments { snapshot, error in
                isLoading = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                
                courts = snapshot?.documents.compactMap { document in
                    try? document.data(as: Court.self)
                } ?? []
            }
    }
}

struct CourtRowView: View {
    let court: Court
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(court.name)
                    .font(.headline)
                
                Spacer()
                
                Text("$\(court.pricePerHour, specifier: "%.2f")/hr")
                    .fontWeight(.semibold)
            }
            
            HStack {
                Text(court.type.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(court.isAvailable ? "Available" : "Booked")
                    .foregroundColor(court.isAvailable ? .green : .red)
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
} 