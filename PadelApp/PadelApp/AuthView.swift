import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLogin = true
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var isLoading = false
    @Binding var userIsLoggedIn: Bool
    @Binding var showUserSetup: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Padel App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                
                Text(isLogin ? "Login" : "Create Account")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 10)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding(.horizontal)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Button(action: handleAuth) {
                    Text(isLogin ? "Log In" : "Sign Up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button(action: { isLogin.toggle() }) {
                    Text(isLogin ? "Don't have an account? Sign Up" : "Already have an account? Log In")
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showUserSetup) {
            UserSetupView(userIsLoggedIn: $userIsLoggedIn, showUserSetup: $showUserSetup)
        }
    }
    
    private func handleAuth() {
        if isLogin {
            // Login
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                userIsLoggedIn = true
            }
        } else {
            // Sign up
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                // Instead of setting userIsLoggedIn to true, show the setup view
                showUserSetup = true
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(userIsLoggedIn: .constant(false), showUserSetup: .constant(false))
    }
} 