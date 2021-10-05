import Foundation

protocol  getDataDelegate  {
    func getDataFromAnotherVC(name: String)
}

public class UsersViewModel {

    var users: Box<[Users_DB]> = Box([Users_DB]())
        
    var isFetchInProgress: Bool = false
    
    var largestId = 0
    
    let persistanceService = PersistanceService.shared
    
    var delegateCustom : getDataDelegate?
    
    func fetchLocalUsers(from id: Int) {
        for description in persistanceService.persistentContainer.persistentStoreDescriptions {
            print("db location: \(description.url!)")
        }

        persistanceService.fetch(Users_DB.self, id: id) { [weak self] (users) in
            print(self?.findLargestId(users: users) ?? "Nothing in DB")
            for index in 0..<users.count {
                self?.checkForUserNote(with: users[index].name) { profile in
                    guard let profile = profile else {
                        return
                    }
                    self?.delegateCustom?.getDataFromAnotherVC(name: profile.login)

                    users[index].user_profile = profile
                    
                }
            }

            self?.users.value.append(contentsOf: users)
        }
    }
    
    func fetchListOfUsers(incrementIndex: Bool) {
        guard isFetchInProgress == false else {
            return
        }
        
        if(persistanceService.isExist(Users_DB.self, id: largestId, name: nil, for: false)) {
            fetchLocalUsers(from: largestId)
            return
        }
                
        isFetchInProgress = true
        
        let fetchIndex = incrementIndex || largestId > 0 ? largestId + 1 : largestId

        GithubUsersWebServices.fetchUsersListData(fetchIndex) { [weak self] usersData, error in
            self?.isFetchInProgress = false
            guard let strongSelf = self,
                  error == nil,
                  let usersData = usersData else {
                if error?.localizedDescription == "The Internet connection appears to be offline." {
                    
                } else {
                    print("Show Alert problems while fetching the data")
                }
                return
            }
            
            for element in usersData {
                let users_db = Users_DB(context: strongSelf.persistanceService.context)
                users_db.id = Int64(Int(element.id))
                users_db.name = element.login
                users_db.avatarUrl = element.avatarURL
                                
                strongSelf.persistanceService.save()
            }
            
            strongSelf.fetchLocalUsers(from: strongSelf.largestId)
        }
    }
    
    func findLargestId<T: CoreData_Network_Protocol>(users array: [T]) {
        for user in array {
            if(largestId < user.getId()) {
                largestId = user.getId()
            }
        }
    }
    
    func checkForUserNote(with username: String, completion: @escaping ((Profile?) -> Void)) {
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
}
