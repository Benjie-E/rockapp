    //
    //  NewClimbView 2.swift
    //  rockapp
    //
    //  Created by Benjie on 11/20/24.
    //


    import SwiftUI
    import Auth0
    import AuthenticationServices

    struct ProfileView: View {
        let user: User
        
        var body: some View {
            List {
                Section(header: ProfileHeader(picture: user.picture)) {
                    ProfileCell(key: "ID", value: user.id)
                    ProfileCell(key: "Name", value: user.name)
                    ProfileCell(key: "Email", value: user.email)
                    ProfileCell(key: "Email verified?", value: user.emailVerified)
                    ProfileCell(key: "Updated at", value: user.updatedAt)
                }
    //            Button(action: postStuff)
    //            {
    //                Text("get stuff")
    //                    .font(.title)
    //                    .padding()
    //                    .foregroundColor(.white)
    //                    .background(Color.blue)
    //                    .cornerRadius(10)
    //
    //            }
    //            .padding()
            }
            
        }
    }

    import JWTDecode

    struct User {
        let id: String
        let name: String
        let email: String
        let emailVerified: String
        let picture: String
        let updatedAt: String
    }

    extension User {
        init?(from idToken: String) {
            guard let jwt = try? decode(jwt: idToken),
                  let id = jwt.subject,
                  let name = jwt["name"].string,
                  let email = jwt["email"].string,
                  let emailVerified = jwt["email_verified"].boolean,
                  let picture = jwt["picture"].string,
                  let updatedAt = jwt["updated_at"].string else {
                return nil
            }
            self.id = id
            self.name = name
            self.email = email
            self.emailVerified = String(describing: emailVerified)
            self.picture = picture
            self.updatedAt = updatedAt
        }
    }

    struct ProfileHeader: View {
        @State var picture: String
        
        private let size: CGFloat = 100
        
        var body: some View {
            ZStack(alignment: .topLeading){
                
                
    #if os(iOS)
                AsyncImage(url: URL(string: picture), content: { image in
                    image.resizable()
                }, placeholder: {
                    Color.clear
                })
                .frame(width: self.size, height: self.size)
                .clipShape(Circle())
                .padding(.bottom, 24)
    #else
                Text("Profile")
    #endif
                HStack {
                    Spacer() // Pushes the button to the far right
                    Button(action: logout) {
                        Text("Logout")
                            .font(.title)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(10)
                        
                    }
                }
            }
        }
    }

    struct ProfileCell: View {
        @State var key: String
        @State var value: String
        
        private let size: CGFloat = 14
        
        var body: some View {
            HStack {
                Text(key)
                    .font(.system(size: self.size, weight: .semibold))
                Spacer()
                Text(value)
                    .font(.system(size: self.size, weight: .regular))
                
            }
            
        }
    }

    extension ProfileHeader {
        private func logout(){
            Auth0
                .webAuth()
                .clearSession{ result in
                    switch result {
                    case .success:
                        UserDefaults.standard.removeObject(forKey: "idToken")
                        UserDefaults.standard.removeObject(forKey: "accessToken")
                        print("Logged out successfully")
                        VStack {
                            LoginView()
                        }
                    case .failure(let error):
                        print("Error logging out: \(error)")
                    }
                }
        }
    //    private func postStuff() {
    //        // Print the user data (this will be logged in the console)
    //        print("Sending data for user ID: \(user.id)")
    //
    //        // Create the user stuff to send
    //        let userStuff = UserStuff(id: user.id)
    //
    //        // Convert to JSON data
    //        guard let jsonData = try? JSONEncoder().encode(userStuff) else {
    //            print("Failed to encode user data to JSON")
    //            return
    //        }
    //
    //        // Create the URL for your server endpoint (Replace with your actual server URL)
    //        guard let url = URL(string: "https://0anvu7mfrf.execute-api.us-east-1.amazonaws.com/test/getClimbs") else {
    //            print("Invalid URL")
    //            return
    //        }
    //
    //        // Create the request with the URL
    //        var request = URLRequest(url: url)
    //        request.httpMethod = "POST"  // Set HTTP method to POST
    //        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    //        request.httpBody = jsonData  // Attach the encoded data
    //
    //        // Send the POST request using URLSession
    //        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
    //            if let error = error {
    //                print("Request failed with error: \(error.localizedDescription)")
    //                return
    //            }
    //
    //            // Check the HTTP response status code
    //            if let httpResponse = response as? HTTPURLResponse {
    //                if httpResponse.statusCode == 200 {
    //                    print("Request succeeded: \(httpResponse)")
    //                } else {
    //                    print("Request failed with status code: \(httpResponse.statusCode)")
    //                }
    //            }
    //
    //            // Handle the data received (optional)
    //            if let data = data {
    //                // You could decode the response into a model if needed, e.g.
    //                 let responseData = try? JSONDecoder().decode(ClimbData.self, from: data)
    //                print(responseData)
    //                    //print("Received data: \(String(describing: String(data: data, encoding: .utf8)))")
    //            }
    //        }
    //
    //        // Start the request
    //        task.resume()
    //    }
    }

    struct UserStuff: Codable {
        var id: String
    }
