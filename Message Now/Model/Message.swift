//
//  Message.swift
//  Message Now
//
//  Created by Hazem Tarek on 4/30/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import Foundation

struct Message {
    var key : String?
    var to: String?
    var text: String?
    var timestamp: Double?
    var msgKind: String?
    var photoURL: String?
    var latitude: Double?
    var longitude: Double?
    var videoURL:  String?
    var voiceURL:  String?
    var voiceSec:  Double?
}

struct RecentMessage {
    var to: String?
    var text: String?
    var timestamp: Double?
    var unreadCount: Int?
    var user: User?
}
