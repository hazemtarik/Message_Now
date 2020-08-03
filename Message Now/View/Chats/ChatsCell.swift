//
//  ChatsCell.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/7/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit

class ChatsCell: UITableViewCell {

    
    
    var cellVM = RecentsViewModel() { didSet {
        nameLabel.text = cellVM.name
        
        messageLabel.text = String(cellVM.message!.prefix(22))
        
        timeLabel.text = " . \(cellVM.timestamp!.getDays())"
        
        profileImage.KFloadImage(url: cellVM.imageURL!)
        
        let unreadCount = cellVM.unreadCount
        if unreadCount != nil {
            unreadCountButton.isHidden = false
            unreadCountButton.setTitle("\(unreadCount!)", for: .normal)
        } else {
            unreadCountButton.isHidden = true
        }
        
        checkAvailability()
        
        }
    }
    
    
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var unreadCountButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }

    
    
    
    
    private func initView() {
        profileImage.layer.cornerRadius = 21
        statusView.layer.cornerRadius = 6
        statusView.layer.borderColor    = #colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1411764706, alpha: 1)
        statusView.layer.borderWidth    = 1.5
        
        unreadCountButton.layer.cornerRadius = 12
    }

    
    
    
    private func checkAvailability() {
        let status = DefaultSettings.shared.availability()
        if status {
            guard let isOnline = cellVM.isOnline else { statusView.isHidden = true; return }
            if isOnline {
                statusView.isHidden = false
            } else {
                statusView.isHidden = true
            }
        } else {
            statusView.isHidden = true
        }
        
    }
    
}
