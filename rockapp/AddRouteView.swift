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
    
    let location: Int
    var onSave: (Route) -> Void
    
    @State private var name: String = ""
    @State private var selectedClimbingType = -1
    @State private var grade: String = ""
    @State private var description: String = ""
    @State private var color: String = ""
    

    let boulderingGrades = ["VB","V0","V1","V2","V3","V4","V5","V6","V7","V8","V9","V10","V11","Other"]
    let topropeGrades = ["5.5","5.6","5.7","5.8","5.9","5.10","5.11","5.12","5.13","Other"]
    let climbingTypes = ["Select a Type", "Auto", "Top Rope","Bouldering", "Lead"]
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name).tag("Select a Type")
                Picker("Climbing Type", selection: $selectedClimbingType) {
                    ForEach(climbingTypes.indices, id: \.self) { index in
                        Text(climbingTypes[index]).tag(index - 1)
                    }
                }
                Picker("Grade", selection: $grade) {
                    Text("Select a Grade").tag("Select a Grade")
                    if selectedClimbingType == 2 {
                        ForEach(boulderingGrades, id: \.self) { gradeOption in
                            Text(gradeOption).tag(gradeOption)
                        }
                    } else {
                        ForEach(topropeGrades, id: \.self) { gradeOption in
                            Text(gradeOption).tag(gradeOption)
                        }
                    }
                }.onAppear{if selectedClimbingType == 2 {
                    grade = "Select a Grade"
                } else {
                    grade = "Select a Grade"
                }}
                TextField("Description", text: $description)
                TextField("Color", text: $color)

            }.toolbar {
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
                    .disabled(name.isEmpty || grade == "Select a Grade" || selectedClimbingType == 0)
                }
            }.navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Create New Route")
            
            
        }
    }
    private func saveRoute() {
        
       
        let parameters: [String: Any] = [
                "name": name,
                "type_id": selectedClimbingType,
                "color": color,
                "grade": grade,
                "description": description
            ]
        
        let apiUrl = AppEnvironment.baseURL + "locations/" + String(location) + "/routes"
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: AuthViewModel.shared.idToken)]
        
        AF.request(apiUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: RouteData.self) { response in
                switch response.result {
                case .success(let data):
                    print("Route saved successfully: \(data)")
                    let newRoute = Route(id: data.routes.first!.id, name: name, type: selectedClimbingType, color: color, grade: grade, description: description)
                    onSave(newRoute)
                    dismiss()
                case .failure(let error):
                    print("Error saving route: \(error)")
                }
            }
    }
}

#Preview {
    AddRouteView(location: 1, onSave:{ newRoute in
        // Add the new location and select it
        
    })
}
