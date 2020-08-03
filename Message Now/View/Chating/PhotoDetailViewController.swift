//
//  PhotoDetailViewController.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/12/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {

    var photoURL = String()
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet var swipeGesture: UISwipeGestureRecognizer!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.KFloadImage(url: photoURL)
        swipeGesture.direction = .down
        swipeGesture.addTarget(self, action: #selector(dismissVC))
    }

    @objc func dismissVC() {
        dismiss(animated: true)
    }
    
}
