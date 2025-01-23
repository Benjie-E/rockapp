//
//  SessionListView.swift
//  rockapp
//
//  Created by Benjie on 1/21/25.
//

import SwiftUI
import Alamofire
import Auth0

struct ClimbingSession: Identifiable, Codable {
    var id: Int
    var date: String
    var location: String
    var comment: String
    var climbs: [Climb]
}
class SessionViewModel: ObservableObject {
    @Published var sessions: [ClimbingSession] = []  // List of climbs
    @Published var isLoading: Bool = false
    @Published var error: String? = nil

    // Fetch sessions using Alamofire
    func fetchSessions(user: User) {
        let userStuff = UserStuff(id: user.id)
        // Convert user data to JSON
        guard let jsonData = try? JSONEncoder().encode(userStuff) else {
            print("Failed to encode user data to JSON")
            return
        }
        let urlString = "https://0anvu7mfrf.execute-api.us-east-1.amazonaws.com/test/sessions/"+user.id
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        print(url)
        print(userStuff)
        print(user.id)
        guard let accessToken: String = getSavedCredentials()?.accessToken else {
            error = "No access token"
            return
        }
        
        let header: HTTPHeaders = [.authorization(bearerToken: accessToken)]
        //print(accessToken)
        AF.request(url, method: .get)
            .validate() // Automatically checks for 2xx status codes
            .responseDecodable(of: SessionData.self) { response in
                switch response.result {
                case .success(let data):
                    //self.climbs = data.climbs
                    self.isLoading = false
                case .failure(let error):
                    self.error = "Failed to fetch data: \(error.localizedDescription)"
                    print(self.error)
                    print(String(data: response.data!, encoding: .utf8) ?? "")
                    self.isLoading = false
                    self.sessions = []
                }
            }
    }
}

struct SessionData: Codable {
    let sessions: [ClimbingSession]
}

struct SessionListView: View {
    let user: User
    @StateObject private var viewModel = SessionViewModel()
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let error = viewModel.error {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                } else {
                    List(viewModel.sessions) { session in
                        VStack(alignment: .leading) {
                            Text("Date: \(session.date)")
                                .font(.subheadline)
                            Text("Location: \(session.location)")
                                .font(.subheadline)
                            Text("Comments: \(session.comment)")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Climbing Sessions")
            .onAppear {
                viewModel.fetchSessions(user:user)
            }
        }
    }
}

#Preview {
    SessionListView(user: User(id: "String", name: "String", email: "String", emailVerified: "String", picture: "String", updatedAt: "String"))
}
