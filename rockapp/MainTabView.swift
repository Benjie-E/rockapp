//
//  MainTabView.swift
//  rockapp
//
//  Created by Benjie on 11/19/24.
//


import SwiftUI

struct MainTabView: View {
    @StateObject var sessionToShow = ViewNewSession()
    @State private var selectedTab = "session"
    //let user: User
    var body: some View {
        TabView (selection: $selectedTab){
            // NewClimbView(user: user)
            
            
            SessionListView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Sessions", systemImage: "list.bullet.clipboard")
                }
                .tag("session")
                .environmentObject(sessionToShow)
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "paperplane.fill")
                }
                .tag("feed")
                .environmentObject(sessionToShow)
            NewSessionView(selectedTab: $selectedTab)
                .tabItem {
                    Label("New Session", systemImage: "plus")
                }
                .tag("new")
                .environmentObject(sessionToShow)

            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag("profile")
        }
    }
}
