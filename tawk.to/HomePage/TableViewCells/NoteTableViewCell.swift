//
//  NoteTableViewCell.swift
//  tawk.to
//
//  Created by Kapil Kanchan on 02/10/21.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var notes: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePic.roundImage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
