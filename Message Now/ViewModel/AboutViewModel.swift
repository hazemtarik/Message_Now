//
//  AboutViewModel.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/25/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import Foundation

class AboutViewModel {
    
    
    public var userViewModel   = UserViewModel() { didSet { reloadTableViewClosure?() }}
    public var isBlocked       = false           { didSet { reloadTableViewClosure?() }}
    public var message         : String?         { didSet { showAlertClosure?() }}
    
    
    var reloadTableViewClosure: (()->())?
    var showAlertClosure      : (()->())?
    
    
    
    
    
    
    
    
    //MARK:- Fetch User Info
    
    func initFetch(uid: String) {
        FBDatabase.shared.loadUserInfo(for: uid) { [weak self] (user, error) in
            guard let self = self else { return }
            if error == nil {
                self.userViewModel = self.proccessFetchUser(user: user!)
            } else { self.message = error! }
        }
    }
    
    private func proccessFetchUser(user: User) -> UserViewModel {
        let name = user.first! + " " + user.last!
        let status = FBNetworkRequest.shared.blockedList.contains(user.id!) ? false : user.isOnline
        return UserViewModel(name: name, username: user.username, email: user.email, imageURL: user.imageURL, uid: user.id, isOnline: status, country: user.country)
    }
    
    
    
    
    
    
    
    
    // MARK:- Block Action
    
    func checkBlocking(uid: String) {
        if FBNetworkRequest.shared.blockedList.isEmpty {
            FBNetworkRequest.shared.fetchBlockedList { [weak self] (_) in
                guard let self = self else { return }
                self.isBlocked = FBNetworkRequest.shared.blockedList.contains(uid)
            }
        } else {
            self.isBlocked = FBNetworkRequest.shared.blockedList.contains(uid)
        }
    }
    
    func blockUser(uid: String) {
        FBNetworkRequest.shared.blockUser(uid: uid)
        self.isBlocked = true
    }
    
    func unblockUser(uid: String) {
        FBNetworkRequest.shared.unblockUser(uid: uid)
        self.isBlocked = false
    }
    
}
