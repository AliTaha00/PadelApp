import SwiftUI
import FirebaseFirestore

struct OpenMatchesView: View {
    @State private var openMatches: [OpenMatch] = []
    @State private var isLoading = false
    
    var body: some View {
        List {
            if isLoading {
                ProgressView()
            } else if openMatches.isEmpty {
                Text("No open matches available")
                    .foregroundColor(.secondary)
            } else {
                ForEach(openMatches) { match in
                    OpenMatchRow(match: match)
                }
            }
        }
        .navigationTitle("Open Matches")
        .onAppear {
            loadOpenMatches()
        }
        .refreshable {
            loadOpenMatches()
        }
    }
    
    private func loadOpenMatches() {
        isLoading = true
        
        let db = Firestore.firestore()
        db.collection("openMatches")
            .whereField("status", isEqualTo: "open")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    isLoading = false
                    
                    if let error = error {
                        print("Error loading open matches: \(error)")
                        return
                    }
                    
                    openMatches = snapshot?.documents.compactMap { document in
                        var match = try? document.data(as: OpenMatch.self)
                        match?.id = document.documentID
                        return match
                    } ?? []
                    
                    print("Loaded \(openMatches.count) open matches")
                }
            }
    }
} 