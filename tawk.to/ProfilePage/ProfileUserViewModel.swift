import Foundation

public class ProfileUserViewModel {

    var profileUser: Box<ProfileUser?> = Box(nil)
                    
    func fetchUser(for username: String) {
        
        GithubUsersWebServices.fetchUserProfile(for: username) { profileUser, error in
            guard error == nil,
                  let profileUser = profileUser else {
                print("Show Alert problems while fetching the data")
                return
            }
            
            self.profileUser.value = profileUser
        }
    }
}
