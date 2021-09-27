import Foundation

enum NetworkServiceErrors: Error {
    case returnedError(Error)
    case noData
    case invalidResponse
    case failedRequest
    case invalidData
    case parsingFailure
}

class GithubUsersWebServices {
    typealias dataCompletion = (Data?, NetworkServiceErrors?) -> ()
    typealias githubUsersDataCompletion = (Users?, NetworkServiceErrors?) -> ()
    typealias profileUserDataCompletion = (ProfileUser?, NetworkServiceErrors?) -> ()

    private static func fetchData(from url: URL, completion: @escaping dataCompletion) {
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("Failed request from github users: \(error!.localizedDescription)")
                completion(nil, .returnedError(error!))
                return
            }
            
            guard let data = data else {
                print("No data returned from github users")
                completion(nil, .noData)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("Unable to process github users response")
                completion(nil, .invalidResponse)
                return
            }
            
            guard response.statusCode == 200 else {
                print("Failure response from github users: \(response.statusCode)")
                completion(nil, .failedRequest)
                return
            }
            
            completion(data, nil)
            
        }.resume()
        
        
    }
    
    static func fetchUsersListData(_ id: Int, completion: @escaping githubUsersDataCompletion) {
        let url = URL(string: "https://api.github.com/users?since=\(id)")!
        
        fetchData(from: url) { data, error in
            guard error == nil,
                  let data = data else {
                completion(nil, error!)
                return
            }
            do {
                let decoder = JSONDecoder()
                let usersData = try decoder.decode(Users.self, from: data)
                completion(usersData, nil)
            } catch {
                print("Unable to decode GithubUsersData response: \(error.localizedDescription)")
                completion(nil, .parsingFailure)
            }
        }
    }
    
    static func fetchUserProfile(for user: String, completion: @escaping profileUserDataCompletion) {
        let url = URL(string: "https://api.github.com/users/\(user)")!

        fetchData(from: url) { data, error in
            guard error == nil,
                  let data = data else {
                completion(nil, error!)
                return
            }
            do {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(dateFormatter)

                let profileUserData = try decoder.decode(ProfileUser.self, from: data)
                completion(profileUserData, nil)
            } catch {
                print("Unable to decode GithubUsersData response: \(error)")
                completion(nil, .parsingFailure)
            }
        }
    }

}
