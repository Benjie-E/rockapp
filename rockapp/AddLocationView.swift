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
//                TextField("Name", text: $name)
//                TextField("Address", text: $address)
//                TextField("Description", text: $description)
                map.padding(0)
                //.mapFeatureSelectionAccessory()

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
//                        onSave(newLocation)
//                        dismiss()
                        print(map)
                    }
                    //.disabled(name.isEmpty || address.isEmpty)
                }
            }
        }
    }
}