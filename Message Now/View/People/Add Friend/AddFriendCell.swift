//
//  AddFriendCell.swift
//  Message Now
//
//  Created by Hazem Tarek on 6/13/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit

class AddFriendCell: UITableViewCell {

    var user = User() {
        didSet {
            userImage.KFloadImage(url: user.imageURL!)
            nameLabel.text = user.first! + " " + user.last!
            usernameLabel.text = user.username!
            let status = FBNetworkRequest.shared.requestsSent.contains { (element) -> Bool in return user.id! == element }
            updateButtonUI(status: status)
        }
    }
    
    
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
        addButton.addTarget(self, action: #selector(addPressed), for: .touchUpInside)
    }

    func initView() {
        userImage.layer.cornerRadius = 21
        addButton.layer.cornerRadius = 4
    }
    
    
    @objc private func addPressed() {
        if addButton.titleLabel?.text == "Add Friend" {
            addButton.setTitle("Undo", for: .normal)
            addButton.backgroundColor = .darkGray
            FBNetworkRequest.shared.addFriend(uid: user.id!)
        } else {
            addButton.setTitle("Add Friend", for: .normal)
            addButton.backgroundColor = .systemBlue
            FBNetworkRequest.shared.cancelRequestFriend(uid: user.id!)
        }
    }

    
    private func updateButtonUI(status: Bool) {
        if !status {
            addButton.setTitle("Add Friend", for: .normal)
            addButton.backgroundColor = .systemBlue
        } else {
            addButton.setTitle("Undo", for: .normal)
            addButton.backgroundColor = .darkGray
        }
    }
    
    
}
