import SwiftUI
import FirebaseFirestore


struct TimeSlotSelectionSection: View {
    let facility: Facility
    let selectedDate: Date
    let duration: Int
    @Binding var selectedTimeSlot: Date?
    
    @State private var availableTimeSlots: [Date] = []
    @State private var isLoading = false
    
    var body: some View {
        Section(header: Text("Available Time Slots")) {
            if isLoading {
                ProgressView()
            } else if availableTimeSlots.isEmpty {
                Text("No available time slots")
                    .foregroundColor(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(availableTimeSlots, id: \.self) { time in
                            Button(action: {
                                selectedTimeSlot = time
                            }) {
                                Text(time.formatted(date: .omitted, time: .shortened))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedTimeSlot == time ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedTimeSlot == time ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .onAppear {
            loadAvailableTimeSlots()
        }
        .onChange(of: selectedDate) { _ in
            loadAvailableTimeSlots()
        }
        .onChange(of: duration) { _ in
            loadAvailableTimeSlots()
        }
    }
    
    private func loadAvailableTimeSlots() {
        isLoading = true
        selectedTimeSlot = nil
        availableTimeSlots = []
        
        // Get the start of the selected date
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        
        // Generate time slots from opening hour to closing hour
        let openingHour = facility.openingHour
        let closingHour = facility.closingHour
        
        for hour in openingHour..<closingHour {
            if let timeSlot = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: startOfDay) {
                // Check if this time slot is available (you'll need to implement this check against your bookings)
                availableTimeSlots.append(timeSlot)
            }
        }
        
        isLoading = false
    }
} 