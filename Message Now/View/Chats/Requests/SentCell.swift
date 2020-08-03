//
//  SentCell.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/8/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit

class SentCell: UITableViewCell {
    
    private let vm   = RequestsViewModel()
    
    public  var user = UserViewModel() { didSet {
        nameLabel.text      = user.name
        usernameLabel.text  = user.username
        userImage.load(url: user.imageURL!)
        }}
    
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    
    private func initView() {
        userImage.layer.cornerRadius     = 21
        cancelButton.layer.cornerRadius = 4
        cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
    }
    
    
    
    
    
    
    
    // MARK:- Actions
    
    @objc private func cancelPressed() {
        vm.removeRequest(uid: user.uid!)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.cancelButton.alpha = 0
            }
        }
    }
    
}
