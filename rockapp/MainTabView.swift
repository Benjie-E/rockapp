//
//  MainTabView.swift
//  rockapp
//
//  Created by Benjie on 11/19/24.
//


import SwiftUI

struct MainTabView: View {
    let user: User
    var body: some View {
        TabView {
            // NewClimbView(user: user)
            
            
            SessionListView(user: user)
                .tabItem {
                    Label("Sessions", systemImage: "2.circle")
                }
            
            NewSessionView(user: user)
                .tabItem {
                    Label("New Session", systemImage: "plus")
                }
            
            ProfileView(user: user)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}
