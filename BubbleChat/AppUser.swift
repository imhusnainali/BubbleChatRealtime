//
//  AppUser.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import Foundation

class AppUser : NSObject {
    
    // MARK: Properties
    
    var id: String
    var email: String
    var name: String
    var picUrl: String
    
    // MARK: Initializers
    
    init(id: String, email: String, name: String, picUrl: String) {
        self.id = id
        self.email = email
        self.name = name
        self.picUrl = picUrl
    }
    
}
