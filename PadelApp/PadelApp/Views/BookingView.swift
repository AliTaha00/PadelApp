import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct BookingView: View {
    let facility: Facility
    let court: Court
    let date: Date
    @Binding var isPresented: Bool
    
    @State private var selectedHour: Int?
    @State private var duration = 60
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var bookedTimeSlots: [(start: Int, end: Int)] = []
    
    var availableTimeSlots: [Int] {
        let allTimeSlots = Array(facility.openingHour..<facility.closingHour)
        return allTimeSlots.filter { hour in
            let potentialEndTime = hour + (duration / 60)
            
            let hasConflict = bookedTimeSlots.contains { bookedSlot in
                (hour < bookedSlot.end && potentialEndTime > bookedSlot.start)
            }
            
            let fitsWithinHours = potentialEndTime <= facility.closingHour
            
            return !hasConflict && fitsWithinHours
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Booking Details")) {
                    Text("Court: \(court.name)")
                    Text("Date: \(date.formatted(date: .long, time: .omitted))")
                }
                
                Section(header: Text("Duration")) {
                    Picker("Duration", selection: $duration) {
                        ForEach([30, 60, 90, 120, 150, 180], id: \.self) { minutes in
                            Text(formatDuration(minutes: minutes))
                        }
                    }
                }
                
                Section(header: Text("Available Time Slots")) {
                    if isLoading {
                        ProgressView()
                    } else if availableTimeSlots.isEmpty {
                        Text("No available time slots for selected duration")
                            .foregroundColor(.secondary)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(availableTimeSlots, id: \.self) { hour in
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
                }
                
                if let selectedHour = selectedHour {
                    Section(header: Text("Selected Time")) {
                        HStack {
                            Text("\(String(format: "%02d:00", selectedHour)) - \(String(format: "%02d:%02d", selectedHour + (duration / 60), (duration % 60)))")
                            Spacer()
                            Text("$\(calculatePrice(), specifier: "%.2f")")
                                .fontWeight(.semibold)
                        }
                    }
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
            .onChange(of: duration) { _ in
                selectedHour = nil
            }
            .onAppear {
                loadExistingBookings()
            }
        }
    }
    
    private func loadExistingBookings() {
        isLoading = true
        let db = Firestore.firestore()
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        db.collection("bookings")
            .whereField("courtId", isEqualTo: court.id)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .whereField("status", isEqualTo: Booking.BookingStatus.confirmed.rawValue)
            .getDocuments { snapshot, error in
                isLoading = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                    return
                }
                
                bookedTimeSlots = snapshot?.documents.compactMap { document -> (start: Int, end: Int)? in
                    guard let startTime = document.data()["startTime"] as? Int,
                          let duration = document.data()["duration"] as? Int else {
                        return nil
                    }
                    let endTime = startTime + (duration / 60)
                    return (start: startTime, end: endTime)
                } ?? []
            }
    }
    
    private func createBooking() {
        guard let userId = Auth.auth().currentUser?.uid,
              let startTime = selectedHour else { return }
        
        isLoading = true
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        let bookingData: [String: Any] = [
            "id": UUID().uuidString,
            "facilityId": facility.id,
            "courtId": court.id,
            "userId": userId,
            "date": Timestamp(date: startOfDay),
            "startTime": startTime,
            "duration": duration,
            "status": Booking.BookingStatus.confirmed.rawValue,
            "totalPrice": calculatePrice()
        ]
        
        let db = Firestore.firestore()
        db.collection("bookings").document(bookingData["id"] as! String).setData(bookingData) { error in
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else {
                isPresented = false
            }
            isLoading = false
        }
    }
    
    private func calculatePrice() -> Double {
        let hourlyRate = court.pricePerHour
        return (Double(duration) / 60.0) * hourlyRate
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
