//
//  SettingsViewModel.swift
//  Message Now
//
//  Created by Hazem Tarek on 4/23/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import Foundation
import Firebase


class SettingsViewModel {
    
    let defaults = UserDefaults.standard
    var user = User() {
        didSet {
            loadInfoClosure?()
        }
    }
    
    var loadInfoClosure: (()->())?
    
    
    func loadInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if self.defaults.string(forKey: "id") == uid  {
            DefaultSettings.shared.initUserDefaults { (user) in
                self.user = user
            }
        } else {
        FBDatabase.shared.loadUserInfo(for: uid) { [weak self] (user, error) in
                guard let self = self else { return }
                if error != nil {
                    print(error!)
                } else {
                    guard let user = user else { return }
                    self.user = user
                    DefaultSettings.shared.setUserDefauls(first: user.first, last: user.last, id: user.id, email: user.email, username: user.username, imageURL: user.imageURL, country: user.country)
                }
            }
        }
    }
}
