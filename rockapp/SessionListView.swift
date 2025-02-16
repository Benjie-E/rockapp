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
    var location: Int?
    var comment: String
    //var climbs: [Climb]
}
class SessionViewModel: ObservableObject {
    @Published var sessions: [ClimbingSession] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil

    func fetchSessions(user: User) {
        let userStuff = UserStuff(id: user.id)
        
        // Convert user data to JSON
        guard let jsonData = try? JSONEncoder().encode(userStuff) else {
            print("Failed to encode user data to JSON")
            return
        }
        
        let urlString = AppEnvironment.baseURL + "sessions/" + user.id
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        AF.request(url, method: .get)
            .validate()  // Automatically checks for 2xx status codes
            .responseDecodable(of: SessionData.self) { response in
                switch response.result {
                case .success(let data):
                    self.sessions = data.sessions
                    self.isLoading = false
                case .failure(let error):
                    self.error = "Failed to fetch data: \(error.localizedDescription)"
                    print(self.error ?? "")
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
                        NavigationLink(destination: ClimbListView(session: session)) {
                            VStack(alignment: .leading) {
                                Text("Date: \(session.date)")
                                    .font(.subheadline)
                                Text("Location: \(session.location ?? 0)") // Fallback for nil location
                                    .font(.subheadline)
                                Text("Comments: \(session.comment)")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Climbing Sessions")
            .onAppear {
                viewModel.fetchSessions(user: user)
            }
        }
    }
}

// Preview example
struct SessionListView_Previews: PreviewProvider {
    static var previews: some View {
        SessionListView(user: User(id: "1", name: "John Doe", email: "john@example.com", emailVerified: "true", picture: "", updatedAt: "2025-02-13"))
    }
}
