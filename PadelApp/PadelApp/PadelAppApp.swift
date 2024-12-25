//
//  PadelAppApp.swift
//  PadelApp
//
//  Created by Ali Taha on 12/25/24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Attempting to configure Firebase...")
        do {
            FirebaseApp.configure()
            print("Firebase successfully configured")
        } catch {
            print("Error configuring Firebase: \(error)")
        }
        return true
    }
}

@main
struct PadelAppApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}
