//
//  ContentView.swift
//  PadelApp
//
//  Created by Ali Taha on 12/25/24.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var userIsLoggedIn = false
    
    var body: some View {
        Group {
            if userIsLoggedIn {
                HomeView()
            } else {
                AuthView()
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
