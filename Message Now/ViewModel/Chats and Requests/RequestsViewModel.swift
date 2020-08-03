//
//  RequestsViewModel.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/9/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import Foundation

class RequestsViewModel {
    
    
    
    private var recivedViewModel = [UserViewModel]()
    private var sentViewModel    = [UserViewModel]()
    public  var userViewModel    = [UserViewModel]() { didSet { reloadTableView?() }}
    
    
    public  var numberOfCells: Int { return userViewModel.count }
    
    
    public  var reloadTableView: (()->())?
    
 
    
    
    
    
    
    
    
    
    // MARK:- Init Requests recvied and sent
    
    func initFetch() {
        // Validate if has requests recived and load it
        if FBNetworkRequest.shared.requestsRecived.isEmpty {
            FBNetworkRequest.shared.checkRequestsRecived { (_) in
                FBNetworkRequest.shared.loadUsersOfRequests(requestType: .recived) { [weak self] (requests) in
                    guard let self = self else { return }
                    guard let requests = requests else {
                        self.selectedSegmentIndex(SegmentIndex: 0)
                        return
                    }
                    self.createRecivedViewModel(users: requests)
                    self.selectedSegmentIndex(SegmentIndex: 0)
                }
            }
        } else {
            FBNetworkRequest.shared.loadUsersOfRequests(requestType: .recived) { [weak self] (requests) in
                guard let self = self else { return }
                self.createRecivedViewModel(users: requests!)
                self.selectedSegmentIndex(SegmentIndex: 0)
            }
        }
        
        // Validate if has requests recived and load it
        if FBNetworkRequest.shared.requestsSent.isEmpty {
            FBNetworkRequest.shared.checkRequestsSent { (_) in
                FBNetworkRequest.shared.loadUsersOfRequests(requestType: .sent) { [weak self] (requests) in
                    guard let self = self else { return }
                    guard let requests = requests else { return }
                    self.createSentViewModel(users: requests)
                }
            }
        } else {
            FBNetworkRequest.shared.loadUsersOfRequests(requestType: .sent) { [weak self] (requests) in
                guard let self = self else { return }
                self.createSentViewModel(users: requests!)
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK:- Refactor and Create a Cell View Model
    
    private func createRecivedViewModel(users: [User]) {
        var vms = [UserViewModel]()
        for user in users {
            vms.append(proccessFetchUsers(user: user))
        }
        recivedViewModel.append(contentsOf: vms)
    }
    
    
    private func createSentViewModel(users: [User]) {
        var vms = [UserViewModel]()
        for user in users {
            vms.append(proccessFetchUsers(user: user))
        }
        sentViewModel.append(contentsOf: vms)
    }
    
    
    private func proccessFetchUsers(user: User) -> UserViewModel {
        let name = user.first! + " " + user.last!
        return UserViewModel(name: name, username: user.username!, imageURL: user.imageURL!, uid: user.id!)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK:- Select which Requests will display
    func selectedSegmentIndex(SegmentIndex: Int) {
        switch SegmentIndex {
            case 1:
            userViewModel = sentViewModel
            default:
            userViewModel = recivedViewModel
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK:- Handle requests action
    func confirmRequest(uid: String) {
        FBNetworkRequest.shared.confirmRequestFriend(uid: uid)
    }
    
    func declineRequest(uid: String) {
        FBNetworkRequest.shared.declineRequestFriend(uid: uid)
    }
    
    func removeRequest(uid: String) {
        FBNetworkRequest.shared.cancelRequestFriend(uid: uid)
    }
    
}

