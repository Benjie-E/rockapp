import SwiftUI
import Alamofire
import Auth0

struct Climb: Codable, Identifiable {
    let id: Int
    let date: String
    let type: String
    let difficulty: String
}

class ClimbViewModel: ObservableObject {
    @Published var climbs: [Climb] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var isCreating: Bool = false

    func fetchClimbs(sessionId: Int) {
        let urlString = AppEnvironment.baseURL+"climbs/"+String(sessionId)
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

//        guard let accessToken: String = getSavedCredentials()?.accessToken else {
//            error = "No access token"
//            return
//        }
//
//        let headers: HTTPHeaders = [.authorization(bearerToken: accessToken)]

        isLoading = true

        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: ClimbData.self) { response in
                self.isLoading = false
                switch response.result {
                case .success(let data):
                    self.climbs = data.climbs
                case .failure(let error):
                    self.error = "Failed to fetch climbs: \(error.localizedDescription)"
                    print(self.error ?? "")
                }
            }
    }

    func createClimb(sessionId: Int, routeId: Int, comment: String) {
        let urlString = AppEnvironment.baseURL + "climbs"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

//        guard let accessToken: String = getSavedCredentials()?.accessToken else {
//            error = "No access token"
//            return
//        }
//
//        let headers: HTTPHeaders = [
//            .authorization(bearerToken: accessToken),
//            .contentType("application/json")
//        ]

        let parameters: [String: Any] = [
            "session_id": sessionId,
            "route_id": routeId,
            "comment": comment
        ]

        isCreating = true

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .response { response in
                self.isCreating = false
                switch response.result {
                case .success:
                    self.fetchClimbs(sessionId: sessionId)
                case .failure(let error):
                    self.error = "Failed to create climb: \(error.localizedDescription)"
                    print(self.error ?? "")
                }
            }
    }
}

struct ClimbData: Codable {
    let climbs: [Climb]
}

struct ClimbListView: View {
    let session: ClimbingSession
    @StateObject private var viewModel = ClimbViewModel()

    @State private var routeId: String = ""
    @State private var comment: String = ""
    @State private var isAddingClimb = false

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading Climbs...")
            } else if let error = viewModel.error {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else {
                List(viewModel.climbs) { climb in
                    VStack(alignment: .leading) {
                        Text("Difficulty: \(climb.difficulty)")
                        Text("Date: \(climb.date)")
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingClimb) {
            VStack {
                Text("Add New Climb")
                    .font(.title2)
                    .padding()

                TextField("Route ID", text: $routeId)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Comment", text: $comment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    if let routeIdInt = Int(routeId) {
                        viewModel.createClimb(sessionId: session.id, routeId: routeIdInt, comment: comment)
                        isAddingClimb = false
                        routeId = ""
                        comment = ""
                    }
                }) {
                    if viewModel.isCreating {
                        ProgressView()
                    } else {
                        Text("Create Climb")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(viewModel.isCreating || routeId.isEmpty)
                .buttonStyle(.bordered)
                .padding()
            }
            .padding()
        }
        .navigationTitle("Climbs")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isAddingClimb.toggle()
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            viewModel.fetchClimbs(sessionId: session.id)
        }
    }
}

#Preview {
    NavigationView {
        ClimbListView(session: ClimbingSession(id: 1, date: "2025-02-13", location: 3, comment: "Fun day out!"))
    }
}
