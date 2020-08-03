//
//  EditeProfileViewModel.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/23/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit


class EditeProfileViewModel {

    var userInfo: UserInfoViewModel? { didSet {loadUserInfoClosure?() }}
    var message : String? { didSet { showAlertClosure?() }}
    
    
    var loadUserInfoClosure: (()->())?
    var showAlertClosure   : (()->())?
    
    
    
    
    func initFetch() {
        DefaultSettings.shared.initUserDefaults { [unowned self] (user) in
            self.userInfo = self.proccessCreateUser(user: user)
        }
    }
    
    
    func UpdateProfile(photo: UIImage, country: String) {
        FBDatabase.shared.editeProfile(profileImage: photo, country: country) { [unowned self] (isSuccess, error) in
            self.message = isSuccess ?  "Profile Updated Successfully" : error
        }
    }
    
    
    private func proccessCreateUser(user: User) -> UserInfoViewModel{
        let country = user.country == "" ? "Egypt" : user.country
        return UserInfoViewModel(photo: user.image, country: country)
    }
    
}




struct UserInfoViewModel {
    var photo  : UIImage?
    var country: String?
}
