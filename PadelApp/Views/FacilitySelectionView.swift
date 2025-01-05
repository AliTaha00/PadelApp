import SwiftUI
import FirebaseFirestore


struct FacilitySelectionView: View {
    @Binding var selectedFacility: Facility?
    @Environment(\.presentationMode) var presentationMode
    @State private var facilities: [Facility] = []
    @State private var isLoading = false
    
    var body: some View {
        List {
            if isLoading {
                ProgressView()
            } else {
                ForEach(facilities) { facility in
                    Button(action: {
                        selectedFacility = facility
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        FacilityRowView(facility: facility)
                    }
                }
            }
        }
        .navigationTitle("Select Facility")
        .onAppear {
            loadFacilities()
        }
    }
    
    private func loadFacilities() {
        isLoading = true
        let db = Firestore.firestore()
        
        db.collection("facilities").getDocuments { snapshot, error in
            if let error = error {
                print("Error loading facilities: \(error)")
                isLoading = false
                return
            }
            
            facilities = snapshot?.documents.compactMap { document in
                try? document.data(as: Facility.self)
            } ?? []
            
            isLoading = false
        }
    }
} 