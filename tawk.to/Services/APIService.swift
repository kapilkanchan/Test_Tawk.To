import Foundation

//extension String: Error {} // Enables you to throw a string
//
//extension String: LocalizedError { // Adds error.localizedDescription to Error instances
//    public var errorDescription: String? { return self }
//}

enum CustomError: Error {
    case localizedDescription(String)
}

protocol APIServiceProtocol {
    func fetchData(from url: URL, completion: @escaping (Result<Data, CustomError>) -> Void)
    func fetchUsersListData(_ id: Int, completion: @escaping (Result<Users, CustomError>)->Void)
    func fetchUserProfile(for user: String, completion: @escaping (Result<ProfileUser, CustomError>)->Void)
}

class APIService: APIServiceProtocol {

    func fetchData(from url: URL, completion: @escaping (Result<Data, CustomError>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                completion(.failure(.localizedDescription(error!.localizedDescription)))
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                completion(.failure(.localizedDescription("Request Failed")))
                return
            }
            
            guard let data = data else {
                completion(.failure(.localizedDescription("No Data Found")))
                return
            }
            
            completion(.success(data))
            
        }.resume()
        
        
    }
    
    func fetchUsersListData(_ id: Int, completion: @escaping (Result<Users, CustomError>)->Void) {
        let url = URL(string: "https://api.github.com/users?since=\(id)")!
        
        fetchData(from: url) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let usersData = try decoder.decode(Users.self, from: data)
                    completion(.success(usersData))
                } catch {
                    completion(.failure(.localizedDescription("Parsing Failure")))
                }
                break
            case .failure(let error):
                completion(.failure(error))
                break
            }
        }
    }
    
    func fetchUserProfile(for user: String, completion: @escaping (Result<ProfileUser, CustomError>)->Void) {
        let url = URL(string: "https://api.github.com/users/\(user)")!

        fetchData(from: url) { result in
            switch result {
            case .success(let data):
                do {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)

                    let profileUserData = try decoder.decode(ProfileUser.self, from: data)
                    completion(.success(profileUserData))
                } catch {
                    completion(.failure(.localizedDescription("Parsing Failure")))

                }
            case .failure(let error):
                completion(.failure(error))
                break
            }
        }
    }
}
