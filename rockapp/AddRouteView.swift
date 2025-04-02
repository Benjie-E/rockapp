//
//  AddRouteView.swift
//  rockapp
//
//  Created by Benjie on 4/1/25.
//

import Foundation
import SwiftUI
import MapKit
import Alamofire

struct AddRouteView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var color: String = ""
    @State private var grade: String = ""

    @State private var selectedClimbingType = 0
    
    let climbingTypes = ["Auto", "Top Rope", "Lead", "Bouldering"]
    var onSave: (Route) -> Void
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                Picker("Climbing Type", selection: $selectedClimbingType) {
                    ForEach(climbingTypes.indices, id: \.self) { index in
                        Text(climbingTypes[index]).tag(index)
                    }
                }
                TextField("Description", text: $description)
                //                if #available(iOS 18.0, *) {
                //                    map.scaledToFit()
                //                    //                MKLocalSearch()
                //                        .mapFeatureSelectionAccessory()
                //                } else {
                //                    // Fallback on earlier versions
                //                }
                //ContentView()
            }
            .navigationTitle("Add Route")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        //                        let newLocation = Location(
                        //                            id: Int.random(in: 1000...9999), // Simulated ID
                        //                            name: name,
                        //                            address: address,
                        //                            description: description
                        //                        )
                        //                        //onSave(newLocation)
                        //                        dismiss()
                        //print(map)
                        saveRoute()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    private func saveRoute() {
        // Create a new location object
        
        let newRoute = Route(id: Date().hashValue, name: name, type: selectedClimbingType, color: color, grade: grade, description: description)
        
        // Prepare the parameters for the API request
        let parameters: [String: Any] = [
            "id": -1,
            "name": newRoute.name,
            "description": newRoute.description
        ]
        
        let apiUrl = AppEnvironment.baseURL + "route"
        
        AF.request(apiUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    print("Route saved successfully: \(newRoute)")
                    onSave(newRoute) // Pass the new location back
                    dismiss()
                case .failure(let error):
                    print("Error saving route: \(error)")
                }
            }
    }
}

#Preview {
    AddRouteView(onSave:{ newRoute in
        // Add the new location and select it
        
    })
}
