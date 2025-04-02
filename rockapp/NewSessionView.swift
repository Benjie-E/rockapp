import SwiftUI
import Alamofire
import MapKit

struct NewSessionView: View {
    let user: User
    @Binding var selectedTab: String
    @State private var name: String = ""
    @State private var locations: [Location] = []
    @State private var selectedLocation: Location? = nil
    @State private var difficulty: String = ""
    @State private var climbType: String = ""
    @State private var date: Date = Date()
    @State private var comments: String = ""
    //@State private var sessionToShow: ClimbingSession? = nil
    @EnvironmentObject var sessionToShow: ViewNewSession
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Climb Details")) {
                    TextField("Climb Name", text: $name)
                    
                    NavigationLink(
                        destination: LocationPickerView(
                            locations: $locations,
                            selectedLocation: $selectedLocation
                        )
                    ) {
                        HStack {
                            Text("Location")
                            Spacer()
                            if let selectedLocation = selectedLocation {
                                VStack(alignment: .trailing) {
                                    Text(selectedLocation.name)
                                    Text(selectedLocation.address)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            } else {
                                Text("Select Location")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                    }
                    TextField("Comments", text:$comments)

                }
                Button("Start Session") {
                    saveSession()
                }
                //if let session = sessionToShow {
//                    NavigationLink(destination: ClimbListView(session: session), isActive: .constant(true)) {
//                                        EmptyView()
//                    }.hidden()
//                        .disabled(true)
                //                }
            }
            .navigationTitle("Start New Session")
            .onAppear {
                fetchLocations()
            }
            
        }
    }
    
    private func fetchLocations() {
        let apiUrl = AppEnvironment.baseURL + "locations"
        
        AF.request(apiUrl)
            .validate()
            .responseDecodable(of: [Location].self) { response in
                switch response.result {
                case .success(let locations):
                    DispatchQueue.main.async {
                        self.locations = locations
                    }
                case .failure(let error):
                    print("Error fetching locations: \(error)")
                }
            }
    }
    
    private func saveSession() {
        
        let formattedDate = ISO8601DateFormatter().string(from: Date())
        
        // Safely unwrap location id (or provide a default value)
        let locationId = selectedLocation?.id ?? 0 // Default to 0 if nil
        
        // Ensure comments is not nil (or provide a default value)
        let commentText = comments
        
        let parameters: [String: Any] = [
            "user_id": user.id,
            "date": formattedDate,
            "location": locationId,
            "comment": commentText,
        ]
        
        print(parameters)
        let apiUrl = AppEnvironment.baseURL+"sessions"
        
        AF.request(apiUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(of: SessionResponse.self) { response in
                switch response.result {
                case .success(let data):
                    print("Session created successfully: \(String(describing: data.session))")
                    resetFormFields()
                    selectedTab = "session"
                    sessionToShow.session = data.session
                case .failure(let error):
                    print("Error saving session: \(error)")
                }
            }
    }
    
    private func resetFormFields() {
        name = ""
        selectedLocation = nil
        comments = ""
        climbType = ""
    }
    
    private func fetchClimbs() {
        print("Fetching updated climbs...")
    }
}

struct LocationPickerView: View {
    @Binding var locations: [Location]
    @Binding var selectedLocation: Location?
    @State private var isShowingAddLocationView = false
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        List(locations) { location in
            HStack {
                VStack(alignment: .leading) {
                    Text(location.name).font(.headline)
                    Text(location.address).font(.subheadline).foregroundColor(.gray)
                }
                Spacer()
                if selectedLocation?.id == location.id {
                    Image(systemName: "checkmark")
                }
            }
            .contentShape(Rectangle()) // Makes the whole row tappable
            .onTapGesture {
                selectedLocation = location
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationTitle("Select Location")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isShowingAddLocationView = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingAddLocationView) {
            AddLocationView { newLocation in
                // Add the new location and select it
                locations.append(newLocation)
                selectedLocation = newLocation
            }
        }
    }
}

struct SessionResponse: Decodable{
    let message: String
    let session: ClimbingSession
}

struct Location: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let address: String
    let description: String
}
