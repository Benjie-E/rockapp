import SwiftUI
struct LoginView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        NavigationStack {
            if sessionManager.isLoggedIn, let user = sessionManager.user {
                MainTabView(user: user)
            } else {
                VStack {
                    Text(String("test"))
                        .font(.largeTitle)
                        .padding()

                    Button(action: sessionManager.login) {
                        Text("Login")
                            .font(.title)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()

                    Spacer()
                }
                .navigationTitle("Login")
            }
        }
    }
}
