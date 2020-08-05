//
//  ChatingViewModel.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/15/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit

class ChatingViewModel {
    
    public  var friend             : UserViewModel? { didSet { updateUserInfoClouser?() }}
    public  var friend_image       : UIImage? { didSet { updateUserImageoClouser?() }}
    public  var messageViewModel   = [MessageViewModel]() { didSet { reloadTableViewClouser?() }}
    public  var countOfCells       : Int { return messageViewModel.count}
    
    
    private var queryStart         : Double?
    private var unreadMessages     = [String]()
    public  var selectedCell       : MessageViewModel?
    
    
    private var lastIsReached   = false
    private var isFetching      = false
    public  var isNew           = false
    public  var isTyping        = false { didSet { updateFriendStatusClouser?() }}
    public  var isFriendBlocked = false { didSet { updateBottomViewClouser?() }}
    public  var isYouBlocked    = false { didSet { updateBottomViewClouser?() }}
    
    
    var updateUserInfoClouser      : (()->())?
    var updateUserImageoClouser    : (()->())?
    var reloadTableViewClouser     : (()->())?
    var updateTableViewClouser     : (()->())?
    var updateFriendStatusClouser  : (()->())?
    var updateBottomViewClouser    : (()->())?
    
    
    
    
    
    
    
    
    
    
    // MARK:- Fetch friend info
    
    public func fetchUserInfo(uid: String) {
        FBDatabase.shared.readMessages(id: uid)
        FBDatabase.shared.loadChatingUser(for: uid) { [weak self] (user, error) in
            guard let self = self else { return }
            if error == nil {
                self.friend = self.createUserViewModel(user: user!)
                self.createUserImage(url: (user?.imageURL)!)
            }else { print(error!) }
        }
    }
    
    private func createUserViewModel(user: User) -> UserViewModel {
        let name = user.first! + " " + user.last!
        let lastOnlineDate = user.lastOnlineDate!.getDays() == "Just now" ? "Just now": "Active \(user.lastOnlineDate!.getDays()) ago"
        let availability = DefaultSettings.shared.availability()
        let status = isYouBlocked || isFriendBlocked || !availability ? "" : user.isOnline! ? "Online" : lastOnlineDate
        return UserViewModel(name: name, username: user.username!, email: user.email!, imageURL: user.imageURL!, uid: user.id!, status: status)
    }
    
    private func createUserImage(url: String) {
        let imageView = UIImageView()
        imageView.KFload(url: url) { [weak self] (image) in
            guard let self = self else { return }
            self.friend_image = image
        }
    }
    
    
    
    
    
    
    
    
    
    
    // MARK:- Fetch Messages
    
    public func fetchMessages(uid: String) {
        FBDatabase.shared.loadUnreadMessages(id: uid) { [weak self] (keys) in
            guard let self = self else { return }
            if keys!.count > 0 {
                self.unreadMessages.append(contentsOf: keys!)
            } else { self.checkFriendSeenMessage(uid: uid) }
        }
        guard !isFetching else { return }
        isFetching = true
        FBDatabase.shared.loadMessages(for: uid, queryStart: queryStart) { [weak self] (newMessages) in
            guard let self = self else { return }
            self.lastIsReached = newMessages.count == 0
            if self.lastIsReached {
                self.fetchNewMessages(uid: uid, messages: newMessages)
                return
            }
            self.lastIsReached = newMessages.count < 20
            self.queryStart = newMessages[newMessages.count-1].timestamp
            if newMessages.count == 20 {
                var messages = newMessages
                messages.removeLast()
                self.createMessageViewModel(messages: messages)
            } else {
                self.createMessageViewModel(messages: newMessages)
            }
            self.fetchNewMessages(uid: uid, messages: newMessages)
            self.isFetching = false
        }
    }
    
    // Fetch the new messages
    public func fetchNewMessages(uid: String, messages: [Message]) {
        FBDatabase.shared.loadNewMessages(for: uid, lastMessages: messages) { [weak self] (newMessage) in
            guard let self = self else { return }
            self.isFetching = false
            self.isNew = true
            self.createNMessageViewModel(message: newMessage!)
        }
    }
    
