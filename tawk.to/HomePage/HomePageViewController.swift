import UIKit
import Kingfisher

class HomePageViewController: UITableViewController, UISearchControllerDelegate {
    private let viewModel = UsersViewModel()
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search Users"
        sc.searchBar.autocapitalizationType = .allCharacters
        return sc
    }()
    
    var users: Users?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "HOME"
        navigationItem.searchController = searchController

        tableView.rowHeight = UITableView.automaticDimension
        
        viewModel.users.bind { [weak self] users in
            self?.users = users
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.fetchListOfUsers()
    }
}

extension HomePageViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseCell", for: indexPath) as! UserTableViewCell
                
        if (users?[indexPath.row].avatarURL) != nil {
            cell.profilePic.kf.setImage(with: URL(string: (users?[indexPath.row].avatarURL)!))
        }
        cell.usernameLabel.text = users?[indexPath.row].login
        cell.detailLabel.text = users?[indexPath.row].nodeID
        
        return cell
    }
}

extension HomePageViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

//extension UIImage {
//    func inverseImage(cgResult: Bool) -> UIImage? {
//        let coreImage = self.ciImage
//        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
//        filter.setValue(coreImage, forKey: kCIInputImageKey)
//        guard let result = filter.value(forKey: kCIOutputImageKey) as? UIKit.CIImage else { return nil }
//        if cgResult { // I've found that UIImage's that are based on CIImages don't work with a lot of calls properly
//            return UIImage(cgImage: CIContext(options: nil).createCGImage(result, from: result.extent)!)
//        }
//        return UIImage(ciImage: result)
//    }
//}

