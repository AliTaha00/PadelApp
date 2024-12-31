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
    @State private var showUserSetup = false
    
    var body: some View {
        Group {
            if userIsLoggedIn {
                MainTabView(userIsLoggedIn: $userIsLoggedIn)
            } else {
                AuthView(userIsLoggedIn: $userIsLoggedIn)
            }
        }
        .onAppear {
            userIsLoggedIn = Auth.auth().currentUser != nil
            
            Auth.auth().addStateDidChangeListener { auth, user in
                DispatchQueue.main.async {
                    if let user = user {
                        let db = Firestore.firestore()
                        db.collection("users").document(user.uid).getDocument { document, error in
                            if let document = document, document.exists {
                                userIsLoggedIn = true
                            } else {
                                showUserSetup = true
                            }
                        }
                    } else {
                        userIsLoggedIn = false
                        showUserSetup = false
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showUserSetup) {
            UserSetupView(userIsLoggedIn: $userIsLoggedIn)
        }
    }
}

#Preview {
    ContentView()
}
