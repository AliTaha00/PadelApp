import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoginMode = true
    @State private var errorMessage = ""
    @State private var isAuthenticated = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Title
                Text(isLoginMode ? "Welcome Back" : "Create Account")
                    .font(.largeTitle)
                    .bold()
                
                // Email field
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                // Password field
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Error message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                // Login/Signup button
                Button(action: handleAuth) {
                    Text(isLoginMode ? "Log In" : "Sign Up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Toggle between login and signup
                Button(action: { isLoginMode.toggle() }) {
                    Text(isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Log In")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
    
    private func handleAuth() {
        errorMessage = ""
        
        if isLoginMode {
            // Login
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                isAuthenticated = true
            }
        } else {
            // Sign up
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    print("Firebase Auth Error: \(error)")
                    if let underlyingError = (error as NSError).userInfo["NSUnderlyingError"] as? NSError {
                        print("Underlying error: \(underlyingError)")
                    }
                    errorMessage = error.localizedDescription
                    return
                }
                isAuthenticated = true
            }
        }
    }
} 