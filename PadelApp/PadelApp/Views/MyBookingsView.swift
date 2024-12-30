import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MyBookingsView: View {
    @State private var bookings: [Booking] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if bookings.isEmpty {
                ContentUnavailableView("No Bookings", 
                    systemImage: "calendar",
                    description: Text("You haven't made any bookings yet")
                )
            } else {
                List(bookings) { booking in
                    BookingRow(booking: booking)
                }
            }
        }
        .navigationTitle("My Bookings")
        .onAppear {
            loadUserBookings()
        }
    }
    
    private func loadUserBookings() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        print("Loading bookings for user: \(userId)")
        
        let db = Firestore.firestore()
        db.collection("bookings")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: Booking.BookingStatus.confirmed.rawValue)
            .getDocuments { snapshot, error in
                isLoading = false
                
                if let error = error {
                    print("Error loading bookings: \(error)")
                    errorMessage = error.localizedDescription
                    return
                }
                
                print("Found \(snapshot?.documents.count ?? 0) bookings")
                
                self.bookings = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    guard let id = data["id"] as? String,
                          let facilityId = data["facilityId"] as? String,
                          let courtId = data["courtId"] as? String,
                          let userId = data["userId"] as? String,
                          let timestamp = data["date"] as? Timestamp,
                          let startTime = data["startTime"] as? Int,
                          let duration = data["duration"] as? Int,
                          let status = data["status"] as? String,
                          let totalPrice = data["totalPrice"] as? Double else {
                        print("Failed to parse booking document: \(document.documentID)")
                        return nil
                    }
                    
                    return Booking(
                        id: id,
                        facilityId: facilityId,
                        courtId: courtId,
                        userId: userId,
                        date: timestamp.dateValue(),
                        startTime: startTime,
                        duration: duration,
                        status: Booking.BookingStatus(rawValue: status) ?? .pending,
                        totalPrice: totalPrice
                    )
                } ?? []
                
                print("Successfully loaded \(self.bookings.count) bookings")
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