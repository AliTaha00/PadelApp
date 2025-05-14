import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @Binding var userIsLoggedIn: Bool
    @Binding var selectedTab: Int
    @State private var userEmail: String = Auth.auth().currentUser?.email ?? "User"
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemBackground), Color.blue.opacity(0.1)]), 
                          startPoint: .top, 
                          endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome,")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text(userEmail.components(separatedBy: "@").first ?? "Player")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Card View Container
                    VStack(spacing: 16) {
                        // Reserve a Court Card
                        NavigationLink(destination: FacilitiesView(selectedTab: $selectedTab)) {
                            FeatureCard(
                                title: "Reserve a Court",
                                subtitle: "Browse available courts and book your slot",
                                icon: "sportscourt",
                                color: .blue
                            )
                        }
                        
                        // View Open Matches Card
                        NavigationLink(destination: OpenMatchesView()) {
                            FeatureCard(
                                title: "Open Matches",
                                subtitle: "Find matches to join nearby",
                                icon: "person.2",
                                color: .orange
                            )
                        }
                        
                        // Create Open Match Card
                        NavigationLink(destination: OpenMatchCreationView(selectedTab: $selectedTab)) {
                            FeatureCard(
                                title: "Create Match",
                                subtitle: "Set up a new match and invite players",
                                icon: "person.3.fill",
                                color: .green
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Quick Stats Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Your Activity")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            StatCard(title: "Upcoming", value: "2", icon: "calendar", color: .purple)
                            StatCard(title: "Played", value: "8", icon: "figure.handball", color: .indigo)
                        }
                    }
                    .padding(.top, 10)
                    
                    Spacer(minLength: 50)
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitle("Padel App", displayMode: .large)
    }
}

// Feature card for main options
struct FeatureCard: View {
    var title: String
    var subtitle: String
    var icon: String
    var color: Color
    
    var body: some View {
        HStack {
            // Icon container
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            .padding(.trailing, 8)
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// Stat card for quick stats
struct StatCard: View {
    var title: String
    var value: String
    var icon: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 1)
    }
}