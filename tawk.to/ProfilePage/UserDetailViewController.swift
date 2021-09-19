//
//  UserDetailViewController.swift
//  tawk.to
//
//  Created by Kapil Kanchan on 19/09/21.
//

import UIKit

class UserDetailViewController: UIViewController {

    private let viewModel = ProfileUserViewModel()
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var blogLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.fetchUsers()
        viewModel.profileUser?.bind(listener: { [weak self] profileUser in
            print(profileUser)
            self?.nameLabel.text = profileUser.login
        })
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        
    }
}
