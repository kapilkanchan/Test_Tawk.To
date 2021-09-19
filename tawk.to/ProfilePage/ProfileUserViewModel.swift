import Foundation

public class ProfileUserViewModel {

    //Issue at this point
    var profileUser = Box(ProfileUser())
                
    func fetchUsers() {
        
        GithubUsersWebServices.fetchUserProfile { profileUser, error in
            guard error == nil,
                  let profileUser = profileUser else {
                print("Show Alert problems while fetching the data")
                return
            }
            
            self.profileUser?.value = profileUser
            print(self.profileUser ?? "failed")
        }
    }
}
