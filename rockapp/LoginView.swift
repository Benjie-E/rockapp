import SwiftUI
import AuthenticationServices
import Auth0

struct LoginView: View {
    var body: some View {
        NavigationStack {
            if AuthViewModel.shared.isAuthenticated/*, let user = authViewModel.user */{
                MainTabView()
            } else {
                VStack {
                    Text("CLIMB")
                        .font(.largeTitle)
                        .padding()

                    Button(action: AuthViewModel.shared.login) {  // Call shared login function
                        Text("Login")
                            .font(.title)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                    Button(action: AuthViewModel.shared.signup) {  // Call shared login function
                        Text("Sign Up")
                            .font(.title)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding()
//                    SignInWithAppleButton(.signIn, onRequest: { request in
//                        request.requestedScopes = [.fullName, .email]
//                    }, onCompletion: { result in
//                        switch result {
//                        case .success(let authResults):
//                            print("Authorization successful.")
//                        case .failure(let error):
//                            print("Authorization failed: \(error.localizedDescription)")
//                        }
//                    })
//                    .frame(height: 44)
//                    .padding()
//
//                    Spacer()
                }
//                .navigationTitle("Login")
            }
        }
        .onAppear {
            AuthViewModel.shared.loadUser()  // Ensure credentials are checked on app launch
        }
    }
}

#Preview {
    LoginView()
}
