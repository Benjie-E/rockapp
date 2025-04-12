import Alamofire
import Auth0
import SwiftUI

struct Climb: Codable, Identifiable {
    let id: Int
    var attempts: Int
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
        let urlString = AppEnvironment.baseURL + "sessions/" + String(sessionId)+"/climbs"
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
        let headers: HTTPHeaders = [
            .authorization(bearerToken: AuthViewModel.shared.idToken)]
        AF.request(url, method: .get, headers: headers)
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
        let parameters: [String: Any] = [
            "session_id": sessionId,
            "route_id": routeId,
            "comment": comment,
        ]
        
        isCreating = true
        let headers: HTTPHeaders = [
            .authorization(bearerToken: AuthViewModel.shared.idToken)]
        AF.request(
            url,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
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
    func deleteClimb(climbId: Int, index: Int){
        let headers: HTTPHeaders = [
            .authorization(bearerToken: AuthViewModel.shared.idToken)]
        let apiUrl = AppEnvironment.baseURL+"climbs/"+String(climbId)
        AF.request(apiUrl, method: .delete, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    DispatchQueue.main.async {
                        self.climbs.remove(at: index)
                    }
                    print("deleted "+String(climbId))
                case .failure(let error):
                    print("Failed to delete session: \(error.localizedDescription)")
                }
            }
    }
    func addAttempt(climbId: Int){
        print(climbId)
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
    @State private var isAddingClimb: Bool = false
    //var routes: [Route]
    @StateObject private var climbViewModel = ClimbViewModel()
    @StateObject private var routeViewModel = RouteViewModel()
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
                        VStack(alignment: .leading) {
                            //Text("ID: \(climb.id)")
                            Text("Route: \(climb.name)")
                            Text("Comment: \(climb.comment)")
                            //Text("Color: \(climb.color)")
                            Text("Grade: \(climb.grade)")
                            Text("Description: \(climb.description)")
                            Text("Type: \(climb.type)")
                            Text("Type: \(climb.attempts)")
                        }
//                        .swipeActions(edge: .leading){Button("Add Attempt", systemImage: "plus"){addAttempt(at: <#T##IndexSet#>)}}.tint(.yellow)
                    }.onDelete(perform: deleteClimb)
                        

                }
            }
        }
        .sheet(isPresented: $isAddingClimb) {
            AddClimbView(
                session: session,
                climbViewModel: climbViewModel,
                routeViewModel: routeViewModel,
                isPresented: $isAddingClimb
            )
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
            climbViewModel.deleteClimb(climbId: climb.id, index: index)
        }
        
    }
    private func addAttempt(at offsets: IndexSet) {
        offsets.forEach { index in
            let climb = climbViewModel.climbs[index]
            climbViewModel.addAttempt(climbId: climb.id)
        }
        
    }
}

struct AddClimbView: View{
    let session: ClimbingSession
    @ObservedObject var climbViewModel: ClimbViewModel
    @ObservedObject var routeViewModel: RouteViewModel
    @Binding var isPresented: Bool
    
    @State private var selectedRouteId: Int? = nil
    
    @State private var comment: String = ""
    @State private var isShowingAddRoute = false
    var body: some View{
        NavigationView{
            Form {
                Section(header: Text("Route")) {
                    if routeViewModel.isLoading {
                        ProgressView("Loading Routes...")
                    } else if let error = routeViewModel.error {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                    } else {
                        Section {
                            if routeViewModel.isLoading {
                                ProgressView("Loading Routes...")
                            } else if let error = routeViewModel.error {
                                Text("Error: \(error)")
                                    .foregroundColor(.red)
                            } else {
                                Picker("Select a Route", selection: $selectedRouteId) {
                                    Text("Choose a route").tag(nil as Int?)
                                    ForEach(routeViewModel.routes) { route in
                                        Text("\(route.name) - \(route.grade)").tag(route.id as Int?)
                                    }
                                }
                                
                                Button(action: {
                                    isShowingAddRoute = true
                                }) {
                                    Label("Add a New Route", systemImage: "plus.circle")
                                        .font(.body)
                                }
                                .sheet(isPresented: $isShowingAddRoute) {
                                    AddRouteView(location:session.location!) { newRoute in
                                        routeViewModel.routes.append(newRoute)
                                        selectedRouteId = newRoute.id
                                    }
                                }.navigationTitle("Create new Climb")
                            }
                        }
                    }
                }
                
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
                
                TextField("Comment", text: $comment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    if let routeId = selectedRouteId,
                       let route = routeViewModel.routes.first(where: { $0.id == routeId }) {
                        climbViewModel.createClimb(
                            sessionId: session.id,
                            routeId: route.id,
                            comment: comment
                        )
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
                .disabled(climbViewModel.isCreating || selectedRouteId == nil)
                .buttonStyle(.bordered)
                .padding()
            }
            .padding()
            .onAppear {
                routeViewModel.fetchRoute(locationId: session.location ?? -1)
            }
        }
    }
}


//struct RoutePickerView: View {
//    @Binding var routes: [Route]
//    @Binding var selectedRoute: Route?
//    @State private var isShowingAddRouteView = false
//    @Environment(\.presentationMode) var presentationMode
//    var body: some View {
//        List(routes) { route in
//            HStack {
//                VStack(alignment: .leading) {
//                    Text(route.name).font(.headline)
//                    Text(route.description).font(.subheadline).foregroundColor(.gray)
//                }
//                Spacer()
//                if selectedRoute?.id == route.id {
//                    Image(systemName: "checkmark")
//                }
//            }
//            .contentShape(Rectangle())
//            .onTapGesture {
//                selectedRoute = route
//                presentationMode.wrappedValue.dismiss()
//            }
//        }
//        .navigationTitle("Select Route")
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: {
//                    isShowingAddRouteView = true
//                }) {
//                    Image(systemName: "plus")
//                }
//            }
//        }
//        .sheet(isPresented: $isShowingAddRouteView) {
//            AddRouteView { newRoute in
//                routes.append(newRoute)
//                selectedRoute = newRoute
//
//            }
//        }
//    }
//}

#Preview {
    let dummySession = ClimbingSession(id: 64, date: "2025-02-13", location: 5, comment: "Fun day!")
    let climbVM = ClimbViewModel()
    let routeVM = RouteViewModel()
    
    // Pre-populate routes for previewing
    
    return AddClimbView(
        session: dummySession,
        climbViewModel: climbVM,
        routeViewModel: routeVM,
        isPresented: .constant(true)
    )
}
