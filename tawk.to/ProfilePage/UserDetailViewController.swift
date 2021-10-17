
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkCheck.addObserver(observer: self)

        if networkCheck.currentStatus == .satisfied{
//            Utility.showAlert(viewController: self, title: "Network Connection", message: "You're online now")
        }else{
            Utility.showAlert(viewController: self, title: "Network Connection", message: "You're offline now")
        }

        self.title = username
        
        borderView.layer.borderWidth = 1
        borderView.layer.borderColor = UIColor.black.cgColor
        noteTextView.layer.borderWidth = 1
        noteTextView.layer.borderColor = UIColor.black.cgColor

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
        
        viewModel.fetchUser(for: username)
        
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        viewModel.updateProfile(with: noteTextView.text)
        
        customDelegate?.refreshProfile(with: username,at: index)
        
        Utility.showAlert(viewController: self, title: "Note Saved", message: "Note successfully updated")
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
