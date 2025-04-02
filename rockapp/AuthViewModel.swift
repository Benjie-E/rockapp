import SwiftUI
import Auth0

class AuthViewModel: ObservableObject {
    private let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

    @Published var isAuthenticated = false
    @Published var user: User?

    init() {
        loadUser()  // Check authentication status when app launches
    }

    /// Loads user from stored credentials
    func loadUser() {
        credentialsManager.credentials { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let credentials):
                    self.user = User(from: credentials.idToken)
                    self.isAuthenticated = self.user != nil
                case .failure:
                    self.isAuthenticated = false
                    self.user = nil
                }
            }
        }
    }

    /// Handles login via Auth0
    func login() {
        Auth0
            .webAuth()
            .start { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let credentials):
                        print("Login successful: \(credentials)")
                        self.credentialsManager.store(credentials: credentials)  // Store credentials securely
                        self.user = User(from: credentials.idToken)
                        self.isAuthenticated = self.user != nil
                    case .failure(let error):
                        print("Login failed: \(error.localizedDescription)")
                    }
                }
            }
    }
    
    func signup() {
        Auth0
            .webAuth()
            .parameters(["screen_hint": "signup"])
            .start() { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let credentials):
                        print("Signup successful: \(credentials)")
                        self.credentialsManager.store(credentials: credentials)  // Store credentials securely
                        self.user = User(from: credentials.idToken)
                        self.isAuthenticated = self.user != nil
                    case .failure(let error):
                        print("Login failed: \(error.localizedDescription)")
                    }
                }
            }
    }
    /// Logs out the user
    func logout() {
        Auth0.webAuth().clearSession { result in
            DispatchQueue.main.async {
                self.credentialsManager.clear()  // Remove stored credentials
                self.isAuthenticated = false
                self.user = nil
                print("User logged out successfully")
            }
        }
    }
}