    // Fetching more messages (Pagenation)
    public func fetchMoreMessages(uid: String) {
        guard !isFetching else { return }
        guard !lastIsReached else { return }
        isFetching = true
        FBDatabase.shared.loadMessages(for: uid, queryStart: queryStart) { [weak self] (newMessages) in
            guard let self = self else { return }
            let NMsgsCount = newMessages.count
            self.lastIsReached = NMsgsCount == 0
            self.lastIsReached = NMsgsCount < 20
            self.queryStart = newMessages[NMsgsCount-1].timestamp
            if NMsgsCount == 20 {
                var messages = newMessages
                messages.removeLast()
                self.createMessageViewModel(messages: messages)
            } else {
                self.createMessageViewModel(messages: newMessages)
            }
            
            self.isFetching = false
        }
    }
    
    
    private func createMessageViewModel(messages: [Message]) {
        var vms = [MessageViewModel]()
        for message in messages {
            vms.append(proccessFetchMessage(message: message))
        }
        messageViewModel.append(contentsOf: vms)
    }
    
    private func createNMessageViewModel(message: Message) {
        messageViewModel.insert(proccessFetchMessage(message: message), at: 0)
    }
    
    private func proccessFetchMessage(message: Message) -> MessageViewModel {
        let isSeen = checkSeenMessage(message: message)
        return MessageViewModel(to: message.to, text: message.text, timestamp: message.timestamp, msgKind: message.msgKind, photoURL: message.photoURL, latitude: message.latitude, longitude: message.longitude, voiceURL: message.voiceURL, videoURL: message.videoURL, voiceSec: message.voiceSec, isSeen: isSeen)
    }
    
    
    //Get the Index of selected cell
    func pressedCell(at indexpath: IndexPath) {
        selectedCell = messageViewModel[indexpath.row]
    }
    
    
    
    
    
    
    
    
    
    // MARK:- Handle unread messages
    
    func readMessages(friendID: String) {
        FBDatabase.shared.readMessages(id: friendID)
    }
    
    private func checkFriendSeenMessage(uid: String) {
        var newVM = [MessageViewModel]()
        self.messageViewModel.forEach { (message) in
            var msg = message
            msg.isSeen = true
            newVM.append(msg)
            if msg.timestamp == self.messageViewModel.last?.timestamp {
                self.messageViewModel = newVM
            }
        }
    }
    
    private func checkSeenMessage(message: Message) -> Bool {
        let isSeen = unreadMessages.contains(message.key!) ? false : true
        return isSeen
    }
    
    
    
    
    
    
    
    
    
    
    // MARK:- Handling send message
    
    func sendTextMessage(uid: String, text: String) {
        FBDatabase.shared.sendMessage(to: uid, msg: text, msgKind: .text, voiceSec: 0)
    }
    
    func sendVoiceMessage(data: Data, seconds: Double, uid: String) {
        FBDatabase.shared.sendVoice(file: data, seconds: seconds, toUID: uid)
    }
    
    func sendLocationMessage(uid: String, latitude: Double, longitude: Double) {
        FBDatabase.shared.sendLocation(toUID: uid, latitude: latitude, longitude: longitude)
    }
    
    func sendPhotoMessage(image: UIImage, uid: String) {
        FBDatabase.shared.sendPhoto(photo: image, toUID: uid)
    }
    
    
    
    
    
    // MARK:- Handle typing action
    
    func startTyping(friendID: String) {
        FBDatabase.shared.FBStartTypingUser(friendID: friendID)
    }
    
    func endTyping(friendID: String) {
        FBDatabase.shared.FBEndTypingUser(friendID: friendID)
    }
    
    func detectFrindTyping(friendID: String) {
        FBDatabase.shared.FBDetectFriendTyping(friendID: friendID) { (isTyping) in
            self.isTyping = isTyping
        }
    }
    
    
    
    
    
    
    
    
    
    
    // MARK:- Check Blocking

    func checkBlocking(uid: String) {
        if FBNetworkRequest.shared.blockedList.isEmpty {
            FBNetworkRequest.shared.fetchBlockedList { [unowned self] (_) in
                self.isFriendBlocked = FBNetworkRequest.shared.blockedList.contains(uid)
            }
        } else {
            self.isFriendBlocked = FBNetworkRequest.shared.blockedList.contains(uid)
        }
        
        if FBNetworkRequest.shared.blockedByList.isEmpty {
            FBNetworkRequest.shared.fetchBlockedByList { [unowned self] (_) in
                self.isYouBlocked = FBNetworkRequest.shared.blockedByList.contains(uid)
            }
        } else {
            self.isYouBlocked = FBNetworkRequest.shared.blockedByList.contains(uid)
        }
    }
    
}









// MARK:- Message View Model

struct MessageViewModel {
    
    var to       : String?
    var text     : String?
    var timestamp: Double?
    var msgKind  : String?
    var photoURL : String?
    var latitude : Double?
    var longitude: Double?
    var voiceURL : String?
    var videoURL : String?
    var voiceSec : Double?
    var isSeen   : Bool?
    
}
