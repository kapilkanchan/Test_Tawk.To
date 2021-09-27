import UIKit
import Kingfisher

class HomePageViewController: UITableViewController, UISearchControllerDelegate {
    private let viewModel = UsersViewModel()
    var isLoading = false
    var largestUserId = 0
    let spinner = UIActivityIndicatorView(style: .large)
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search Users"
        sc.searchBar.autocapitalizationType = .allCharacters
        return sc
    }()
    
    var users: Users = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "HOME"
        navigationItem.searchController = searchController

        tableView.rowHeight = UITableView.automaticDimension
        tableView.prefetchDataSource = self
        
        viewModel.users.bind { [weak self] users in
            self?.users = users
            
            guard self?.users != nil,
                  (self?.users.count)! > 0 else {
                return
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.fetchListOfUsers(incrementIndex: false) /*{ [weak self] errorString in
            guard errorString != nil else {
                return
            }
            DispatchQueue.main.async {
                Utility.showAlert(viewController: self!)
            }
        }*/
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "userDetailSegue" {
            if let
                destination = segue.destination as? UserDetailViewController,
                let cell = sender as? UserTableViewCell,
                let user = cell.usernameLabel?.text
            {
                destination.username = user
            }
        }
    }
}

extension HomePageViewController: UITableViewDataSourcePrefetching {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseCell", for: indexPath) as! UserTableViewCell
        
        if (indexPath.row+1)%4==0 {
            cell.profilePic.kf.setImage(with: URL(string: (users[indexPath.row].avatarURL)), placeholder: nil, options: nil, completionHandler: { result in
                DispatchQueue.main.async {
                    cell.profilePic.invertImageColors()
                }
            })
        } else {
            cell.profilePic.kf.setImage(with: URL(string: (users[indexPath.row].avatarURL)))
        }
        
        cell.usernameLabel.text = users[indexPath.row].login
        cell.detailLabel.text = users[indexPath.row].nodeID
                    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       let lastSectionIndex = tableView.numberOfSections - 1
       let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
       if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
           spinner.startAnimating()
           spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))

           tableView.tableFooterView = spinner
           tableView.tableFooterView?.isHidden = false
       }
   }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            loadMoreData()
        }
    }

    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row == users.count-1
    }

    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }

    func loadMoreData() {
        viewModel.fetchListOfUsers(incrementIndex: true) /*{ errorString in
            guard errorString != nil else {
                return
            }
            DispatchQueue.main.async {
                Utility.showAlert(viewController: self)
            }
        }*/
    }
        
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
      // 1
      guard let newIndexPathsToReload = newIndexPathsToReload else {
        spinner.stopAnimating()
        tableView.isHidden = false
        tableView.reloadData()
        return
      }
      // 2
      let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
      tableView.reloadRows(at: indexPathsToReload, with: .automatic)
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

