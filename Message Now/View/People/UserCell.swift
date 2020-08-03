//
//  UserCell.swift
//  Message Now
//
//  Created by Hazem Tarek on 4/24/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    
    var cellVM = UserViewModel() { didSet {
        userImage.KFloadImage(url: cellVM.imageURL!)
        nameLabel.text = cellVM.name
        messageLabel.text = cellVM.username
        }
    }
    
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    
    
    private func initView() {
        userImage.layer.cornerRadius = 21
    }
    
}
