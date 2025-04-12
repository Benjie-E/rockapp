import SwiftUI
import Auth0

final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var user: User?
    @Published var credentials: Credentials?
    @Published var idToken: String = ""
    
    static let shared = AuthViewModel()
    
    private let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
    
    
    private init() {
        loadUser()
        // Check authentication status when app launches
    }
    
    /// Loads user from stored credentials
    func loadUser() {
        credentialsManager.credentials { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let credentials):
                    self.credentials = credentials
                    self.idToken = credentials.idToken
                    self.user = User(from: credentials.idToken)
                    self.isAuthenticated = self.user != nil
                    
                case .failure:
                    self.isAuthenticated = false
                    self.user = nil
                }
            }
        }
    }
    
    func login() {
        Auth0
            .webAuth()
            .start { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let credentials):
                        print("Signup successful: \(credentials)")
                        self.credentialsManager.store(credentials: credentials)
                        self.credentials = credentials
                        self.idToken = credentials.idToken
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
                        self.credentialsManager.store(credentials: credentials)
                        self.credentials = credentials
                        self.idToken = credentials.idToken
                        self.user = User(from: credentials.idToken)
                        self.isAuthenticated = self.user != nil
                    case .failure(let error):
                        print("Login failed: \(error.localizedDescription)")
                    }
                }
            }
    }
    
    func logout() {
        Auth0.webAuth().clearSession { result in
            DispatchQueue.main.async {
                self.credentialsManager.clear()
                self.credentials = nil
                self.idToken = ""
                self.user = nil
                self.isAuthenticated = false
                print("User logged out successfully")
            }
        }
    }
}
