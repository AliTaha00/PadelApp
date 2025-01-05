//
//  ContentView.swift
//  PadelApp
//
//  Created by Ali Taha on 12/25/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @State private var userIsLoggedIn = false
    @State private var selectedTab = 0
    @State private var showUserSetup = false
    
    var body: some View {
        Group {
            if userIsLoggedIn {
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
                        UserProfileView(
                            userIsLoggedIn: $userIsLoggedIn,
                            showUserSetup: $showUserSetup
                        )
                    }
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                    .tag(2)
                }
            } else {
                AuthView(userIsLoggedIn: $userIsLoggedIn, showUserSetup: $showUserSetup)
            }
        }
        .onAppear {
            userIsLoggedIn = Auth.auth().currentUser != nil
        }
    }
}

#Preview {
    ContentView()
}
