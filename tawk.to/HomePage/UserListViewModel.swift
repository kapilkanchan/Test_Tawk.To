import Foundation

public class UsersViewModel {

    var users: Box<Users> = Box(Users())
        
    var isFetchInProgress: Bool = false
    
    var largestId = 0
    
    func fetchListOfUsers(incrementIndex: Bool) {
        guard isFetchInProgress == false else {
            return
        }
        
        isFetchInProgress = true
        
        var fetchIndex = 0
        if incrementIndex {
            fetchIndex = largestId + 1
        } else {
            fetchIndex = largestId
        }
        
        GithubUsersWebServices.fetchUsersListData(fetchIndex) { [weak self] usersData, error in
            self?.isFetchInProgress = false
            guard error == nil,
                  let usersData = usersData else {
                if error?.localizedDescription == "The Internet connection appears to be offline." {
                    
                } else {
                    print("Show Alert problems while fetching the data")
                }
                return
            }
            
            self?.findLargestId(users: usersData)
            self?.users.value.append(contentsOf: usersData) //Box(usersData ?? [])
        }
    }
    
    func findLargestId(users array: Users) {
        for user in array {
            if(largestId < user.id) {
                largestId = user.id
            }
        }
    }
}
