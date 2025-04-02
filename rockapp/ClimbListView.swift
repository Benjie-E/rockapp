import Alamofire
import Auth0
import SwiftUI

struct Climb: Codable, Identifiable {
    let id: Int
    let attempts: Int
    let sent: Bool
    let flashed: Bool
    let comment: String
    let name: String
    let color: String
    let grade: String
    let description: String
    let type: String
    

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case attempts = "attempts"
        case sent = "sent"
        case flashed = "flashed"
        case comment = "comment"
        case name = "name"
        case color = "color"
        case grade = "grade"
        case description = "description"
        case type = "type"
        
    }
}
class RouteViewModel: ObservableObject{
    @Published var routes: [Route] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var isCreating: Bool = false
    func fetchRoute(locationId: Int) {
        print("fetching routes")
        let urlString = AppEnvironment.baseURL + "locations/" + String(locationId) + "/routes"
        print(urlString)
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        //        guard let accessToken: String = getSavedCredentials()?.accessToken else {
        //            error = "No access token"
        //            return
        //        }

        //let headers: HTTPHeaders = [.authorization(bearerToken: accessToken)]

        isLoading = true

        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: RouteData.self) { response in
                self.isLoading = false
                switch response.result {
                case .success(let data):
                    self.routes = data.routes
                    print(data.routes)
                case .failure(let error):
                    self.error =
                        "Failed to fetch routes: \(error.localizedDescription)"
                    print(self.error ?? "")
                }
            }
    }
}
class ClimbViewModel: ObservableObject {
    @Published var climbs: [Climb] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var isCreating: Bool = false

    func fetchClimbs(sessionId: Int) {
        let urlString = AppEnvironment.baseURL + "climbs/" + String(sessionId)
        print(urlString)
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        //        guard let accessToken: String = getSavedCredentials()?.accessToken else {
        //            error = "No access token"
        //            return
        //        }

        //let headers: HTTPHeaders = [.authorization(bearerToken: accessToken)]

        isLoading = true

        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: ClimbData.self) { response in
                self.isLoading = false
                switch response.result {
                case .success(let data):
                    self.climbs = data.climbs
                case .failure(let error):
                    self.error =
                        "Failed to fetch climbs: \(error.localizedDescription)"
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

        //        let headers: HTTPHeaders = [
        //            .authorization(bearerToken: accessToken),
        //            .contentType("application/json")
        //        ]

        let parameters: [String: Any] = [
            "session_id": sessionId,
            "route_id": routeId,
            "comment": comment,
        ]

        isCreating = true

        AF.request(
            url, method: .post, parameters: parameters,
            encoding: JSONEncoding.default
        )
        .validate()
        .response { response in
            self.isCreating = false
            switch response.result {
            case .success:
                self.fetchClimbs(sessionId: sessionId)
            case .failure(let error):
                self.error =
                    "Failed to create climb: \(error.localizedDescription)"
                print(self.error ?? "")
            }
        }
    }
}

struct ClimbData: Codable {
    let climbs: [Climb]
}
struct RouteData: Codable {
    let routes: [Route]
}
struct Route: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let type: Int
    let color: String
    let grade: String
    let description: String
}
struct ClimbListView: View {
    let session: ClimbingSession
    //var routes: [Route]
    @StateObject private var climbViewModel = ClimbViewModel()
    @StateObject private var routeViewModel = RouteViewModel()

    @State private var routeId: String = ""
    @State private var selectedRoute: Route? = nil
    @State private var comment: String = ""
    @State private var isAddingClimb = false

