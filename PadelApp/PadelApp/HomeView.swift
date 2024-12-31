import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @Binding var userIsLoggedIn: Bool
    @State private var userEmail: String = Auth.auth().currentUser?.email ?? "User"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome, \(userEmail)!")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            NavigationLink(destination: FacilitiesView()) {
                HStack {
                    Image(systemName: "sportscourt")
                    Text("Reserve a Court")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: {
                // TODO: Implement open match creation
            }) {
                HStack {
                    Image(systemName: "person.3.fill")
                    Text("Create Open Match")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationBarTitle("Padel App", displayMode: .large)
    }
}

#Preview {
    HomeView(userIsLoggedIn: .constant(true))
} 