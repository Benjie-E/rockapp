//
//  SessionManager.swift
//  rockapp
//
//  Created by Benjie on 2/16/25.
//

import Foundation
import SwiftUI
import Auth0

class SessionManager: ObservableObject {
    @Published var user: User?
    @Published var isLoggedIn: Bool = true

    private let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

    init() {
        checkForExistingCredentials()
    }

    func checkForExistingCredentials() {
        guard credentialsManager.canRenew() else {
            DispatchQueue.main.async {
                self.isLoggedIn = false
            }
            return
        }

        credentialsManager.credentials { [weak self] result in
            switch result {
            case .success(let credentials):
                DispatchQueue.main.async {
                    self?.user = User(from: credentials.idToken)
                    self?.isLoggedIn = true
                }
            case .failure(let error):
                print("Failed to retrieve credentials: \(error)")
                DispatchQueue.main.async {
                    self?.isLoggedIn = false
                }
            }
        }
    }


    func login() {
        Auth0
            .webAuth()
            .scope("openid profile offline_access")
            .start { [weak self] result in
                switch result {
                case .success(let credentials):
                    self?.credentialsManager.store(credentials: credentials)
                    self?.user = User(from: credentials.idToken)
                    self?.isLoggedIn = true
                case .failure(let error):
                    print("Login failed: \(error)")
                }
            }
    }

    func logout() {
        credentialsManager.clear()
        DispatchQueue.main.async {
            self.user = nil
            self.isLoggedIn = false
        }
    }


    func getAccessToken(completion: @escaping (String?) -> Void) {
        credentialsManager.credentials { result in
            switch result {
            case .success(let credentials):
                completion(credentials.accessToken)
            case .failure:
                completion(nil)
            }
        }
    }

}
