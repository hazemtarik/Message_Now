//
//  BlockedUsersTableViewCell.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/25/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit

class BlockedUsersTableViewCell: UITableViewCell {

    let vm     = BlockedViewModel()
    var userVM = UserViewModel() { didSet {
        profileImage.KFloadImage(url: userVM.imageURL!)
        nameLabel.text = userVM.name!
        usernameLabel.text = userVM.username!
        }}
    
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var unblockButton: UIButton!
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = 21
    }

    @IBAction func unlockPressed(_ sender: UIButton) {
        vm.unblockUser(uid: userVM.uid!)
        sender.isHidden = true
    }
    

}
