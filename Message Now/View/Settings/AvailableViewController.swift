//
//  AvailableViewController.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/29/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit

class AvailableViewController: UIViewController {

    let defaults = DefaultSettings.shared.defaults
    
    @IBOutlet weak var statusSwitch: UISwitch!
    
    
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        let status = defaults.bool(forKey: "status")
        statusSwitch.isOn = status
    }
    
    
    @IBAction func switchPressed(_ sender: UISwitch) {
        let database = FBDatabase.shared
        let status = sender.isOn
        defaults.set(status, forKey: "status")
        status ? database.updateUserStatus(isOnline: status) : database.updateUserStatus(isOnline: status)
    }
    
    

}
