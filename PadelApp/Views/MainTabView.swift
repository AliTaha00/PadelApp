import SwiftUI

struct MainTabView: View {
    @Binding var userIsLoggedIn: Bool
    @Binding var selectedTab: Int
    @State private var showUserSetup = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                HomeView(userIsLoggedIn: $userIsLoggedIn, selectedTab: $selectedTab)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(0)
            
            NavigationView {
                MyBookingsView()
            }
            .tabItem {
                Label("Bookings", systemImage: "calendar")
            }
            .tag(1)
            
            NavigationView {
                UserProfileView(userIsLoggedIn: $userIsLoggedIn, showUserSetup: $showUserSetup)
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(2)
        }
    }
} 