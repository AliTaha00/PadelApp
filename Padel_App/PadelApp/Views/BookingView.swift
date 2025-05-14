import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct BookingView: View {
    let facility: Facility
    let court: Court
    let date: Date
    @Binding var isPresented: Bool
    @Binding var selectedTab: Int
    
    @State private var navigateToBookings = false
    
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
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemBackground), Color.blue.opacity(0.1)]), 
                          startPoint: .top, 
                          endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    VStack(spacing: 16) {
                        BookingInfoCard(facility: facility, court: court, date: date)
                        
                        // Duration Selection
                        DurationSelectionView(duration: $duration)
                    }
                    .padding(.horizontal)
                    
                    // Available Time Slots
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Available Time Slots")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        } else if availableTimeSlots.isEmpty {
                            Text("No available time slots for selected duration")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
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
                    .padding(.top, 8)
                    
                    // Selected Time Summary
                    if let selectedHour = selectedHour {
                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Booking Summary")
                                    .font(.headline)
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Time")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("\(String(format: "%02d:00", selectedHour)) - \(String(format: "%02d:%02d", selectedHour + (duration / 60), (duration % 60)))")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Total")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("$\(calculatePrice(), specifier: "%.2f")")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Confirm Button
                    VStack {
                        Button(action: createBooking) {
                            HStack {
                                Spacer()
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Confirm Booking")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(selectedHour == nil ? Color.gray : Color.blue)
                            .cornerRadius(14)
                            .padding(.horizontal)
                        }
                        .disabled(selectedHour == nil || isLoading)
                        
                        Button(action: { isPresented = false }) {
                            Text("Cancel")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 12)
                        }
                    }
                    .padding(.vertical)
                }
                .padding(.vertical)
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
        db.collection("bookings").addDocument(data: bookingData) { error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                } else {
                    isPresented = false
                    selectedTab = 1
                }
            }
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

struct BookingInfoCard: View {
    let facility: Facility
    let court: Court
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(facility.name)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(facility.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "sportscourt.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.blue.opacity(0.8))
            }
            
            Divider()
            
            HStack(spacing: 20) {
                InfoCell(
                    title: "Court",
                    value: court.name,
                    icon: "sportscourt"
                )
                
                InfoCell(
                    title: "Date",
                    value: date.formatted(date: .abbreviated, time: .omitted),
                    icon: "calendar"
                )
                
                InfoCell(
                    title: "Type",
                    value: court.type.rawValue,
                    icon: "house"
                )
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct InfoCell: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DurationSelectionView: View {
    @Binding var duration: Int
    let durations = [30, 60, 90, 120, 150, 180]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Duration")
                .font(.headline)
            
            HStack(spacing: 8) {
                ForEach(durations, id: \.self) { minutes in
                    DurationButton(
                        duration: minutes,
                        isSelected: duration == minutes,
                        action: { duration = minutes }
                    )
                }
            }
        }
    }
}

struct DurationButton: View {
    let duration: Int
    let isSelected: Bool
    let action: () -> Void
    
    private func formatDuration() -> String {
        let hours = duration / 60
        let minutes = duration % 60
        
        if minutes == 0 {
            return "\(hours)h"
        } else {
            return "\(hours):\(String(format: "%02d", minutes))"
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(formatDuration())
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? Color.blue : Color(UIColor.tertiarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(10)
        }
    }
}

struct TimeSlotButton: View {
    let hour: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(String(format: "%02d:00", hour))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .primary)
                    
                Text(hour < 12 ? "AM" : "PM")
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .frame(width: 70, height: 70)
            .background(
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                    } else {
                        Circle()
                            .fill(Color(UIColor.tertiarySystemBackground))
                            .overlay(
                                Circle()
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            )
        }
    }
}
