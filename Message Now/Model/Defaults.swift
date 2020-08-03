//
//  Defaults.swift
//  Message Now
//
//  Created by Hazem Tarek on 4/23/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit

struct DefaultSettings {
    
    static let shared   = DefaultSettings()
    public let defaults = UserDefaults.standard
    
    func initUserDefaults(completion: @escaping (User)->()) {
        var user = User()
        user.first = defaults.string(forKey: "first")
        user.last = defaults.string(forKey: "last")
        user.id = defaults.string(forKey: "id")
        user.email = defaults.string(forKey: "email")
        user.username = defaults.string(forKey: "username")
        user.imageURL = defaults.string(forKey: "imageURL")
        user.image = UIImage(data: defaults.data(forKey: "image")!)
        user.country = defaults.string(forKey: "country")
        completion(user)
    }
    
    func setUserDefauls(first: String?, last: String?, id: String?, email: String?, username: String?, imageURL: String?, country: String?) {
        
        self.defaults.set(first, forKey: "first")
        self.defaults.set(last, forKey: "last")
        self.defaults.set(id, forKey: "id")
        self.defaults.set(email, forKey: "email")
        self.defaults.set(username, forKey: "username")
        self.defaults.set(imageURL, forKey: "imageURL")
        self.defaults.set(country, forKey: "country")
        
        guard let imageURL = imageURL else { return }
        let Url = URL(string: imageURL)
        let data = try? Data(contentsOf: Url!)
        self.defaults.set(data, forKey: "image")
    }
    
    
    func availability() -> Bool {
        let availability = DefaultSettings.shared.defaults.bool(forKey: "status")
        return availability
    }
    
    func ChangeAvailability(status: Bool) {
        DefaultSettings.shared.defaults.set(status, forKey: "status")
    }
    
}
