//
//  ClimbListView.swift
//  rockapp
//
//  Created by Benjie on 11/20/24.
//


import SwiftUI
import Alamofire
import Auth0
// Climb model


struct Climb: Codable, Identifiable {
    let id: Int
    let date: String
    let type: String
    let difficulty: String
    //let name: String?
}

class ClimbViewModel: ObservableObject {
    @Published var climbs: [Climb] = []  // List of climbs
    @Published var isLoading: Bool = false
    @Published var error: String? = nil

    // Fetch climbs using Alamofire
    func fetchClimbs(user: User) {
        let userStuff = UserStuff(id: user.id)
        // Convert user data to JSON
        guard let jsonData = try? JSONEncoder().encode(userStuff) else {
            print("Failed to encode user data to JSON")
            return
        }
        let urlString = "https://0anvu7mfrf.execute-api.us-east-1.amazonaws.com/test/climbs/"+user.id
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
            .responseDecodable(of: ClimbData.self) { response in
                switch response.result {
                case .success(let data):
                    //self.climbs = data.climbs
                    self.isLoading = false
                case .failure(let error):
                    self.error = "Failed to fetch data: \(error.localizedDescription)"
                    print(self.error)
                    print(String(data: response.data!, encoding: .utf8) ?? "")
                    self.isLoading = false
                    self.climbs = []
                }
            }
    }
}

// ClimbData struct for decoding response
struct ClimbData: Codable {
    let climbs: [Climb]
}





// Step 3: ClimbListView that displays the list of climbs
struct ClimbListView: View {
    let user: User
    @StateObject private var viewModel = ClimbViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading Climbs...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if let error = viewModel.error {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(viewModel.climbs) { climb in
                        VStack(alignment: .leading) {
//                            Text(climb.name ?? "test")
//                                .font(.headline)
                            Text("Difficulty: \(climb.difficulty)")
                                .font(.subheadline)
                            Text("Date: \(climb.date)")
                                .font(.subheadline)
                        }
                        .padding()
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Climbs")
            .onAppear {
                viewModel.fetchClimbs(user:user)  // Fetch data when the view appears
            }
        }
    }
}

#Preview {
    ClimbListView(user: User(id: "String", name: "String", email: "String", emailVerified: "String", picture: "String", updatedAt: "String"))
}
