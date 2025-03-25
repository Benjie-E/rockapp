import Auth0
import Foundation
struct UpdateToken {
    let credentialsManager: CredentialsManager
    
    init() {
        self.credentialsManager = CredentialsManager(authentication: Auth0.authentication())
    }
    
    
    func updateToken() {
        
        guard credentialsManager.canRenew() else {
            // Present login screen
            print("not renewing")
            return
        }
        Auth0
            .webAuth()
            .scope("openid profile offline_access")
        
        //.audience("\(audience)/userinfo")
            .start {
                switch $0 {
                case .failure(let error):
                    print("token update failed")
                    break
                    // Handle error
                case .success(let credentials):
                    // Pass the credentials over to the Credentials Manager
                    credentialsManager.store(credentials: credentials)
                    UserDefaults.standard.set(credentials.idToken, forKey: "id_token")
                    print("token updated")
                    
                }
            }
    }
}
