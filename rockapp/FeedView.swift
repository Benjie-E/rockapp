//
//  FeedView.swift
//  rockapp
//
//  Created by Benjie on 3/29/25.
//
import Alamofire
import Foundation
import SwiftUI
struct FeedView: View {
    
    @StateObject private var viewModel = SessionViewModel(sessionType: .feed)
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
                        .listRowSeparatorTint(.black)
                    }
                }

            }
            //.navigationTitle("Climbing Sessions")
            //.navigationTitle(sessionToLoad?.comment ?? "test")
            .onAppear {
                viewModel.fetchSessions()
                print(AuthViewModel.shared.idToken)
            }.navigationTitle("Feed")
        }
    }
    private func deleteSession(at offsets: IndexSet) {
            offsets.forEach { index in
                let session = viewModel.sessions[index]
                
                let parameters: [String: Any] = [
                    "session_id":session.id
                ]
                let apiUrl = AppEnvironment.baseURL+"sessions"
                
                AF.request(apiUrl, method: .delete, parameters: parameters, encoding: JSONEncoding.default)
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
