import SwiftUI
import AuthenticationServices
import Auth0

struct LoginView: View {
    @State private var isLoggedIn = false
    @State var user: User?

    var body: some View {
        NavigationStack {
            // Check if user data exists
            if let user = self.user {
                
                VStack {
                    MainTabView(user: user)
                }
            } else {
                VStack {
                    Text("Rock app thing")
                        .font(.largeTitle)
                        .padding()
                    
                    // Login Button
                    Button(action: handleLogin) {
                        Text("Login")
                            .font(.title)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()

                    // Apple SignIn Button
                    SignInWithAppleButton(.signIn, onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    }, onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            print("Authorization successful.")
                        case .failure(let error):
                            print("Authorization failed: " + error.localizedDescription)
                        }
                    }).frame(height: 44)
                    .padding()

                    Spacer()
                }
                .navigationTitle("Login")
            }
        }
        .onAppear {
            checkForExistingCredentials()
        }
    }

    private func checkForExistingCredentials() {
        // Here you check for saved credentials (for example, from UserDefaults or the Keychain)
        if let credentials = getSavedCredentials() {
            self.user = User(from: credentials.idToken)
            isLoggedIn = true
        }
    }
    
    

    private func handleLogin() {
        Auth0
            .webAuth()
            .start { result in
                switch result {
                case .success(let credentials):
                    print("Obtained credentials: \(credentials)")
                    self.user = User(from: credentials.idToken)
                    isLoggedIn = true
                    // Save credentials for future use
                    saveCredentials(credentials)
                case .failure(let error):
                    print("Failed with: \(error)")
                }
            }
    }
    
    private func saveCredentials(_ credentials: Credentials) {
        // Store credentials securely (e.g., in Keychain, UserDefaults, etc.)
        UserDefaults.standard.set(credentials.idToken, forKey: "idToken")
        UserDefaults.standard.set(credentials.accessToken, forKey: "accessToken")
    }
}
public func getSavedCredentials() -> Credentials? {
    // Retrieve saved credentials from UserDefaults or Keychain (this is an example; actual implementation will vary)
    // Example: Retrieve from UserDefaults
    if let savedIdToken = UserDefaults.standard.string(forKey: "idToken"),
       let savedAccessToken = UserDefaults.standard.string(forKey: "accessToken") {
        return Credentials(accessToken: savedAccessToken, idToken: savedIdToken)
    }
    return nil
}

#Preview {
    LoginView(user: nil)
}
