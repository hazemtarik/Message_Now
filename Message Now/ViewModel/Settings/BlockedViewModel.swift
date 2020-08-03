//
//  BlockedViewModel.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/25/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import Foundation

class BlockedViewModel {
    
    
    
    
    var userViewModel = [UserViewModel]() { didSet { reloadTableViewClouser?() }}
    var numberOfCells : Int? { return userViewModel.count}
    
    
    var reloadTableViewClouser: (()->())?
    
    
    
    
    
    
    
    // MARK:- Fetch Blocked Users
    
    func initFetch() {
        if FBNetworkRequest.shared.blockedList.isEmpty {
            FBNetworkRequest.shared.fetchBlockedList { (_) in
                FBNetworkRequest.shared.fetchBlockedUsers { [weak self] (users) in
                    guard let self = self else { return }
                    guard let users = users else { return }
                    self.createUserViewModel(users: users)
                }
            }
        } else {
            FBNetworkRequest.shared.fetchBlockedUsers { [weak self] (users) in
                guard let self = self else { return }
                self.createUserViewModel(users: users!)
            }
        }
    }
    
    private func createUserViewModel(users: [User]) {
        var vms = [UserViewModel]()
        for user in users {
            vms.append(proccessFetchUsers(user: user))
        }
        userViewModel.append(contentsOf: vms)
    }
    
    private func proccessFetchUsers(user: User) -> UserViewModel {
        let name = user.first! + " " + user.last!
        return UserViewModel(name: name, username: user.username!, imageURL: user.imageURL!, uid: user.id!)
    }
    
    
    
    
    
    
    
    
    // MARK:- Block Action
    
    func unblockUser(uid: String) {
        FBNetworkRequest.shared.unblockUser(uid: uid)
    }
    
}
