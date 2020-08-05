//
//  ChatsViewModel.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/7/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import Foundation


class ChatsViewModel {
    
    public  var isReachable             = true { didSet { updateTableViewClouser?() }}
    public  var isAnimating             = true { didSet { updateIndicatorClouser?() }}
    public  var messageViewModel        = [RecentsViewModel]() { didSet { updateTableViewClouser?() }}
    public  var countUnreadedMessages   = 0 { didSet{ updatebadgeClouser?() }}
    private var originalModel           = [RecentsViewModel]()
    
    
    public var numberOfMessages         : Int { return messageViewModel.count }
    public var numberOfSection          : Int { return 1 }
    public var prevIndex                : Int?
    public var selectedCell             : RecentsViewModel?
    
    
    var updateTableViewClouser: (()->())?
    var updateIndicatorClouser: (()->())?
    var updateRequestsClouser:  (()->())?
    var updatebadgeClouser:  (()->())?
    
    
    
    init() {
        checkConnection()
    }
    
    
    
    
    
    
    
    // MARK:- Check Connection
    private func checkConnection() {
        Network.shared.isReachable = isReachable
        Network.shared.updateConnectionStatus = { [weak self] isReachable in
            guard let self = self else { return }
            self.isReachable = isReachable
            if !isReachable && self.isAnimating {
                self.isAnimating = false
            } else if isReachable && self.messageViewModel.count == 0 {
                self.isAnimating = true
            }
        }
    }
    
    
    
    
    // MARK:- Fetch Requests, Recent Messages and Undread Messages
    
    func initFetchRequests() {
        FBNetworkRequest.shared.fetchBlockedList     { (_) in }
        FBNetworkRequest.shared.fetchBlockedByList   { (_) in }
        FBNetworkRequest.shared.checkRequestsSent    { (_) in }
        FBNetworkRequest.shared.checkRequestsRecived { [weak self] (requests) in
            guard let self = self else { return }
            self.updateRequestsClouser?()
            //self.initFetchMessages()
        }
    }
    
    func initFetchMessages() {
        FBDatabase.shared.loadRecentMessages  { [weak self] (messages) in
            guard let self = self else { return }
            self.isAnimating = false
            guard let messages = messages else { return }
            self.messageViewModel.removeAll()
            self.proccessFetchUbreadCount(messages: messages)
        }
    }
    
    
    func initFetchUnreadMessages() {
        FBDatabase.shared.loadCountAllUnread { [weak self] (count) in
            guard let self = self else { return }
            self.countUnreadedMessages = count ?? 0
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK:- Proccess to create  message view model
    
    private func proccessFetchUbreadCount(messages: [RecentMessage]) {
        var msgs = [RecentMessage]()
        var index = 0
        for var msg in messages {
            FBDatabase.shared.loadUnreadMessagesSingleEvent(id: msg.to!) { [weak self] (count) in
                guard let self = self else { return }
                msg.unreadCount = count
                msgs.append(msg)
                index += 1
                if index == messages.count {
                    self.proccessFetchUsers(messages: msgs)
                }
            }
            FBDatabase.shared.updateUnreadMessagesCount(id: msg.to!) { [weak self] (_)in
                guard let self = self else { return }
                self.updateUnreadCount(uid: msg.to!, count: nil)
            }
        }
    }
    
    
    private func updateUnreadCount(uid: String, count: Int?) {
        var index = 0
        for cell in messageViewModel {
            if cell.uid == uid {
                messageViewModel[index].unreadCount = count
            }
            index += 1
        }
    }
    
    private func proccessFetchUsers(messages: [RecentMessage]) {
        var msgs = [RecentMessage]()
        var index = 0
        for var msg in messages {
            FBDatabase.shared.loadUserInfo(for: msg.to!) { [weak self] (usr, _) in
                guard let self = self else { return }
                msg.user = usr
                msgs.append(msg)
                index += 1
                if index == messages.count {
                    self.createCellViewModel(messages: msgs)
                }
            }
            FBDatabase.shared.loadStatusOfUser(for: msg.to!) { [weak self] (status, uid) in
                guard let self = self else { return }
                guard let status = status else { return }
                self.updateUserStatus(uid: uid!, status: status)
            }
        }
    }
    
    
    private func updateUserStatus(uid: String, status: Bool) {
        if FBNetworkRequest.shared.blockedByList.contains(uid) || FBNetworkRequest.shared.blockedList.contains(uid) {}
        else {
            var index = 0
            for cell in messageViewModel {
                if cell.uid == uid {
                    messageViewModel[index].isOnline = status
                }
                index += 1
            }
        }
    }
    
    
    private func createCellViewModel(messages: [RecentMessage]) {
        var vms = [RecentsViewModel]()
        for message in messages {
            vms.append(proccessFetchMessage(message: message))
        }
        messageViewModel.append(contentsOf: vms)
    }
    
    
    private func proccessFetchMessage(message: RecentMessage) -> RecentsViewModel {
        let name   = message.user!.first! + " " + message.user!.last!
        let status = FBNetworkRequest.shared.blockedByList.contains((message.user?.id)!) || FBNetworkRequest.shared.blockedList.contains((message.user?.id)!) ? false : message.user?.isOnline
        return RecentsViewModel(name: name, message: message.text!, imageURL: message.user!.imageURL, timestamp: message.timestamp, isOnline: status, uid: message.to, unreadCount: message.unreadCount)
    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK:- Handle selected cell
    
    func pressedCell(at indexpath: IndexPath) {
        selectedCell = messageViewModel[indexpath.row]
    }
    
    
    
    
    
    
    
    
    
    
    // MARK:- Handle searching
    
    func startSearching() {
        originalModel = messageViewModel
    }
    
    func searchAbout(text: String) {
        if text.isEmpty {
            messageViewModel = originalModel
        } else {
            let text = text.lowercased()
            messageViewModel = originalModel.filter() {($0.name?.lowercased().contains((text)))!}
        }
    }
    
    
    func endSearching() {
        messageViewModel = originalModel
    }
      
}











// MARK:- Message ViewModel

struct RecentsViewModel{
    var name: String?
    var message: String?
    var imageURL: String?
    var timestamp: Double?
    var isOnline: Bool?
    var uid: String?
    var unreadCount: Int?
}