    var body: some View {
        VStack {
            if climbViewModel.isLoading {
                ProgressView("Loading Climbs...")
            } else if let error = climbViewModel.error {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else {
                List{
                    ForEach(climbViewModel.climbs) { climb in
                        NavigationLink(destination:ClimbListView(session: session), isActive: .constant(false)){
                            VStack(alignment: .leading) {
                                //Text("ID: \(climb.id)")
                                Text("Comment: \(climb.comment)")
                                Text("Name: \(climb.name)")
                                //Text("Color: \(climb.color)")
                                Text("Grade: \(climb.grade)")
                                Text("Description: \(climb.description)")
                                Text("Type: \(climb.type)")
                            }
                        }
                    }.onDelete(perform: deleteClimb)
                }
            }
        }
        .sheet(isPresented: $isAddingClimb) {
            VStack {
                            Text("Add New Climb")
                                .font(.title2)
                                .padding()

                            if routeViewModel.isLoading {
                                ProgressView("Loading Routes...")
                            } else if let error = routeViewModel.error {
                                Text("Error: \(error)")
                                    .foregroundColor(.red)
                            } else {
                                                                Picker("Select a Route", selection: $selectedRoute) {
                                                                    Text("Select a Route").tag(nil as Route?)
                                                                    ForEach(routeViewModel.routes) { route in
                                                                        Text("\(route.name) - \(route.grade)")
                                                                            .tag(route as Route?)
                                                                    }
                                                                }
                                                                .pickerStyle(MenuPickerStyle())
                                                                .padding()
                                                            
//                                NavigationLink(
//                                    destination: RoutePickerView(
//                                        routes: $routeViewModel.routes,
//                                        selectedRoute: $selectedRoute
//                                    )
//                                ){
//                                    HStack {
//                                        Text("Route")
//                                        Spacer()
//                                        if let selectedRoute = selectedRoute {
//                                            VStack(alignment: .trailing) {
//                                                Text(selectedRoute.name)
//                                                Text(selectedRoute.description)
//                                                    .font(.caption)
//                                                    .foregroundColor(.gray)
//                                            }
//                                        } else {
//                                            Text("Select Route")
//                                                .foregroundColor(.gray)
//                                        }
//                                    }
//                                }
                            }
                            TextField("Comment", text: $comment)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()

                            Button(action: {
                                if let selectedRoute = selectedRoute {
                                    climbViewModel.createClimb(
                                        sessionId: session.id,
                                        routeId: selectedRoute.id,
                                        comment: comment
                                    )
                                    isAddingClimb = false
                                    routeId = ""
                                    comment = ""
                                }
                            }) {
                                if climbViewModel.isCreating {
                                    ProgressView()
                                } else {
                                    Text("Create Climb")
                                        .frame(maxWidth: .infinity)
                                }
                }
                            .disabled(climbViewModel.isCreating || selectedRoute == nil)
                .buttonStyle(.bordered)
                .padding()
            }
            .padding()
            .onAppear {
                routeViewModel.fetchRoute(locationId: session.location ?? -1)
            }
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
            climbViewModel.fetchClimbs(sessionId: session.id)
        }
    }
    private func deleteClimb(at offsets: IndexSet) {
            offsets.forEach { index in
                let climb = climbViewModel.climbs[index]
                
                let parameters: [String: Any] = [
                    "climb_id":climb.id
                ]
                let apiUrl = AppEnvironment.baseURL+"climbs"
                print("delete climb" + String(climb.id))
//                AF.request(apiUrl, method: .delete, parameters: parameters, encoding: JSONEncoding.default)
//                    .validate()
//                    .response { response in
//                        switch response.result {
//                        case .success:
//                            DispatchQueue.main.async {
//                                climbViewModel.climbs.remove(at: index)
//                            }
//                            print("deleted "+String(session.id))
//                        case .failure(let error):
//                            print("Failed to delete session: \(error.localizedDescription)")
//                        }
                    //}
            }
        }
}
struct RoutePickerView: View {
    @Binding var routes: [Route]
    @Binding var selectedRoute: Route?
    @State private var isShowingAddRouteView = false
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        List(routes) { route in
            HStack {
                VStack(alignment: .leading) {
                    Text(route.name).font(.headline)
                    Text(route.description).font(.subheadline).foregroundColor(.gray)
                }
                Spacer()
                if selectedRoute?.id == route.id {
                    Image(systemName: "checkmark")
                }
            }
            .contentShape(Rectangle()) // Makes the whole row tappable
            .onTapGesture {
                selectedRoute = route
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationTitle("Select Route")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isShowingAddRouteView = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingAddRouteView) {
            AddRouteView { newRoute in
                // Add the new location and select it
                routes.append(newRoute)
                selectedRoute = newRoute
            }
        }
    }
}

//#Preview {
//    NavigationView {
//        ClimbListView(
//            session: ClimbingSession(
//                id: 1, date: "2025-02-13", location: 3, comment: "Fun day out!")
//        )
//    }
//}
