import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MyBookingsView: View {
    @State private var bookings: [Booking] = []
    @State private var openMatches: [OpenMatch] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if bookings.isEmpty && openMatches.isEmpty {
                ContentUnavailableView("No Bookings", 
                    systemImage: "calendar",
                    description: Text("You haven't made any bookings yet")
                )
            } else {
                List {
                    if !bookings.isEmpty {
                        Section(header: Text("Court Bookings")) {
                            ForEach(bookings) { booking in
                                BookingRow(booking: booking)
                            }
                        }
                    }
                    
                    if !openMatches.isEmpty {
                        Section(header: Text("Open Matches")) {
                            ForEach(openMatches) { match in
                                OpenMatchRow(match: match)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("My Bookings")
        .onAppear {
            loadUserBookings()
            loadUserOpenMatches()
        }
    }
    
    private func loadUserBookings() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        let db = Firestore.firestore()
        db.collection("bookings")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error loading bookings: \(error)")
                    errorMessage = error.localizedDescription
                    return
                }
                
                self.bookings = snapshot?.documents.compactMap { document in
                    try? document.data(as: Booking.self)
                } ?? []
                
                isLoading = false
            }
    }
    
    private func loadUserOpenMatches() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("openMatches")
            .whereField("players", arrayContains: userId)
            .whereField("status", isEqualTo: "open")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error loading open matches: \(error)")
                    errorMessage = error.localizedDescription
                    return
                }
                
                self.openMatches = snapshot?.documents.compactMap { document in
                    var match = try? document.data(as: OpenMatch.self)
                    match?.id = document.documentID
                    return match
                } ?? []
                
                // Sort by creation date
                self.openMatches.sort { $0.createdAt > $1.createdAt }
            }
    }
}

struct BookingRow: View {
    let booking: Booking
    @State private var facilityName = ""
    @State private var courtName = ""
    
    var body: some View {
        NavigationLink(destination: BookingDetailView(booking: booking)) {
            VStack(alignment: .leading, spacing: 8) {
                Text(facilityName)
                    .font(.headline)
                Text(courtName)
                    .font(.subheadline)
                
                HStack {
                    Image(systemName: "calendar")
                    Text(booking.date.formatted(date: .long, time: .omitted))
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "clock")
                    Text("\(String(format: "%02d:00", booking.startTime)) - \(formatEndTime(start: booking.startTime, duration: booking.duration))")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                if booking.status == .cancelled {
                    Text("Cancelled")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
            }
            .padding(.vertical, 4)
        }
        .onAppear {
            loadFacilityAndCourtDetails()
        }
    }
    
    private func formatEndTime(start: Int, duration: Int) -> String {
        let endMinutes = (start * 60) + duration
        let endHour = endMinutes / 60
        let endMinute = endMinutes % 60
        return String(format: "%02d:%02d", endHour, endMinute)
    }
    
    private func loadFacilityAndCourtDetails() {
        let db = Firestore.firestore()
        
        db.collection("facilities").document(booking.facilityId).getDocument { document, error in
            if let facility = try? document?.data(as: Facility.self) {
                facilityName = facility.name
            }
        }
        
        db.collection("courts").document(booking.courtId).getDocument { document, error in
            if let court = try? document?.data(as: Court.self) {
                courtName = court.name
            }
        }
    }
}