import SwiftUI
import FirebaseFirestore

struct BookingDetailView: View {
    let booking: Booking
    @Environment(\.presentationMode) var presentationMode
    @State private var showCancelAlert = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var facilityName = ""
    @State private var courtName = ""
    
    var body: some View {
        Form {
            Section(header: Text("Booking Details")) {
                InfoRow(title: "Facility", value: facilityName)
                InfoRow(title: "Court", value: courtName)
                InfoRow(title: "Date", value: booking.date.formatted(date: .long, time: .omitted))
                InfoRow(title: "Time", value: "\(String(format: "%02d:00", booking.startTime)) - \(formatEndTime(start: booking.startTime, duration: booking.duration))")
                InfoRow(title: "Duration", value: formatDuration(minutes: booking.duration))
                InfoRow(title: "Price", value: String(format: "$%.2f", booking.totalPrice))
                InfoRow(title: "Status", value: booking.status.rawValue.capitalized)
            }
            
            if booking.status != .cancelled {
                Section {
                    Button(action: {
                        showCancelAlert = true
                    }) {
                        Text("Cancel Booking")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("Booking Details")
        .alert("Cancel Booking", isPresented: $showCancelAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Confirm", role: .destructive) {
                cancelBooking()
            }
        } message: {
            Text("Are you sure you want to cancel this booking?")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .overlay {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
        .onAppear {
            print("Booking ID: \(booking.id)")
            loadFacilityAndCourtDetails()
        }
    }
    
    private func cancelBooking() {
        isLoading = true
        let db = Firestore.firestore()
        
        print("Attempting to delete booking with ID: \(booking.id)")
        
        // First find the document by querying the id field
        db.collection("bookings")
            .whereField("id", isEqualTo: booking.id)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error finding booking: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    self.isLoading = false
                    return
                }
                
                guard let document = querySnapshot?.documents.first else {
                    print("No booking found with ID: \(booking.id)")
                    self.errorMessage = "Booking not found"
                    self.showError = true
                    self.isLoading = false
                    return
                }
                
                // Delete the document instead of updating it
                db.collection("bookings").document(document.documentID).delete { error in
                    self.isLoading = false
                    if let error = error {
                        print("Error deleting booking: \(error.localizedDescription)")
                        self.errorMessage = error.localizedDescription
                        self.showError = true
                    } else {
                        print("Successfully deleted booking")
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
        }
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
    
    private func formatEndTime(start: Int, duration: Int) -> String {
        let endMinutes = (start * 60) + duration
        let endHour = endMinutes / 60
        let endMinute = endMinutes % 60
        return String(format: "%02d:%02d", endHour, endMinute)
    }
    
    private func formatDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)min"
        } else {
            return "\(minutes)min"
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
} 