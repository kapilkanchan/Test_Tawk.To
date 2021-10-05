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
        //        sc.searchBar.autocapitalizationType = .allCharacters
        return sc
    }()
    
    var users: [Users_DB] = []
    var filteredData: [Users_DB]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                destination.username = filteredData[indexPath.row].name
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
                cell.profilePic.kf.setImage(with: URL(string: avatarUrl), placeholder: nil, options: nil, completionHandler: { result in
                    DispatchQueue.main.async {
                        cell.profilePic.invertImageColors()
                    }
                })
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
                cell.profilePic.kf.setImage(with: URL(string: avatarUrl))
            }
            
            cell.usernameLabel.text = filteredData[indexPath.row].name
            
            return cell
        } else if filteredData[indexPath.row].user_profile?.notes != nil && filteredData[indexPath.row].user_profile?.notes != "" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseCell2", for: indexPath) as! NoteTableViewCell
            if let avatarUrl = filteredData[indexPath.row].avatarUrl {
                cell.profilePic.kf.setImage(with: URL(string: avatarUrl))
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
        guard searchController.searchBar.text != "" else {
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
        guard let searchText = searchController.searchBar.text else {
            return
        }
        
        filteredData = searchText.isEmpty ? users : users.filter({(user: Users_DB) -> Bool in
            return (user.name.range(of: searchText, options: .caseInsensitive) != nil || user.user_profile?.notes?.range(of: searchText, options: .caseInsensitive) != nil)
            
        })

        tableView.reloadData()
    }
}
