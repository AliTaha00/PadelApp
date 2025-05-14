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
    @State private var courtType: Court.CourtType?
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemBackground), Color.blue.opacity(0.1)]), 
                          startPoint: .top, 
                          endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Booking status indicator
                    BookingStatusHeader(status: booking.status)
                    
                    // Main info card
                    VStack(spacing: 20) {
                        // Header with court and facility info
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(facilityName)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                
                                Text(courtName)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "sportscourt.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.blue)
                                .frame(width: 60, height: 60)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(15)
                        }
                        
                        Divider()
                        
                        // Date and time card
                        HStack(spacing: 30) {
                            DateTimeInfoCell(
                                title: "Date",
                                value: booking.date.formatted(date: .abbreviated, time: .omitted),
                                icon: "calendar"
                            )
                            
                            Divider()
                                .frame(height: 40)
                            
                            DateTimeInfoCell(
                                title: "Time",
                                value: "\(String(format: "%02d:00", booking.startTime)) - \(formatEndTime(start: booking.startTime, duration: booking.duration))",
                                icon: "clock"
                            )
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                        
                        // Court type and duration
                        HStack(spacing: 30) {
                            DateTimeInfoCell(
                                title: "Court Type",
                                value: courtType?.rawValue ?? "Standard",
                                icon: "house"
                            )
                            
                            Divider()
                                .frame(height: 40)
                            
                            DateTimeInfoCell(
                                title: "Duration",
                                value: formatDuration(minutes: booking.duration),
                                icon: "hourglass"
                            )
                        }
                        .padding(.vertical, 8)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Price Summary
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Payment Summary")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Court Rental")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(String(format: "$%.2f", booking.totalPrice))
                                    .fontWeight(.medium)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Total")
                                    .font(.headline)
                                Spacer()
                                Text(String(format: "$%.2f", booking.totalPrice))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    // Cancel Button
                    if booking.status == .confirmed || booking.status == .pending {
                        Button(action: { showCancelAlert = true }) {
                            HStack {
                                Spacer()
                                Text("Cancel Booking")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            .background(Color.red)
                            .cornerRadius(14)
                            .padding(.horizontal)
                        }
                        .padding(.top, 10)
                    }
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
            
            // Loading overlay
            if isLoading {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            
                            Text("Processing...")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.top, 10)
                        }
                    )
            }
        }
        .navigationTitle("Booking Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Cancel Booking", isPresented: $showCancelAlert) {
            Button("No, Keep It", role: .cancel) { }
            Button("Yes, Cancel", role: .destructive) {
                cancelBooking()
            }
        } message: {
            Text("Are you sure you want to cancel this booking? This action cannot be undone.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            loadFacilityAndCourtDetails()
        }
    }
    
    private func cancelBooking() {
        isLoading = true
        let db = Firestore.firestore()
        
        // First find the document by querying the id field
        db.collection("bookings")
            .whereField("id", isEqualTo: booking.id)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    self.isLoading = false
                    return
                }
                
                guard let document = querySnapshot?.documents.first else {
                    self.errorMessage = "Booking not found"
                    self.showError = true
                    self.isLoading = false
                    return
                }
                
                // Delete the document instead of updating it
                db.collection("bookings").document(document.documentID).delete { error in
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        self.showError = true
                    } else {
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
                courtType = court.type
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
            if remainingMinutes > 0 {
                return "\(hours)h \(remainingMinutes)m"
            } else {
                return "\(hours)h"
            }
        } else {
            return "\(minutes)m"
        }
    }
}

struct BookingStatusHeader: View {
    let status: Booking.BookingStatus
    
    var statusColor: Color {
        switch status {
        case .confirmed:
            return .green
        case .pending:
            return .orange
        case .completed:
            return .blue
        case .cancelled:
            return .red
        }
    }
    
    var statusIcon: String {
        switch status {
        case .confirmed:
            return "checkmark.circle.fill"
        case .pending:
            return "clock.fill"
        case .completed:
            return "flag.checkered.circle.fill"
        case .cancelled:
            return "xmark.circle.fill"
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: statusIcon)
                .font(.system(size: 18))
                .foregroundColor(statusColor)
            
            Text(status.rawValue.capitalized)
                .font(.headline)
                .foregroundColor(statusColor)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(statusColor.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct DateTimeInfoCell: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
} 