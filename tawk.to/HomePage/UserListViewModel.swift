import Foundation

public class UsersViewModel {

    var users: Box<Users> = Box(Users())
                
    func fetchListOfUsers() {
        GithubUsersWebServices.fetchUsersListData { usersData, error in
            guard error == nil,
                  let usersData = usersData else {
                print("Show Alert problems while fetching the data")
                return
            }
            
            self.users.value = usersData//Box(usersData ?? [])
        }
    }
}
