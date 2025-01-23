import SwiftUI
import Alamofire
struct NewClimbView: View {
    //let user: User
    @State private var name: String = ""
    @State private var location: String = ""
    @State private var difficulty: String = ""
    @State private var climbType: String = ""

    @State private var date: Date = Date()
    var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Climb Details")) {
                        TextField("Climb Name", text: $name)
                        TextField("Location", text: $location)
                        TextField("Difficulty", text: $difficulty)
                        TextField("Type", text: $climbType)
                        
                        DatePicker("Date", selection: $date)
                    }
                    
                    Button("Save Climb") {
                        saveClimb()
                    }
                    .disabled(name.isEmpty || location.isEmpty || difficulty.isEmpty) // Disable if fields are empty
                }
                .navigationTitle("Add New Climb")
            }
        
    }
}

import Alamofire

extension NewClimbView {
    private func saveClimb() {
        // Create a new climb object
        let newClimb = Climb(id: Date().hashValue, date: Date().ISO8601Format(), type: climbType, difficulty: difficulty)

        // Prepare the parameters for the API request
        let parameters: [String: Any] = [
            //"user_id": newClimb.user,
            "id": newClimb.id,
            "date": newClimb.date,
            "type": newClimb.type,
            "difficulty": newClimb.difficulty,
            //"name": newClimb.name
        ]

        // Replace with your API endpoint URL
        let apiUrl = "https://yourapi.com/saveClimb"
        
        // Send the request to save the climb data
        AF.request(apiUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                    .validate()
                    .response { response in
                        switch response.result {
                        case .success:
                            // Handle successful response (e.g., show success message, reset form fields)
                            print("Climb saved successfully: \(newClimb)")
                            resetFormFields()
                            fetchClimbs() // Optionally fetch updated list of climbs
                        case .failure(let error):
                            // Handle failure (e.g., show error message)
                            print("Error saving climb: \(error)")
                        }
                    }
    }

    private func resetFormFields() {
        // Reset the form fields after saving
        name = ""
        location = ""
        difficulty = ""
        climbType = ""
    }

    private func fetchClimbs() {
        // Example function to fetch updated list of climbs
        // Implement your logic to fetch and update the UI
        print("Fetching updated climbs...")
    }
}

    

#Preview {
    let view = NewClimbView()
    return view
}
