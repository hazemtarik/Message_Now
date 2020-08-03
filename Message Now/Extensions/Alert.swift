//
//  Alert.swift
//  Message Now
//
//  Created by Hazem Tarek on 4/21/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit

struct Alert {
    
    static func showAlert(at viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Ok", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
}
