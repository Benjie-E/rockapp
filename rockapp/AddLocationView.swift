//
//  AddLocationView.swift
//  rockapp
//
//  Created by Benjie on 2/28/25.
//

import Foundation
import SwiftUI
import MapKit
import Alamofire

struct AddLocationView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var address: String = ""
    @State private var description: String = ""
    let map = Map()
    var onSave: (Location) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                                TextField("Name", text: $name)
                                TextField("Address", text: $address)
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
            .navigationTitle("Add Location")
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
                        saveLocation()
                    }
                    .disabled(name.isEmpty || address.isEmpty)
                }
            }
        }
    }
    private func saveLocation() {
            // Create a new location object
            let newLocation = Location(id: Date().hashValue, name: name, address: address, description: description)

            // Prepare the parameters for the API request
            let parameters: [String: Any] = [
                "id": -1,
                "name": newLocation.name,
                "address": newLocation.address,
                "description": newLocation.description
            ]

            let apiUrl = AppEnvironment.baseURL + "locations"
            
            AF.request(apiUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .validate()
                .response { response in
                    switch response.result {
                    case .success:
                        print("Location saved successfully: \(newLocation)")
                        onSave(newLocation) // Pass the new location back
                        dismiss()
                    case .failure(let error):
                        print("Error saving location: \(error)")
                    }
                }
        }
    }



import Combine


import SwiftUI
import MapKit

struct ContentView: View {
    /// View properties
    let garage = CLLocationCoordinate2D(
        latitude: 40.83657722488077,
        longitude: 14.306896671048852
    )
    
    /// Search properties
    @State private var searchQuery: String = ""
    @State private var searchResults: [MKMapItem] = []
    
    /// Map properties
    @State private var position: MapCameraPosition = .automatic
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var selectedResult: MKMapItem?
    
    var body: some View {
        
        NavigationStack {

            Map(position: $position, selection: $selectedResult) {
                /// Reference point
                Marker("Garage", coordinate: garage)
                
                /// Search results on the map
//                ForEach(searchResults, id: \\.self) { result in
//                    Marker(item: result)
//                }
            }
            
            /// Map modifiers
            .mapStyle(.hybrid(elevation: .realistic))
            .onMapCameraChange { context in
                self.visibleRegion = context.region
            }
            
            /// Search modifiers
            .searchable(text: $searchQuery, prompt: "Locations")
            .onSubmit(of: .search) {
                self.search(for: searchQuery)
            }
            
            /// Navigation modifiers
            .navigationTitle("Search")
        }
        
    }
    
    /// Search method
    private func search(for query: String) {
        
        let defaultRegion = MKCoordinateRegion(
            center: garage,
            span: MKCoordinateSpan(
                latitudeDelta: 0.0125,
                longitudeDelta: 0.0125
            )
        )
        
        let request = MKLocalSearch.Request()
        
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = visibleRegion ?? defaultRegion
        
        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            searchResults = response?.mapItems ?? []
            position = .region(request.region)
        }
    }
}



#Preview {
    AddLocationView(onSave:{ newLocation in
        // Add the new location and select it
        
    })
}
