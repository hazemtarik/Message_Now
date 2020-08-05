//
//  PhotoTableViewCell.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/12/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {

    var msgVM = MessageViewModel() { didSet {
        photo.KFloadImage(url: msgVM.photoURL ?? "")
        timeLabel.text = msgVM.timestamp?.getMessageTime()
        seenImage.image   = msgVM.isSeen! ? UIImage(named: "Seen") : UIImage(named: "Unseen")
        }}
    
    
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var photoStack: UIStackView!
    @IBOutlet weak var seenImage: UIImageView!
    @IBOutlet weak var incomingProfile: UIImageView!
    @IBOutlet weak var outgoingProfile: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photo.layer.cornerRadius = 15
        outgoingProfile.layer.cornerRadius = 12.5
        incomingProfile.layer.cornerRadius = 10
        contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        photo.isUserInteractionEnabled = true
    }

    
    func checkMessageType(senderID: String, photo: UIImage) {
        if senderID != currentUser.id {
            outgoingProfile.isHidden = true
            timeLabel.textAlignment = .right
            incomingProfile.isHidden = false
            incomingProfile.image = currentUser.image
            seenImage.isHidden = false
        } else {
            outgoingProfile.isHidden = false
            timeLabel.textAlignment = .left
            seenImage.isHidden = true
            incomingProfile.isHidden = true
            outgoingProfile.isHidden = false
            outgoingProfile.image = photo
        }
    }
    

}
