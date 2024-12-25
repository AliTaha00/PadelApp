import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @State private var userEmail: String = Auth.auth().currentUser?.email ?? "User"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome, \(userEmail)!")
                    .font(.title)
                    .padding()
                
                // Add your main navigation buttons here
                Button(action: {
                    // Action for finding games
                }) {
                    NavigationLink(destination: Text("Games View")) {
                        HStack {
                            Image(systemName: "sportscourt")
                            Text("Find Games")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Button(action: {
                    // Action for profile
                }) {
                    NavigationLink(destination: Text("Profile View")) {
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
                }
                .padding(.horizontal)
                
                Button(action: {
                    try? Auth.auth().signOut()
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
            .navigationBarTitle("PadelApp", displayMode: .large)
        }
    }
}

#Preview {
    HomeView()
} 