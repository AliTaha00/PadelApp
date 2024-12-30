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
            
            Section {
                Button(action: { showCancelAlert = true }) {
                    HStack {
                        Spacer()
                        Text("Cancel Booking")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
                .disabled(booking.status != .confirmed || isLoading)
            }
        }
        .navigationTitle("Booking Details")
        .alert("Error", isPresented: $showError) {
            Button("OK") { errorMessage = "" }
        } message: {
            Text(errorMessage)
        }
        .alert("Cancel Booking", isPresented: $showCancelAlert) {
            Button("No", role: .cancel) { }
            Button("Yes", role: .destructive) {
                cancelBooking()
            }
        } message: {
            Text("Are you sure you want to cancel this booking?")
        }
        .onAppear {
            loadFacilityAndCourtDetails()
        }
    }
    
    private func loadFacilityAndCourtDetails() {
        let db = Firestore.firestore()
        
        // Load facility name
        db.collection("facilities").document(booking.facilityId).getDocument { document, error in
            if let facility = try? document?.data(as: Facility.self) {
                facilityName = facility.name
            }
        }
        
        // Load court name
        db.collection("courts").document(booking.courtId).getDocument { document, error in
            if let court = try? document?.data(as: Court.self) {
                courtName = court.name
            }
        }
    }
    
    private func cancelBooking() {
        isLoading = true
        let db = Firestore.firestore()
        
        db.collection("bookings").document(booking.id).updateData([
            "status": Booking.BookingStatus.cancelled.rawValue
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
    
    private func formatEndTime(start: Int, duration: Int) -> String {
        let endMinutes = (start * 60) + duration
        let endHour = endMinutes / 60
        let endMinute = endMinutes % 60
        return String(format: "%02d:%02d", endHour, endMinute)
    }
    
    private func formatDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if remainingMinutes == 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        } else {
            return "\(hours)h \(remainingMinutes)min"
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