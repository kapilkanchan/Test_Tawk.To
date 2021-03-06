
import UIKit
import Network

protocol updateHomeFromUDVC: AnyObject {
    func refreshProfile(with username: String, at index: Int)
}

class UserDetailViewController: UIViewController {

    weak var customDelegate: updateHomeFromUDVC?
    
    private let viewModel = ProfileUserViewModel()
    var username: String!
    var index: Int!
    
    var networkCheck = NetworkCheck.sharedInstance()

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var blogLabel: UILabel!
    
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkCheck.addObserver(observer: self)

        if networkCheck.currentStatus == .satisfied{
//            Utility.showAlert(viewController: self, title: "Network Connection", message: "You're online now")
        }else{
            Utility.showAlert(viewController: self, title: "Network Connection", message: "You're offline now")
        }

        self.title = username
        
        borderView.drawBorder()
        noteTextView.drawBorder()
        saveButton.drawBorder()

        viewModel.profileUser.bind(listener: { [weak self] profileUser in
            guard let profileUser = profileUser else {
                return
            }
            DispatchQueue.main.async {
                
                if profileUser.avatarUrl != nil {
                    self?.profilePic.loadImageUsingCache(withUrl: profileUser.avatarUrl!, completionHandler: nil)
                }
                self?.followingLabel.text = "following:\(String(profileUser.following))"
                self?.followersLabel.text = "followers:\(String(profileUser.followers))"
                
                self?.nameLabel.text = profileUser.name != nil ? "name: \(String(describing: profileUser.name!))" : "No name"
                self?.companyLabel.text = profileUser.company != nil ? "company: \(profileUser.company!)" : "company: unknown"
                self?.blogLabel.text = profileUser.blog != nil ? "blog: \(String(describing: profileUser.blog!))" : ""
                self?.noteTextView.text = profileUser.notes ?? ""
            }
        })
        
        fetchUserProfile(for: username)
    }
    
    func fetchUserProfile(for username: String) {
        
        if viewModel.isProfileExist(for: username) {
            viewModel.fetchLocalProfile(with: username)
        } else {
            viewModel.fetchProfile(for: username) { [unowned self] result in
                switch result {
                case .success(let profileUser):
                    viewModel.saveDataToPersistanceStore(profileUser: profileUser)
                    viewModel.fetchLocalProfile(with: profileUser.login!)
                    break
                case .failure(let error):
                    switch error {
                    case .localizedDescription(let desc):
                        DispatchQueue.main.async {
                            if desc.elementsEqual("The Internet connection appears to be offline.") {
                                Utility.showAlert(viewController: self, title: "Network Connection", message: "You're offline now")
                            } else {
                                Utility.showAlert(viewController: self, title: "Error", message: error.localizedDescription)
                            }
                        }
                        break
                    }
                    break
                }
            }
        }
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        let message = viewModel.updateProfile(with: noteTextView.text)
        if message.elementsEqual("No User Present") {
            Utility.showAlert(viewController: self, title: "Error", message: message)
        } else if message.elementsEqual("No Text To Save") {
            Utility.showAlert(viewController: self, title: "Empty Text", message: message)
        } else if message.elementsEqual("Note successfully updated") {
            Utility.showAlert(viewController: self, title: "Note Saved", message: message)
        } else if message.elementsEqual("Error while updating") {
            Utility.showAlert(viewController: self, title: "Error", message: message)
        }
        customDelegate?.refreshProfile(with: username,at: index)
    }
}

extension UserDetailViewController: NetworkCheckObserver {
    func statusDidChange(status: NWPath.Status) {
        print("status changed")
        if networkCheck.currentStatus == .satisfied{
            //changing from satisfied to unsatisfied
            Utility.showAlert(viewController: self, title: "Network Connection", message: "You're offline now")
        }else{
            //changing from unsatisfied to satisfied
            Utility.showAlert(viewController: self, title: "Network Connection", message: "You're online now")
        }
    }
}
