import SwiftUI

struct MainTabView: View {
    @Binding var userIsLoggedIn: Bool
    
    var body: some View {
        TabView {
            NavigationView {
                HomeView(userIsLoggedIn: $userIsLoggedIn)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            NavigationView {
                MyBookingsView()
            }
            .tabItem {
                Label("Bookings", systemImage: "calendar")
            }
            
            NavigationView {
                UserProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
        }
    }
} 