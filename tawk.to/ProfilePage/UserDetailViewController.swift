//
//  UserDetailViewController.swift
//  tawk.to
//
//  Created by Kapil Kanchan on 19/09/21.
//

import UIKit

class UserDetailViewController: UIViewController {

    private let viewModel = ProfileUserViewModel()
    var username: String!
    
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
                if profileUser.avatarURL != nil {                    
                    self?.profilePic.kf.setImage(with: URL(string: profileUser.avatarURL!))
                }
                if profileUser.following != nil {
                self?.followingLabel.text = "following:\(String(profileUser.following!))"
                }
                if profileUser.followers != nil {
                self?.followersLabel.text = "followers:\(String(profileUser.followers!))"
                }
                
                self?.nameLabel.text = profileUser.login != nil ? "name: \(String(describing: profileUser.login!))" : "No name"
                self?.companyLabel.text = profileUser.company != nil ? "company: \(profileUser.company!)" : "company: unknown"
                self?.blogLabel.text = profileUser.blog != nil ? "blog: \(String(describing: profileUser.blog!))" : ""
            }
        })
        
        viewModel.fetchUser(for: username)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        profilePic.invertImageColors()
    }
}
