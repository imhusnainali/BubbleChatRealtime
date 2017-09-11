//
//  AppMessage.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import Foundation

class AppMessage: NSObject {
    
    // MARK: Properties
    
    var id: String?
    var conversationId: String
    var senderId: String
    var receiverId: String
    var timestamp: NSNumber
    var text: String
    
    // MARK: Initializers
    
    init(id: String, conversationId: String, senderId: String, receiverId: String, timestamp: NSNumber, text: String) {
        self.id = id
        self.conversationId = conversationId
        self.senderId = senderId
        self.receiverId = receiverId
        self.timestamp = timestamp
        self.text = text
    }
    
    init(conversationId: String, senderId: String, receiverId: String, timestamp: NSNumber, text: String) {
        self.conversationId = conversationId
        self.senderId = senderId
        self.receiverId = receiverId
        self.timestamp = timestamp
        self.text = text
    }
    
}


