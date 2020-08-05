//
//  FBNetworkRequest.swift
//  Message Now
//
//  Created by Hazem Tarek on 6/17/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import Foundation
import Firebase


class FBNetworkRequest {
    
    
    
    
    public static let shared       = FBNetworkRequest()
    
    private let REQ_REF            = FBAuthentication.shared.ref.child("request_friends")
    private let BLOCK_REF          = FBAuthentication.shared.ref.child("blocked_list")
    
    public var frinedsList         = [String]()
    public var requestsSent        = [String]()
    public var requestsRecived     = [String]()
    public var blockedList         = [String]()
    public var blockedByList       = [String]()
    
    
    
    
    
    
    // MARK:- Requests
    
    func addFriend(uid: String) {
        guard let id = currentUser.id else { return }
        REQ_REF.child("recived").child(uid).updateChildValues([id: "true"])
        REQ_REF.child("sent").child(id).updateChildValues([uid: "true"])
    }
    
    func cancelRequestFriend(uid: String) {
        guard let id = currentUser.id else { return }
        REQ_REF.child("recived").child(uid).child(id).removeValue()
        REQ_REF.child("sent").child(id).child(uid).removeValue()
    }
    
    func declineRequestFriend(uid: String) {
        guard let id = currentUser.id else { return }
        REQ_REF.child("recived").child(id).child(uid).removeValue()
        REQ_REF.child("sent").child(uid).child(id).removeValue()
    }
    
    func confirmRequestFriend(uid: String) {
        guard let id = currentUser.id else { return }
        declineRequestFriend(uid: uid)
        FBAuthentication.shared.ref.child("friends_list").child(id).updateChildValues([uid: "true"])
        FBAuthentication.shared.ref.child("friends_list").child(uid).updateChildValues([id: "true"])
    }
    
    
    
    
    
    
    
    
    // MARK:- Load Requests
    
    func checkRequestsSent(complation: @escaping([String])->()) {
        guard let id = currentUser.id else { return }
        REQ_REF.child("sent").child(id).observe(.value) { [unowned self] (snapshot) in
            if let data = snapshot.value as? [String: String] {
                self.requestsSent.removeAll()
                for user in data {
                    self.requestsSent.append(user.key)
                }
            } else {
                self.requestsSent = [String]()
            }
            complation(self.requestsSent)
        }
    }
    
    func checkRequestsRecived(complation: @escaping([String]?)->()) {
        guard let id = currentUser.id else { return }
        REQ_REF.child("recived").child(id).observe(.value) { [unowned self] (snapshot) in
            if snapshot.exists() {
                if let data = snapshot.value as? [String: String] {
                    self.requestsRecived.removeAll()
                    for user in data {
                        self.requestsRecived.append(user.key)
                    }
                } else {
                    self.requestsRecived = [String]()
                }
                complation(self.requestsRecived)
            } else {
                self.requestsRecived = [String]()
                complation(nil)
            }
        }
    }
    
    func loadUsersOfRequests(requestType: RequestType, complation: @escaping([User]?)->()) {
        let refrence = REQ_REF
        var keys = [String]()
        switch requestType {
            case .recived:
                refrence.child("recived")
                keys = requestsRecived
            case .sent:
                refrence.child("sent")
                keys = requestsSent
        }
        if keys.isEmpty {
            complation(nil)
        } else {
            var users = [User]()
            var index = 0
            for key in keys {
                FBDatabase.shared.loadUserInfo(for: key) { (user, error) in
                    index += 1
                    users.append(user!)
                    if index == keys.count {
                        complation(users)
                    }
                }
            }
        }
        
    }
    
    
    
    
    
    
    
    
    // MARK:- Load Friends
    
    func loadFriendsList(complation: @escaping([String])->()) {
        guard let id = currentUser.id else { return }
        FBAuthentication.shared.ref.child("friends_list").child(id).observe(.value) { [unowned self] (snapshot) in
            if snapshot.exists() {
                guard let data = snapshot.value as? [String: String] else { return }
                self.frinedsList.removeAll()
                for user in data {
                    self.frinedsList.append(user.key)
                }
                complation(self.frinedsList)
            } else {
                self.frinedsList = [String]()
                complation(self.frinedsList)
            }
        }
    }
    
    func loadFriends(complation: @escaping([User]?)->()) {
        var users = [User]()
        if frinedsList.isEmpty {
            complation(nil)
        } else {
            var index = 0
            for key in frinedsList {
                FBDatabase.shared.loadUserInfo(for: key) { [unowned self] (user, error) in
                    index += 1
                    users.append(user!)
                    if index == self.frinedsList.count {
                        complation(users)
                    }
                }
            }
        }
    }
    
    func removeFriend(uid: String) {
        guard let id = currentUser.id else { return }
        FBAuthentication.shared.ref.child("friends_list").child(id).child(uid).removeValue()
        FBAuthentication.shared.ref.child("friends_list").child(uid).child(id).removeValue()
    }
    
    
    
    
    
    
    
    // MARK:- Block User
    
    func blockUser(uid: String) {
        guard let id = currentUser.id else { return }
        BLOCK_REF.child("block").child(id).updateChildValues([uid: "true"])
        BLOCK_REF.child("blocked_by").child(uid).updateChildValues([id: "true"])
        removeFriend(uid: uid)
    }
    
    func unblockUser(uid: String) {
        guard let id = currentUser.id else { return }
        BLOCK_REF.child("block").child(id).child(uid).removeValue()
        BLOCK_REF.child("blocked_by").child(uid).child(id).removeValue()
    }
    
    func checkBlocking(uid: String, complation: @escaping(Bool) -> ()) {
        guard let id = currentUser.id else { return }
        Database.database().reference().child("blocked_list").child(uid).child(id).observe(.value) { (snapshot) in
            snapshot.exists() ? complation(true) : complation(false) }
    }
    
    func fetchBlockedList(complation: @escaping([String]?) -> ()) {
        guard let id = currentUser.id else { return }
        BLOCK_REF.child("block").child(id).observe(.value) { [weak self] (snapshot) in
            guard let self = self else { return }
            if snapshot.exists() {
                self.blockedList.removeAll()
                let keys = snapshot.value as! [String: String]
                for data in keys { self.blockedList.append(data.key)}
                complation(self.blockedList)
            } else {
                self.blockedList = [String]()
                complation(nil)
            }
        }
    }
    
    func fetchBlockedByList(complation: @escaping([String]?) -> ()) {
        guard let id = currentUser.id else { return }
        BLOCK_REF.child("blocked_by").child(id).observe(.value) { [weak self] (snapshot) in
            guard let self = self else { return }
            if snapshot.exists() {
                self.blockedByList.removeAll()
                let keys = snapshot.value as! [String: String]
                for data in keys { self.blockedByList.append(data.key)}
                complation(self.blockedByList)
            } else {
                self.blockedByList = [String]()
                complation(nil)
            }
        }
    }
    
    func fetchBlockedUsers(complation: @escaping([User]?)->()) {
        var users = [User]()
        if blockedList.isEmpty {
            complation(nil)
        } else {
            var index = 0
            for key in blockedList {
                FBDatabase.shared.loadUserInfo(for: key) { [weak self] (user, error) in
                    guard let self = self else { return }
                    users.append(user!)
                    index += 1
                    if index == self.blockedList.count {
                        complation(users)
                    }
                }
            }
        }
    }
    
}
