import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @Binding var userIsLoggedIn: Bool
    @State private var userEmail: String = Auth.auth().currentUser?.email ?? "User"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome, \(userEmail)!")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                NavigationLink(destination: FacilitiesView()) {
                    HStack {
                        Image(systemName: "sportscourt")
                        Text("Find Courts")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                NavigationLink(destination: UserProfileView()) {
                    HStack {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button(action: {
                    do {
                        try Auth.auth().signOut()
                        userIsLoggedIn = false
                    } catch {
                        print("Error signing out: \(error)")
                    }
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitle("Padel App", displayMode: .large)
        }
    }
}

#Preview {
    HomeView(userIsLoggedIn: .constant(true))
} 