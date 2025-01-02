import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct FacilityDetailView: View {
    let facility: Facility
    @State private var courts: [Court] = []
    @State private var selectedDate = Date()
    @State private var selectedCourt: Court?
    @State private var showingBookingSheet = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @Binding var selectedTab: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                facilityInfoSection
                dateSelectionSection
                courtsSection
            }
            .padding()
        }
        .navigationTitle(facility.name)
        .sheet(isPresented: $showingBookingSheet) {
            if let court = selectedCourt {
                BookingView(
                    facility: facility,
                    court: court,
                    date: selectedDate,
                    isPresented: $showingBookingSheet,
                    selectedTab: $selectedTab
                )
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            loadCourts()
        }
    }
    
    private var facilityInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(facility.name)
                .font(.title)
            
            HStack {
                Image(systemName: "mappin")
                Text(facility.address)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "clock")
                Text("\(facility.openingHour):00 - \(facility.closingHour):00")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }
    
    private var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select Date")
                .font(.headline)
            
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
        }
    }
    
    private var courtsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Available Courts")
                .font(.headline)
            
            if courts.isEmpty {
                Text("No courts available")
                    .foregroundColor(.secondary)
            } else {
                ForEach(courts) { court in
                    CourtBookingRow(
                        court: court,
                        isSelected: selectedCourt?.id == court.id,
                        onSelect: {
                            selectedCourt = court
                            showingBookingSheet = true
                        }
                    )
                }
            }
        }
    }
    
    private func loadCourts() {
        isLoading = true
        let db = Firestore.firestore()
        
        db.collection("courts")
            .whereField("facilityId", isEqualTo: facility.id)
            .getDocuments { snapshot, error in
                isLoading = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                    return
                }
                
                courts = snapshot?.documents.compactMap { document in
                    try? document.data(as: Court.self)
                } ?? []
            }
    }
}

struct CourtBookingRow: View {
    let court: Court
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading) {
                    Text(court.name)
                        .font(.headline)
                    Text(court.type.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("$\(court.pricePerHour, specifier: "%.2f")/hr")
                    .fontWeight(.semibold)
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.secondary.opacity(0.1))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

