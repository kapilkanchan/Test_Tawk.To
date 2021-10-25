import Foundation

public class ProfileUserViewModel {

    var profileUser: Box<Profile?> = Box(nil)
    let persistanceService = PersistanceService.shared

    let apiService: APIServiceProtocol
    
    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }
    
    //calls fetch profile api on Profile object from Persistance Service
    func fetchLocalProfile(with name: String) {
        persistanceService.fetchProfile(Profile.self, name: name) { [weak self] (profile) in
            if profile.count > 0 {
                self?.profileUser.value = profile.first
            } else {
                print("No profile data found")
            }
        }
    }
    
    //creates an instance of Profile object and calls save api from Persistance Service
    func saveDataToPersistanceStore(profileUser: ProfileUser) {
        let profile = Profile(context: self.persistanceService.context)
        profile.id = Int64(profileUser.id)
        profile.login = profileUser.login!
        profile.name = profileUser.name ?? ""
        profile.avatarUrl = profileUser.avatarURL
        profile.following = Int64(profileUser.following ?? 0)
        profile.followers = Int64(profileUser.followers ?? 0)
        profile.company = profileUser.company ?? ""
        profile.blog = profileUser.blog ?? ""
        profile.notes = nil
        _ = self.persistanceService.save()
    }
    
    //checks if the profile already exist in persistance container
    func isProfileExist(for username: String) -> Bool {
        if(persistanceService.isExist(Profile.self, id: nil, name: username, for: true)) {
            return true
        } else {
            return false
        }
    }
    
    //calls the web service api for fetching the profile
    func fetchProfile(for username: String, completionHandler: @escaping (Result<ProfileUser, CustomError>)->Void) {
        apiService.fetchUserProfile(for: username) { result in
            switch result {
            case .success(let profileUser):
                completionHandler(.success(profileUser))
                break
            case .failure(let error):
                print("Show Alert problems while fetching the data \(error.localizedDescription)")
                return
            }
        }
    }
    
    //updates the note in persistance container
    func updateProfile(with note: String) -> String {
        guard let login = profileUser.value?.login else {
            return "No User present"
        }
        
        if (note.elementsEqual("")) {
            return "No Text To Save"
        }
        let result = persistanceService.batchUpdateRequest(entityName: "Profile", updateAttribute: "notes", updateValue: note, name: login)
        
        return result ? "Note successfully updated" : "Error while updating"
    }
}
