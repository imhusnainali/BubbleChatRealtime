//
//  AppNotification.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import Foundation

class AppNotification: NSObject {
    
    // MARK: Properties
    
    var id: String
    var senderName: String
    var senderId: String
    var timestamp: NSNumber
    var text: String
    
    // MARK: Initializers
    
    init(id: String, senderName: String, senderId: String, timestamp: NSNumber, text: String) {
        self.id = id
        self.senderName = senderName
        self.senderId = senderId
        self.timestamp = timestamp
        self.text = text
    }
    
    
}
