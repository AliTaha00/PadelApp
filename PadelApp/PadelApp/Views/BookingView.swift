import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct BookingView: View {
    let facility: Facility
    let court: Court
    let date: Date
    @Binding var isPresented: Bool
    
    @State private var selectedHour: Int?
    @State private var duration = 1
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Booking Details")) {
                    Text("Court: \(court.name)")
                    Text("Date: \(date.formatted(date: .long, time: .omitted))")
                }
                
                Section(header: Text("Select Time")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(facility.openingHour..<facility.closingHour, id: \.self) { hour in
                                TimeSlotButton(
                                    hour: hour,
                                    isSelected: selectedHour == hour,
                                    action: { selectedHour = hour }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Section(header: Text("Duration")) {
                    Picker("Duration", selection: $duration) {
                        ForEach([30, 60, 90, 120, 150, 180], id: \.self) { minutes in
                            Text(formatDuration(minutes: minutes))
                        }
                    }
                }
                
                Section(header: Text("Price")) {
                    Text("$\(calculatePrice(), specifier: "%.2f")")
                        .font(.headline)
                }
                
                Section {
                    Button(action: createBooking) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Confirm Booking")
                        }
                    }
                    .disabled(selectedHour == nil || isLoading)
                }
            }
            .navigationTitle("Book Court")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
            .alert("Error", isPresented: $showError) {
                Button("OK") { errorMessage = "" }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func createBooking() {
        guard let userId = Auth.auth().currentUser?.uid,
              let startTime = selectedHour else { return }
        
        isLoading = true
        
        let booking = Booking(
            id: UUID().uuidString,
            facilityId: facility.id,
            courtId: court.id,
            userId: userId,
            date: date,
            startTime: startTime,
            duration: duration,
            status: .confirmed,
            totalPrice: calculatePrice()
        )
        
        let db = Firestore.firestore()
        do {
            try db.collection("bookings").document(booking.id).setData(from: booking)
            isPresented = false
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
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
    
    private func calculatePrice() -> Double {
        let hourlyRate = court.pricePerHour
        return (Double(duration) / 60.0) * hourlyRate
    }
}

struct TimeSlotButton: View {
    let hour: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(String(format: "%02d:00", hour))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.blue : Color.secondary.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}
