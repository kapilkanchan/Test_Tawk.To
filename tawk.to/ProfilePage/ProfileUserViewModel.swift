import Foundation

public class ProfileUserViewModel {

    var profileUser: Box<Profile?> = Box(nil)
    let persistanceService = PersistanceService.shared

    func fetchLocalProfile(with name: String) {
        persistanceService.fetchProfile(Profile.self, name: name) { [weak self] (profile) in
            if profile.count > 0 {
                self?.profileUser.value = profile.first
            } else {
                print("No profile data found")
            }
        }
    }

    func fetchUser(for username: String) {
        if(persistanceService.isExist(Profile.self, id: nil, name: username, for: true)) {
            fetchLocalProfile(with: username)
            return
        }
        
        GithubUsersWebServices.fetchUserProfile(for: username) { [weak self] profileUser, error in
            guard let strongSelf = self,
                  error == nil,
                  let profileUser = profileUser else {
                print("Show Alert problems while fetching the data")
                return
            }
            
            let profile = Profile(context: strongSelf.persistanceService.context)
            profile.id = Int64(profileUser.id)
            profile.login = profileUser.login!
            profile.name = profileUser.name ?? ""
            profile.avatarUrl = profileUser.avatarURL
            profile.following = Int64(profileUser.following ?? 0)
            profile.followers = Int64(profileUser.followers ?? 0)
            profile.company = profileUser.company ?? ""
            profile.blog = profileUser.blog ?? ""
            profile.notes = nil
            strongSelf.persistanceService.save()
            
            strongSelf.fetchLocalProfile(with: profileUser.login!)
        }
    }
    
    func updateProfile(with note: String) {
        
        guard let login = profileUser.value?.login else {
            print("No User present")
            return
        }
        persistanceService.batchUpdateRequest(entityName: "Profile", updateAttribute: "notes", updateValue: note, name: login)
    }
}
