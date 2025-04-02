import SwiftUI
import AuthenticationServices
import Auth0

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel  // Global authentication state

    var body: some View {
        NavigationStack {
            if authViewModel.isAuthenticated, let user = authViewModel.user {
                MainTabView(user: user)
            } else {
                VStack {
                    Text("CLIMB")
                        .font(.largeTitle)
                        .padding()

                    Button(action: authViewModel.login) {  // Call shared login function
                        Text("Login")
                            .font(.title)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                    Button(action: authViewModel.signup) {  // Call shared login function
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
                .navigationTitle("Login")
            }
        }
        .onAppear {
            authViewModel.loadUser()  // Ensure credentials are checked on app launch
        }
    }
}

#Preview {
    LoginView().environmentObject(AuthViewModel())
}
