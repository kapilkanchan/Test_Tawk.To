import Foundation

public class ListUsersViewModel {

    var users: Box<[Users_DB]> = Box([Users_DB]())
    
    let persistanceService = PersistanceService.shared

    private var isFetchInProgress: Bool = false
    private var lastUID = 0
    
    let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
        
    //MARK:- calls the web service and fetch the list of users
    func fetchListOfUsers(incrementIndex: Bool, completionHandler: @escaping (Result<Users, CustomError>) -> Void) {
        guard isFetchInProgress == false else {
            return
        }
        isFetchInProgress = true
        
        let fetchIndex = incrementIndex || lastUID > 0 ? lastUID + 1 : lastUID
        
        apiService.fetchUsersListData(fetchIndex) { result in
            switch result {
            case .success(let users):
                completionHandler(.success(users))
                break
            case .failure(let error):
                completionHandler(.failure(error))
                return
            }
        }
    }

        
    func isDataForLocalUsersExist() -> Bool {
        if(persistanceService.isExist(Users_DB.self, id: lastUID, name: nil, for: false)) {
            return true
        } else {
            return false
        }
    }
    
    //MARK:-
    func fetchLocalUsers() {
        persistanceService.fetch(Users_DB.self, id: lastUID) { [weak self] (users) in
            self?.findLargestId(users: users)
            for index in 0..<users.count {
                self?.fetchUserProfile(with: users[index].name) { profile in
                    guard let profile = profile else {
                        return
                    }
                    users[index].user_profile = profile
                }
            }
            self?.users.value.append(contentsOf: users)
        }
    }
    
    func saveDataToPersistanceStore(usersData: Users) {
        usersData.forEach {
            let users_db = Users_DB(context: self.persistanceService.context)
            users_db.id = Int64(Int($0.id))
            users_db.name = $0.login ?? ""
            users_db.avatarUrl = $0.avatarURL
                            
            _ = self.persistanceService.save()
        }
    }
    
    func fetchUserProfile(with username: String, completion: @escaping ((Profile?) -> Void)) {
        if(persistanceService.isExist(Profile.self, id: nil, name: username, for: true)) {
            persistanceService.fetchProfile(Profile.self, name: username) { (profile) in
                if profile.count > 0 {
                    completion(profile.first)
                } else {
                    print("No profile data found")
                    completion(nil)
                }
            }
        }
    }
        
    // MARK: - Finds the last user id from the loaded data
    func findLargestId<T: CoreData_Network_Protocol>(users array: [T]) {
        for user in array {
            if(lastUID < user.getId()) {
                lastUID = user.getId()
            }
        }
    }
}
