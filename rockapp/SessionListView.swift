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
    var userId: String?
    var date: String
    var location: Int?
    var comment: String
    //var climbs: [Climb]
}
class ViewNewSession: ObservableObject{
    @Published var session: ClimbingSession?
    init(session: ClimbingSession? = nil) {
        self.session = session
    }
    func setSessionToLoad(session: ClimbingSession) -> Void{
        self.session = session
    }
}
class SessionViewModel: ObservableObject {
    let urlString: String
    @Published var sessions: [ClimbingSession] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    enum SessionTypes: Int{
        case individual, feed, specific
    }
    init(sessionType: SessionTypes){
        switch(sessionType){
        case .individual:
            self.urlString = AppEnvironment.baseURL + "me/sessions"
        case .feed:
            self.urlString = AppEnvironment.baseURL + "sessions"
        case .specific:
            self.urlString = AppEnvironment.baseURL + "sessions" //need to fix
        }
    }
    func fetchSessions() {
        //let userStuff = UserStuff(id: user.id)
        
        // Convert user data to JSON
        //        guard let jsonData = try? JSONEncoder().encode(userStuff) else {
        //            print("Failed to encode user data to JSON")
        //            return
        //        }
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        print(urlString)
        let headers: HTTPHeaders = [
            .authorization(bearerToken: AuthViewModel.shared.idToken)]
        AF.request(url, method: .get, headers: headers)
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
    //let user: User
    
    @EnvironmentObject var sessionToShow: ViewNewSession
    @Binding var selectedTab: String

    @StateObject private var viewModel = SessionViewModel(sessionType: .individual)
    //@State private var sessionToLoad: ClimbingSession? = nil
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
                    if viewModel.sessions.isEmpty{
                        VStack{
                            Text("No Sessions found")
                                .font(.headline)
                                .padding()
                            Button(action: {
                                selectedTab = "new"
                                    }) {
                                        Label("Create New Session", systemImage: "plus")
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                        }
                       
                    }else{
                        List{
                            ForEach(viewModel.sessions){ session in
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
                            .onDelete(perform: deleteSession)
                            //.swipeActions(edge: .leading){Button("Edit", systemImage: "square.and.pencil"){}}.tint(.blue)
                            .listRowSeparatorTint(.black)
                        }
                    }
                }
                if let session = sessionToShow.session {
                    NavigationLink(destination: ClimbListView(session: session), isActive: .constant(true)) {
                        EmptyView()
                    }.hidden()
                        .disabled(true)
                }
            }
            //.navigationTitle("Climbing Sessions")
            //.navigationTitle(sessionToLoad?.comment ?? "test")
            .onAppear {
                viewModel.fetchSessions()
            }.navigationTitle("Sessions")
        }
    }
    private func deleteSession(at offsets: IndexSet) {
        offsets.forEach { index in
            let session = viewModel.sessions[index]
            
            //                let parameters: [String: Any] = [
            //                    "session_id":session.id
            //                ]
            let apiUrl = AppEnvironment.baseURL+"sessions/"+String(session.id)
            
            AF.request(apiUrl, method: .delete)
                .validate()
                .response { response in
                    switch response.result {
                    case .success:
                        DispatchQueue.main.async {
                            viewModel.sessions.remove(at: index)
                        }
                        print("deleted "+String(session.id))
                    case .failure(let error):
                        print("Failed to delete session: \(error.localizedDescription)")
                    }
                }
        }
    }
}

// Preview example
//struct SessionListView_Previews: PreviewProvider {
//    static var previews: some View {
////        SessionListView(user: User(id: "auth0|67be1d83d7397dc4f217c8bf", name: "John Doe", username: "t",  email: "john@example.com", emailVerified: "true", picture: "", updatedAt: "2025-02-13")).environmentObject(ViewNewSession())
//        SessionListView()
//    }
//}
