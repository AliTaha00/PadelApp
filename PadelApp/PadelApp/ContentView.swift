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
    @State private var userIsLoggedIn = Auth.auth().currentUser != nil
    @State private var showUserSetup = false
    
    var body: some View {
        Group {
            if userIsLoggedIn {
                MainTabView(userIsLoggedIn: $userIsLoggedIn)
            } else {
                AuthView(userIsLoggedIn: $userIsLoggedIn, showUserSetup: $showUserSetup)
            }
        }
        .onAppear {
            print("ContentView appeared, checking user status...")
            checkUserStatus()
        }
        .fullScreenCover(isPresented: $showUserSetup) {
            UserSetupView(userIsLoggedIn: $userIsLoggedIn, showUserSetup: $showUserSetup)
        }
    }
    
    private func checkUserStatus() {
        if let user = Auth.auth().currentUser {
            print("Found existing user session for: \(user.email ?? "unknown")")
            
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).getDocument { document, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error checking user profile: \(error)")
                        userIsLoggedIn = false
                        return
                    }
                    
                    if let document = document, document.exists {
                        print("User profile found, maintaining logged in state")
                        userIsLoggedIn = true
                        showUserSetup = false
                    } else {
                        print("No user profile found, showing setup")
                        showUserSetup = true
                        userIsLoggedIn = false
                    }
                }
            }
        } else {
            print("No existing user session found")
            userIsLoggedIn = false
            showUserSetup = false
        }
    }
}

#Preview {
    ContentView()
}
