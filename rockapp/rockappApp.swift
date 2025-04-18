//
//  rockappApp.swift
//  rockapp
//
//  Created by Benjie on 11/11/24.
//
import SwiftUI
@main
struct rockappApp: App {
    @StateObject var authViewModel = AuthViewModel.shared

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}
