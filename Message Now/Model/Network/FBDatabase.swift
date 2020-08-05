//
//  FBDatabase.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/7/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import Foundation
import Firebase

struct FBDatabase {
    
    
    static let shared = FBDatabase()
    
    
    
    
    
    
    // MARK:- User database
    
    func loadUserInfo(for uid: String, complation: @escaping(User?, String?)->()) {
        FBAuthentication.shared.ref.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                let values = snapshot.value as! [String: Any]
                var user = User()
                user.email = values["email"] as? String ?? ""
                user.id = values["id"] as? String ?? ""
                user.username = values["username"] as? String ?? ""
                user.first = values["first"] as? String ?? ""
                user.last = values["last"] as? String ?? ""
                user.imageURL = values["imageULR"] as? String ?? ""
                user.country = values["country"] as? String ?? nil
                user.isOnline = values["status"] as? Bool ?? true
                user.lastOnlineDate = values["lastOnlineDate"] as? Double
                complation(user, nil)
            } else {
                complation(nil, "The user is not exist")
            }
        }
    }
    
    
    func loadChatingUser(for uid: String, complation: @escaping(User?, String?)->()) {
        FBAuthentication.shared.ref.child("users").child(uid).observe(.value) { (snapshot) in
            if snapshot.exists(){
                let values = snapshot.value as! [String: Any]
                var user = User()
                user.email = values["email"] as? String ?? ""
                user.id = values["id"] as? String ?? ""
                user.username = values["username"] as? String ?? ""
                user.first = values["first"] as? String ?? ""
                user.last = values["last"] as? String ?? ""
                user.imageURL = values["imageULR"] as? String ?? ""
                user.country = values["country"] as? String ?? ""
                user.isOnline = values["status"] as? Bool ?? true
                user.lastOnlineDate = values["lastOnlineDate"] as? Double
                complation(user, nil)
            } else {
                complation(nil, "The user is not exist")
            }
        }
    }
    
    
    func loadStatusOfUser(for uid: String, complation: @escaping(Bool?, String?)->()) {
        FBAuthentication.shared.ref.child("users").child(uid).observe(.childChanged) { (snapshot) in
            if snapshot.exists(){
                let value = snapshot.value as? Bool
                complation(value, uid)
            } else {
                complation(nil, nil)
            }
        }
    }
    
    
    func loadAllUsers(complation: @escaping([User]?, String?)->()) {
        FBAuthentication.shared.ref.child("users").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                var users = [User]()
                let data = snapshot.children.allObjects as! [DataSnapshot]
                for user in data {
                    var userModel = User()
                    let id = user.childSnapshot(forPath: "id").value as? String
                    let requestStatus = FBNetworkRequest.shared.requestsRecived.contains(id!)
                    let friendStatus  = FBNetworkRequest.shared.frinedsList.contains(id!)
                    let blockedList   = FBNetworkRequest.shared.blockedList.contains(id!) || FBNetworkRequest.shared.blockedByList.contains(id!)
                    if requestStatus || friendStatus || blockedList {}
                    else {
                        userModel.id = id
                        userModel.email = user.childSnapshot(forPath: "email").value as? String
                        userModel.username = user.childSnapshot(forPath: "username").value as? String
                        userModel.first = user.childSnapshot(forPath: "first").value as? String
                        userModel.last = user.childSnapshot(forPath: "last").value as? String
                        userModel.imageURL = user.childSnapshot(forPath: "imageULR").value as? String
                        if userModel.id != Auth.auth().currentUser?.uid {
                            users.append(userModel)
                        } else {}
                    }
                }
                complation(users, nil)
            } else {
                complation(nil, nil)
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK:- Users actions
    
    func updateUserStatus(isOnline: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if isOnline {
            FBAuthentication.shared.ref.child("users").child(uid).updateChildValues(["status": true])
        } else {
            FBAuthentication.shared.ref.child("users").child(uid).updateChildValues(["status": false, "lastOnlineDate": Date().timeIntervalSince1970])
        }
    }
    
    
    func editeProfile(profileImage: UIImage, country: String, complation: @escaping(Bool, String?) -> ()) {
        let uid = Auth.auth().currentUser?.uid
        guard let imageData = profileImage.jpegData(compressionQuality: 0.5) else { return }
        let uploadTask = Storage.storage().reference().child("profile").child("\(uid!).jpg")
        uploadTask.putData(imageData, metadata: nil) { (metadat, error) in
            if error == nil {
                uploadTask.downloadURL { (url, error) in
                    if error == nil {
                        Database.database().reference().child("users").child(uid!).updateChildValues(["imageULR": url!.absoluteString, "country": country]) { (error, data) in
                            let Url = URL(string: url!.absoluteString)
                            let data = try? Data(contentsOf: Url!)
                            UserDefaults.standard.set(url?.absoluteString, forKey: "imageURL")
                            UserDefaults.standard.set(data, forKey: "image")
                            UserDefaults.standard.set(country, forKey: "country")
                            complation(true, nil)
                        }
                    } else {
                        uploadTask.delete(completion: nil)
                        complation(false, "Sorry, There is a problem. Try again")
                    }
                }
            } else {
                complation(false, "Sorry, There is a problem. Try again")
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK:- Messages database
    
    func sendMessage(to toUID: String, msg: String, msgKind: MessageKind, voiceSec: Double?) {
        let ref = FBAuthentication.shared.ref
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let timestamp = Date().timeIntervalSince1970
        var message = [String : Any]()
        var recentMessage = [String : Any]()
        
        if msgKind != .text {
            if msgKind == .photo {
                message = ["to": toUID, "photoURL": msg, "timestamp": timestamp, "msgKind": CheckMessageKind(msgKind: msgKind)]
            } else if msgKind == .location {
                message = ["to": toUID, "location": msg, "timestamp": timestamp, "msgKind": CheckMessageKind(msgKind: msgKind)]
            }else if msgKind == .video {
                message = ["to": toUID, "videoURL": msg, "timestamp": timestamp, "msgKind": CheckMessageKind(msgKind: msgKind)]
            } else if msgKind == .voice {
                message = ["to": toUID, "voiceURL": msg, "timestamp": timestamp, "msgKind": CheckMessageKind(msgKind: msgKind), "voiceSec": voiceSec ?? 0.0]
            }
            recentMessage = ["to": uid, "text": CheckMessageKind(msgKind: msgKind), "timestamp": timestamp]
        } else {
            message = ["to": toUID, "text": msg, "timestamp": timestamp, "msgKind": CheckMessageKind(msgKind: msgKind)]
            recentMessage = ["to": uid, "text": msg, "timestamp": timestamp]
        }
        
        
        let SenderRef = ref.child("messages").child(uid).child(toUID).childByAutoId()
        ref.child("unread").child(toUID).child(uid).updateChildValues([SenderRef.key!: "true"])
        SenderRef.setValue(message) { (error, data) in
            if error != nil {
                print(error!)
            } else {
                ref.child("recent_message").child(uid).child(toUID).setValue(recentMessage)
            }
        }
        ref.child("messages").child(toUID).child(uid).childByAutoId().setValue(message) { (error, data) in
            if error != nil {
                print(error!)
            } else {
                ref.child("recent_message").child(toUID).child(uid).setValue(recentMessage)
            }
        }
    }
    
    
    func sendPhoto(photo: UIImage, toUID: String) {
        guard let imageData = photo.jpegData(compressionQuality: 0.5) else { return }
        let uploadTask = Storage.storage().reference().child("messages").child("\(Date().timeIntervalSince1970).jpg")
        uploadTask.putData(imageData, metadata: nil) { (metaData, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            } else {
                uploadTask.downloadURL { (url, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        let url = url?.absoluteString
                        self.sendMessage(to: toUID, msg: url!, msgKind: .photo, voiceSec: nil)
                    }
                }
            }
        }
    }
    
    
    
    func sendVoice(file: Data, seconds: Double, toUID: String) {
        let audioName = NSUUID().uuidString
        let uploadTask = Storage.storage().reference().child("audio").child(audioName)
        uploadTask.putData(file, metadata: nil) { (metaData, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            } else {
                uploadTask.downloadURL { (url, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        let url = url?.absoluteString
                        self.sendMessage(to: toUID, msg: url!, msgKind: .voice, voiceSec: seconds)
                    }
                }
            }
        }
    }
    
    
    
    func sendLocation(toUID: String, latitude: Double, longitude: Double) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let timestamp = Date().timeIntervalSince1970
        let ref = FBAuthentication.shared.ref
        let message: [String: Any] = ["to": toUID, "timestamp": timestamp, "msgKind": CheckMessageKind(msgKind: .location), "latitude": latitude,"longitude": longitude]
        
        let SenderRef = ref.child("messages").child(uid).child(toUID).childByAutoId()
        ref.child("unread").child(toUID).child(uid).updateChildValues([SenderRef.key!: "true"])
        SenderRef.setValue(message){ (error, data) in
            if error != nil {
                print(error!)
            } else {
                ref.child("recent_message").child(uid).child(toUID).setValue(["to": toUID, "timestamp": timestamp,"text": self.CheckMessageKind(msgKind: .location)])
            }
        }
        ref.child("messages").child(toUID).child(uid).childByAutoId().setValue(message){ (error, data) in
            if error != nil {
                print(error!)
            } else {
                ref.child("recent_message").child(toUID).child(uid).setValue(["to": uid, "timestamp": timestamp,"text": self.CheckMessageKind(msgKind: .location)])
                ref.child("unread").child(toUID).child(uid).updateChildValues([data.key!: "true"])
            }
        }
        
        
    }
    
    
    func loadMessages(for Foruid: String,queryStart: Double?, complation: @escaping([Message]) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var query = FBAuthentication.shared.ref.child("messages").child(uid).child(Foruid).queryOrdered(byChild: "timestamp")
        if queryStart == nil {
            query = query.queryLimited(toLast: 20)
        } else {
            query = query.queryEnding(atValue: queryStart).queryLimited(toLast: 20)
        }
        query.observeSingleEvent(of: .value) { (snapshot) in
            var messages = [Message]()
            let data = snapshot.children.allObjects as! [DataSnapshot]
            for message in data {
                var messageModel = Message()
                messageModel.key = message.key
                messageModel.to = message.childSnapshot(forPath: "to").value as? String
                messageModel.text = message.childSnapshot(forPath: "text").value as? String
                messageModel.timestamp = message.childSnapshot(forPath: "timestamp").value as? Double
                messageModel.msgKind = message.childSnapshot(forPath: "msgKind").value as? String
                messageModel.photoURL = message.childSnapshot(forPath: "photoURL").value as? String
                messageModel.latitude = message.childSnapshot(forPath: "latitude").value as? Double
                messageModel.longitude = message.childSnapshot(forPath: "longitude").value as? Double
                messageModel.voiceURL = message.childSnapshot(forPath: "voiceURL").value as? String
                messageModel.voiceSec = message.childSnapshot(forPath: "voiceSec").value as? Double
                messages.append(messageModel)
            }
            complation(messages.reversed())
        }
    }
    
    
    
    func loadNewMessages(for Foruid: String, lastMessages: [Message], complation: @escaping(Message?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let query = FBAuthentication.shared.ref.child("messages").child(uid).child(Foruid).queryOrdered(byChild: "timestamp").queryLimited(toLast: 1)
        query.observe(.childAdded) { (snapshot) in
            let values = snapshot.value as! [String: Any]
            var message = Message()
            message.key = snapshot.key
            message.timestamp = values["timestamp"] as? Double
            message.to = values["to"] as? String
            message.text = values["text"] as? String
            message.msgKind = values["msgKind"] as? String
            message.photoURL = values["photoURL"] as? String
            message.latitude = values["latitude"] as? Double
            message.longitude = values["longitude"] as? Double
            message.voiceURL = values["voiceURL"] as? String
            message.voiceSec = values["voiceSec"] as? Double
            let status = lastMessages.contains { (element) -> Bool in return message.timestamp == element.timestamp }
            if !status {
                complation(message)
            }
        }
    }
    
    
    func loadRecentMessages(complation: @escaping([RecentMessage]?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DispatchQueue.global(qos: .background).async {
            FBAuthentication.shared.ref.child("recent_message").child(uid).queryOrdered(byChild: "timestamp").observe(.value) { (snapshot) in
                if snapshot.exists() {
                    var messages = [RecentMessage]()
                    let data = snapshot.children.allObjects as! [DataSnapshot]
                    for message in data {
                        var msg = RecentMessage()
                        msg.to = message.key
                        msg.text = message.childSnapshot(forPath: "text").value as? String
                        msg.timestamp = message.childSnapshot(forPath: "timestamp").value as? Double
                        messages.append(msg)
                    }
                    complation(messages.reversed())
                } else { complation(nil) }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK:- Messages action
    
    func loadUnreadMessagesSingleEvent(id: String, complation: @escaping(Int?)->()) {
        let ref = FBAuthentication.shared.ref
        guard let uid = Auth.auth().currentUser?.uid else { return }
        ref.child("unread").child(uid).child(id).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                let count = Int(snapshot.childrenCount)
                complation(count)
            } else { complation(nil) }
        }
    }
    
    func loadCountAllUnread(complation: @escaping(Int?)->()) {
        let ref = FBAuthentication.shared.ref
        guard let uid = Auth.auth().currentUser?.uid else { return }
        ref.child("unread").child(uid).observe(.value) { (snapshot) in
            if snapshot.exists() {
                var count = 0
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    count += Int(child.childrenCount)
                }
                complation(count)
            } else { complation(nil) }
        }
    }
    
    func updateUnreadMessagesCount(id: String, complation: @escaping(Int?)->()) {
        let ref = FBAuthentication.shared.ref
        guard let uid = Auth.auth().currentUser?.uid else { return }
        ref.child("unread").child(uid).child(id).observe(.childRemoved) { (snapshot) in
            if snapshot.exists() {
                let count = Int(snapshot.childrenCount)
                complation(count)
            } else { complation(nil) }
        }
    }
    
    
    func readMessages(id: String) {
        let ref = FBAuthentication.shared.ref
        guard let uid = Auth.auth().currentUser?.uid else { return }
        ref.child("unread").child(uid).child(id).removeValue()
    }
    
    func loadUnreadMessages(id: String, complation: @escaping([String]?) -> ()) {
        let ref = FBAuthentication.shared.ref
        guard let uid = Auth.auth().currentUser?.uid else { return }
        ref.child("unread").child(id).child(uid).observe(.value) { (snapshot) in
            var keys = [String]()
            let messages = snapshot.children.allObjects as! [DataSnapshot]
            for message in messages {
                keys.append(message.key)
            }
            complation(keys)
        }
    }
    
    func checkFriendReadMessages(id: String, complation: @escaping(Bool) -> ()) {
        let ref = FBAuthentication.shared.ref
        guard let uid = Auth.auth().currentUser?.uid else { return }
        ref.child("unread").child(id).child(uid).observe(.childRemoved) { (_) in
            complation(true)
        }
    }
    
    
    
    
    
    
    
    // MARK:- Remove database observer
    
    func removewMessagesObserver(forUID: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        FBAuthentication.shared.ref.child("messages").child(uid).child(forUID).removeAllObservers()
        FBAuthentication.shared.ref.child("users").child(uid).removeAllObservers()
    }
    
    
    
    
    
    
    
    
    
    
    // MARK:- Handle typing indicator
    
    func FBStartTypingUser(friendID: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("typing").child(uid).child(friendID).setValue([uid: "true"])
    }
    
    
    func FBEndTypingUser(friendID: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("typing").child(uid).child(friendID).removeValue()
    }
    
    
    func FBDetectFriendTyping(friendID: String, complation: @escaping(Bool) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("typing").child(friendID).child(uid).observe(.value) { (snapshot) in
            snapshot.exists() ? complation(true) : complation(false)
        }
    }
    
    
    
    
    
    
    
    
    
    //MARK:- Validate kind and Type of Messages
    
    func CheckMessageKind(msgKind: MessageKind) -> String {
        switch msgKind {
            case .location:
                return "location"
            case .photo:
                return "photo"
            case .text:
                return "text"
            case .video:
                return "video"
            case .voice:
                return "voice"
        }
    }
}
