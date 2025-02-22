//
//  rockappApp.swift
//  rockapp
//
//  Created by Benjie on 11/11/24.
//

import SwiftUI

@main
struct rockappApp: App {
    @StateObject var sessionManager = SessionManager()
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(sessionManager)
        }
    }
}
