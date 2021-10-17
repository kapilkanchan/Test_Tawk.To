import UIKit
import Network

class HomePageViewController: UITableViewController, UISearchControllerDelegate {
    
    @IBOutlet weak var offlineLabel: UILabel!
    private let viewModel = UsersViewModel()
    var isLoading = false
    var largestUserId = 0
    let spinner = UIActivityIndicatorView(style: .large)
    var networkCheck = NetworkCheck.sharedInstance()
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search Users"
        return sc
    }()
    
    var users: [Users_DB] = []
    var filteredData: [Users_DB]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkCheck.addObserver(observer: self)

        if networkCheck.currentStatus == .satisfied{
//            Utility.showAlert(viewController: self, title: "Network Connection", message: "You're online now")
        }else{
            Utility.showAlert(viewController: self, title: "Network Connection", message: "You're offline now")
        }

        navigationItem.title = "HOME"
        navigationItem.searchController = searchController
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.prefetchDataSource = self
        
        viewModel.users.bind { [weak self] users in
            self?.users = users
            self?.filteredData = users
            guard self?.users != nil,
                  (self?.users.count)! > 0 else {
                return
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.fetchListOfUsers(incrementIndex: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userDetailSegue" {
            if let destination = segue.destination as? UserDetailViewController,
               let indexPath = sender as? IndexPath {
                destination.customDelegate = self
                destination.username = filteredData[indexPath.row].name
                destination.index = indexPath.row
            }
        }
    }
}

extension HomePageViewController: UITableViewDataSourcePrefetching {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row+1)%4 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseCell1", for: indexPath) as! InvertedImageUserTableViewCell
            if let avatarUrl = filteredData[indexPath.row].avatarUrl {
//                cell.profilePic.loadImageUsingCache(withUrl: avatarUrl)
                cell.profilePic.loadImageUsingCache(withUrl: avatarUrl) {
                    cell.profilePic.invertImageColors()
                }
            }
            cell.usernameLabel.text = filteredData[indexPath.row].name
            cell.notes.isHidden = true
            cell.detailLabel.isHidden = true
            if filteredData[indexPath.row].user_profile?.notes != nil && filteredData[indexPath.row].user_profile?.notes != "" {
                cell.notes.isHidden = false
                cell.detailLabel.isHidden = false
                cell.detailLabel.text = filteredData[indexPath.row].user_profile?.notes!
            }
            
            return cell
        } else if filteredData[indexPath.row].user_profile?.notes == nil || filteredData[indexPath.row].user_profile?.notes == "" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseCell", for: indexPath) as! UserTableViewCell
            if let avatarUrl = filteredData[indexPath.row].avatarUrl {
                cell.profilePic.loadImageUsingCache(withUrl: avatarUrl, completionHandler: nil)
            }
            
            cell.usernameLabel.text = filteredData[indexPath.row].name
            
            return cell
        } else if filteredData[indexPath.row].user_profile?.notes != nil && filteredData[indexPath.row].user_profile?.notes != "" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseCell2", for: indexPath) as! NoteTableViewCell
            if let avatarUrl = filteredData[indexPath.row].avatarUrl {
                cell.profilePic.loadImageUsingCache(withUrl: avatarUrl, completionHandler: nil)
            }
            cell.usernameLabel.text = filteredData[indexPath.row].name
            cell.detailLabel.text = filteredData[indexPath.row].user_profile?.notes!
            
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "userDetailSegue", sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard searchController.searchBar.text == "" else {
            return
        }
        
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
        guard searchController.searchBar.text == "" else {
            return
        }
        
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
        DispatchQueue.main.asyncAfter(deadline: .now()+3) { [weak self] in
            self?.viewModel.fetchListOfUsers(incrementIndex: true)
        }
    }
    
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            spinner.stopAnimating()
            tableView.isHidden = false
            tableView.reloadData()
            return
        }
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }
}

extension HomePageViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            return
        }
        
        filteredData = searchText.isEmpty ? users : users.filter({(user: Users_DB) -> Bool in
            return (user.name.range(of: searchText, options: .caseInsensitive) != nil || user.user_profile?.notes?.range(of: searchText, options: .caseInsensitive) != nil)
        })

        tableView.reloadData()
    }
}

extension HomePageViewController: updateHomeFromUDVC {
    func refreshProfile(with username: String, at index: Int) {
        viewModel.checkForUserNote(with: username) { [unowned self] profile in
            guard let profile = profile else {
                return
            }
            self.viewModel.users.value[index].user_profile = profile
            
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }
}

extension HomePageViewController: NetworkCheckObserver {
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
