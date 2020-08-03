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
        }}
    
    
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var photoStack: UIStackView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photo.layer.cornerRadius = 15
        contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        photo.isUserInteractionEnabled = true
    }


}
