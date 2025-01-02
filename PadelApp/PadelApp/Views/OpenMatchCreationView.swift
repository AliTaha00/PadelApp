import SwiftUI
import FirebaseFirestore

struct OpenMatchCreationView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedTab: Int
    @State private var selectedFacility: Facility?
    @State private var selectedCourt: Court?
    @State private var selectedDate = Date()
    @State private var duration = 90 // Default 90 minutes
    @State private var selectedTimeSlot: Date?
    @State private var showMatchDetailsView = false
    
    var body: some View {
        NavigationView {
            Form {
                // Facility Selection
                Section(header: Text("Select Venue")) {
                    NavigationLink(destination: FacilitySelectionView(selectedFacility: $selectedFacility)) {
                        if let facility = selectedFacility {
                            FacilityRowView(facility: facility)
                        } else {
                            Text("Choose a facility")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Date Selection
                if selectedFacility != nil {
                    Section(header: Text("Select Date")) {
                        DatePicker(
                            "Date",
                            selection: $selectedDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                    }
                    
                    // Duration Selection
                    Section(header: Text("Duration")) {
                        Picker("Duration", selection: $duration) {
                            ForEach([60, 90, 120], id: \.self) { minutes in
                                Text("\(minutes) minutes").tag(minutes)
                            }
                        }
                    }
                    
                    // Time Slots
                    if let facility = selectedFacility {
                        TimeSlotSelectionSection(
                            facility: facility,
                            selectedDate: selectedDate,
                            duration: duration,
                            selectedTimeSlot: $selectedTimeSlot
                        )
                    }
                }
            }
            .navigationTitle("Create Open Match")
            .navigationBarItems(trailing: 
                Button("Next") {
                    showMatchDetailsView = true
                }
                .disabled(selectedFacility == nil || selectedTimeSlot == nil)
            )
        }
        .fullScreenCover(isPresented: $showMatchDetailsView) {
            MatchDetailsView(
                showMatchCreation: $showMatchDetailsView,
                selectedTab: $selectedTab,
                facility: selectedFacility!,
                date: selectedDate,
                timeSlot: selectedTimeSlot!,
                duration: duration
            )
        }
    }
} 