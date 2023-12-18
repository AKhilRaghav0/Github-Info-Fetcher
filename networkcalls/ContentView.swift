import SwiftUI

struct ContentView: View {
    @State private var user: GithubUser?
    @State private var username: String = ""
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color.gray.opacity(0.6)], startPoint: .bottomLeading, endPoint: .topTrailing)
                .blur(radius: 3.0)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                TextField("Enter username", text: $username)
                    .padding(20)
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white, lineWidth: 2)
                    )
                Button("Fetch User") {
                    fetchUser()
                }
                .buttonStyle(.borderedProminent)
                .font(.headline)
                .foregroundColor(.black)
                .accentColor(.white)
                .padding()
                
                if let user = user {
                    AsyncImage(url: URL(string: user.avatarUrl ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 150, height: 150, alignment: .center)
                    
                    Text(user.login ?? "Username Placeholder")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(user.bio ?? "This block is for BIO of Github, lets make it long, so it will spam 2 lines")
                        .foregroundColor(.white)
                    
                    // Display followers and following
                    HStack {
                        VStack {
                            Image(systemName: "shared.with.you")
                                .font(.system(size: 30))
                                .fontWeight(.semibold)
                            Text("Followers: \(user.followers)")
                                .font(.headline)
                                .fontWeight(.bold)
                            .padding()
                        }
//                        .frame(width: 100, height: 40)
                        
                        VStack {
                            Image(systemName: "shareplay")
                                .font(.system(size: 30))
                                .fontWeight(.semibold)
                            Text("Following: \(user.following)")
                                .font(.headline)
                                .fontWeight(.bold)
                            .padding()
                        }
//                        .frame(width: 100, height: 40)
                    }
                    .foregroundColor(.white)
//                    .accentColor(.white)
                } else {
                    ContentUnavailableView.search
//                        .font(.title)
                        .foregroundColor(.white)
                        
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    func fetchUser() {
        if !username.isEmpty {
            let endpoint = "https://api.github.com/users/" + username
            if let url = URL(string: endpoint) {
                Task {
                    do {
                        user = try await getUser(from: url)
                    } catch {
                        print(error)
                    }
                }
            }
        } else {
            user = nil
        }
    }
    
    func getUser(from url: URL) async throws -> GithubUser {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GithubUser.self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct GithubUser: Codable {
    let login: String
    let avatarUrl: String // Snake_Case to CamelCase then we use .ConvertFromSnakeCase
    let bio: String
    let followers: Int
    let following: Int
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
