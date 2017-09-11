//
//  NetworkingService.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import Firebase
import FirebaseAuth
import FirebaseMessaging

class NetworkingService {
    
    // MARK: Singleton
    
    static let shared = NetworkingService()
    
    // MARK: Database References
    
    let baseRef = Database.database().reference()
    let usersRef = Database.database().reference().child("users")
    let conversationsRef = Database.database().reference().child("conversation_messages")
    let notificationsRef = Database.database().reference().child("notifications")
    
    // MARK: Storage References
    
    let storageRef = Storage.storage().reference()
    
    // MARK: Properties
    
    var users = [AppUser]()
    var lastMessages = [AppMessage]()
    var notifications = [AppNotification]()
    var messages = [AppMessage]()

    // MARK: Sign Up
    
    func createAccount(_ email: String, password: String, name: String, completion: @escaping (_ success: Bool) -> ()) {
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user:User?, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                completion(false)
                return
            }
            
            completion(true)
        })
        
    }
    
    // MARK: Login
    
    func loginAccount(_ email: String, password: String, completion: @escaping (_ success: Bool) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            guard error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        })
    }
    
    // MARK: Logout
    
    func logoutAccount() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("ERROR: \(signOutError)")
        }
    }
    
    // MARK: Save Account Data To Database
    
    func saveAccountDataOnDatabase(_ email: String, password: String, name: String, picUrl: String, completion: @escaping (_ success: Bool) -> ()) {
        
        var userInfo = [String: AnyObject]()
        
        userInfo = ["email": email as AnyObject, "name": name as AnyObject, "picUrl": picUrl as AnyObject]
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        
        usersRef.child(currentUserID).setValue(userInfo, withCompletionBlock: { (error, ref) in
            
            guard error == nil else {
                return
            }
            
            completion(true)
        })
        
    }
    
    // MARK: Upload Image To Storage
    
    func uploadImageToStorage(picture: UIImage, completion: @escaping (_ success: Bool, _ picUrl: String?) -> ()) {
        
        guard let uploadData = UIImageJPEGRepresentation(picture, 0.1) else {
            completion(false, nil)
            return
        }
        
        let imageName = UUID().uuidString
        
        storageRef.child("profile_images").child("\(imageName).jpg").putData(uploadData, metadata: nil, completion: { (metadata, error) in
            
            guard error == nil else {
                completion(false, nil)
                print(error!.localizedDescription)
                return
            }
            
            guard let picUrl = metadata?.downloadURL()?.absoluteString else {
                completion(false, nil)
                return
            }
            
            completion(true, picUrl)
            
        })
    }
    
    // MARK: Get Current User
    
    func getCurrentUser(_ completion: @escaping (AppUser) -> ()) {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        
        usersRef.child(currentUserID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let email = snapshot.childSnapshot(forPath: "email").value as? String else { return }
            guard let name = snapshot.childSnapshot(forPath: "name").value as? String else { return }
            guard let picUrl = snapshot.childSnapshot(forPath: "picUrl").value as? String else { return }
            completion(AppUser(id: snapshot.key, email: email, name: name, picUrl: picUrl))
        })
    }
    
    // MARK: Get User
    
    func getUser(_ userId: String, completion: @escaping (AppUser) -> ()) {
        usersRef.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let email = snapshot.childSnapshot(forPath: "email").value as? String else { return }
            guard let name = snapshot.childSnapshot(forPath: "name").value as? String else { return }
            guard let picUrl = snapshot.childSnapshot(forPath: "picUrl").value as? String else { return }
            completion(AppUser(id: snapshot.key, email: email, name: name, picUrl: picUrl))
        })
    }
    
    // MARK: User Was Added Observer
    
    func userWasAddedObserver(completion: @escaping () -> ()) {
        usersRef.observe(.childAdded, with: { [weak self] (snapshot) in
            
            guard let currentUserId = Auth.auth().currentUser?.uid else {
                return
            }
            
            let userId = snapshot.key
            
            if userId != currentUserId {
                
                self?.getUser(userId, completion: { (user) in
                    self?.users.append(user)
                    completion()
                })
                
            }
        })
    }
    
    // MARK: User Was Removed Observer
    
    func userWasRemovedObserver(completion: @escaping (_ index: Int) -> ()) {
        usersRef.observe(.childRemoved, with: { [weak self] (snapshot) in
            
            guard let strongSelf = self else {
                return
            }
            
            let index = strongSelf.indexOfUser(snapshot, array: strongSelf.users)
            strongSelf.users.remove(at: index)
            completion(index)
        })
    }
    
    // MARK: Remove All User Observers
    
    func removeAllUserObservers() {
        usersRef.removeAllObservers()
    }
    
    // MARK: Index Of User Helper
    
    func indexOfUser(_ snapshot: DataSnapshot, array: [AppUser]) -> Int {
        var index = 0
        for user in array {
            if snapshot.key == user.id {
                return index
            }
            index += 1
        }
        return -1
    }
    
    // MARK: Index Of Conversation Helper
    
    func indexOfConversation(_ snapshot: DataSnapshot, array: [AppUser]) -> Int {
        var index = 0
        for user in array {
            if snapshot.key.contains(user.id) {
                return index
            }
            index += 1
        }
        return -1
    }
    
    
    // MARK: Conversation Was Added Observer
    
    func conversationWasAddedObserver(_ completion: @escaping () -> ()) {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        usersRef.child(currentUserId).child("conversations").queryOrdered(byChild: "timestamp").observe(.childAdded, with: { [weak self] (snapshot) in
            
            print("child added!!")
            
            guard let text = snapshot.childSnapshot(forPath: "text").value as? String,
                let timestamp = snapshot.childSnapshot(forPath: "timestamp").value as? NSNumber,
                let senderId = snapshot.childSnapshot(forPath: "senderId").value as? String,
                let receiverId = snapshot.childSnapshot(forPath: "receiverId").value as? String
                else {
                    return
            }
            
            self?.lastMessages.insert(AppMessage(conversationId: snapshot.key, senderId: senderId, receiverId: receiverId, timestamp: timestamp, text: text), at: 0)
            
            completion()
            
        })
    }

    
    // MARK: Conversation Was Changed Observer
    
    func conversationWasChangedObserver(_ completion: @escaping (_ index: Int) -> ()) {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        usersRef.child(currentUserId).child("conversations").queryOrdered(byChild: "timestamp").observe(.childChanged, with: { [weak self] (snapshot) in
            
            print("child changed!!")
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.getLastMessageFor(snapshot.key, completion: { (element) in
                
                let index = strongSelf.indexOfLastMessage(snapshot, array: strongSelf.lastMessages)
                strongSelf.lastMessages.remove(at: index)
                strongSelf.lastMessages.insert(element, at: 0)
                completion(index)
  
            })
            
        })
    }

    // MARK: Conversatiom Was Removed Observer
    
    func conversationWasRemovedObserver(_ completion: @escaping (_ index: Int) -> ()) {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        usersRef.child(currentUserId).child("conversations").queryOrdered(byChild: "timestamp").observe(.childRemoved, with: { [weak self] (snapshot) in
            
            guard let strongSelf = self else {
                return
            }
            
            print("child removed!!")
            
            let index = strongSelf.indexOfLastMessage(snapshot, array: strongSelf.lastMessages)
            self?.lastMessages.remove(at: index)
            completion(index)
            
        })
    }

    // MARK: Remove All Message Observers
    
    func removeAllConversationObservers() {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        usersRef.child(currentUserId).child("conversations").removeAllObservers()
    }
    

    // MARK: Index Of Last Message
    
    func indexOfLastMessage(_ snapshot: DataSnapshot, array: [AppMessage]) -> Int {
        
        var index = 0
        
        for lastMessage in array {
            
            print(snapshot.key, lastMessage.conversationId)
            
            if snapshot.key == lastMessage.conversationId {
                return index
            }
            index += 1
        }
        return -1
    }
    
    
    
    // MARK: Get Last Message for Conversation
    
    func getLastMessageFor(_ conversationId: String, completion: @escaping (AppMessage) -> ()) {
        
        baseRef.child("conversation_messages").child(conversationId).queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                guard let text = child.childSnapshot(forPath: "text").value as? String,
                    let timestamp = child.childSnapshot(forPath: "timestamp").value as? NSNumber,
                    let receiverId = child.childSnapshot(forPath: "receiverId").value as? String,
                    let senderId = child.childSnapshot(forPath: "senderId").value as? String
                    else {
                        return
                }
                
                completion(AppMessage(conversationId: conversationId, senderId: senderId, receiverId: receiverId, timestamp: timestamp, text: text))

            }
            
        })
    }
    
    // MARK: Remove Conversation
    
    func removeConversation(_ conversationId: String, completion: @escaping (Bool) -> ()) {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        guard let partnerId = getPartnerIdUsing(conversationId) else {
            return
        }
        
        baseRef.updateChildValues(["/users/\(currentUserId)/conversations/\(conversationId)/": NSNull(),
                                   "/users/\(partnerId)/conversations/\(conversationId)/": NSNull(),
                                   "/conversation_messages/\(conversationId)/": NSNull()], withCompletionBlock: { (error, ref) in
                                    
                                    guard error == nil else {
                                        return completion(false)
                                    }
                                    
                                    completion(true)
        })
        
    }
    
    
    
    
    // MARK: Message Was Added Observer
    
    func messageWasAddedObserver(_ conversationId: String, _ completion: @escaping () -> ()) {
        conversationsRef.child(conversationId).observe(.childAdded, with: { [weak self] (snapshot) in
            
            let messageId = snapshot.key
            
            guard let senderId = snapshot.childSnapshot(forPath: "senderId").value as? String else { return }
            guard let receiverId = snapshot.childSnapshot(forPath: "receiverId").value as? String else { return }
            guard let timestamp = snapshot.childSnapshot(forPath: "timestamp").value as? NSNumber else { return }
            guard let text = snapshot.childSnapshot(forPath: "text").value as? String else { return }
            
            self?.messages.append(AppMessage(id: messageId, conversationId: conversationId, senderId: senderId, receiverId: receiverId, timestamp: timestamp, text: text))
            completion()
        })
    }
    
    // MARK: Message Was Removed Observer
    
    func messageWasRemovedObserver(_ conversationId: String, _ completion: @escaping (_ index: Int) -> ()) {
        conversationsRef.child(conversationId).observe(.childRemoved, with: { [weak self] (snapshot) in
            guard let strongSelf = self else {
                return
            }
            let index = strongSelf.indexOfMessage(snapshot, array: strongSelf.messages)
            strongSelf.messages.remove(at: index)
            completion(index)
        })
    }
    
    // MARK: Remove All Message Observers
    
    func removeAllMessagesObserver(_ conversationId: String) {
        conversationsRef.child(conversationId).removeAllObservers()
    }
    
    // MARK: Index Of Message Helper
    
    func indexOfMessage(_ snapshot: DataSnapshot, array: [AppMessage]) -> Int {
        var index = 0
        for message in array {
            if snapshot.key == message.id {
                return index
            }
            index += 1
        }
        return -1
    }

    
    
    // MARK: Send Message
    
    func sendMessage(_ messageContent: String, toUserId: String, completion: @escaping (Bool) -> ()) {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        
        guard currentUserId != toUserId else {
            completion(false)
            return
        }
        
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        
        let sender = currentUserId
        
        let constructedKey = generatePushIdUsing(toUserId)
        let messageKey = baseRef.childByAutoId().key
    
        
        guard let conversationKey = constructedKey else {
            completion(false)
            return
        }
        
        let messageData: [String: Any] = ["text": messageContent,
                                          "senderId": sender,
                                          "receiverId": toUserId,
                                          "timestamp": timestamp]
        
        let childUpdates: [String: Any] = ["users/\(currentUserId)/conversations/\(conversationKey)": messageData,
                                           "users/\(toUserId)/conversations/\(conversationKey)": messageData,
                                           "conversation_messages/\(conversationKey)/\(messageKey)": messageData ]
        
        baseRef.updateChildValues(childUpdates, withCompletionBlock: { (error, ref) in
            
            guard error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        })
        
    }
    
    
    // MARK: Generate Custom Push ID
    
    func generatePushIdUsing(_ userId: String) -> String? {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return nil
        }
        
        let id1 = userId
        let id2 = currentUserId
        
        if id1 > id2 {
            return "\(id2)_\(id1)"
        } else {
            return "\(id1)_\(id2)"
        }
        
    }
    
    // MARK: Get Partner ID
    
    func getPartnerIdUsing(_ conversationId: String) -> String? {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return nil
        }
        
        let userIds = conversationId.components(separatedBy: "_")
        
        var partnerId: String
        
        if userIds[0] == currentUserId {
            partnerId = userIds[1]
        } else {
            partnerId = userIds[0]
        }
        
        return partnerId
    }
    
    // MARK: Get Notification
    
    func getNotification(_ notificationID: String, completion: @escaping (AppNotification) -> ()) {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        notificationsRef.child(currentUserId).child(notificationID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let senderName = snapshot.childSnapshot(forPath: "senderName").value as? String else { return }
            guard let senderId = snapshot.childSnapshot(forPath: "senderId").value as? String else { return }
            guard let timestamp = snapshot.childSnapshot(forPath: "timestamp").value as? NSNumber else { return }
            guard let text = snapshot.childSnapshot(forPath: "text").value as? String else { return }
            completion(AppNotification(id: notificationID, senderName: senderName, senderId: senderId, timestamp: timestamp, text: text))
        })
    }
    
    // MARK: Notification Was Added Observer
    
    func notificationWasAddedObserver(_ completion: @escaping () -> ()) {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        notificationsRef.child(currentUserId).observe(.childAdded, with: { [weak self] (snapshot) in
            let notificationID = snapshot.key
            self?.getNotification(notificationID, completion: { (notification) in
                self?.notifications.append(notification)
                completion()
            })
        })
    }
    
    // MARK: Notification Was Removed Observer
    
    func notificationWasRemovedObserver(_ completion: @escaping (_ index: Int) -> ()) {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        notificationsRef.child(currentUserId).observe(.childRemoved, with: { [weak self] (snapshot) in
            guard let strongSelf = self else {
                return
            }
            let index = strongSelf.indexOfNotification(snapshot, array: strongSelf.notifications)
            strongSelf.notifications.remove(at: index)
            completion(index)
        })
    }
    
    // MARK: Remove All Notification Observers
    
    func removeAllNotificationsObserver() {
        notificationsRef.removeAllObservers()
    }
    
    // MARK: Index Of Notification Helper
    
    func indexOfNotification(_ snapshot: DataSnapshot, array: [AppNotification]) -> Int {
        var index = 0
        for notification in array {
            if snapshot.key == notification.id {
                return index
            }
            index += 1
        }
        return -1
    }
    
    // MARK: Update Profile Image
    
    func updateCurrentUserImage(_ pic: UIImage, completion: @escaping (_ success: Bool) -> ()) {
        
        
        uploadImageToStorage(picture: pic, completion: { [weak self] (success, picUrl) in
            
            guard let picUrl = picUrl, success else {
                completion(false)
                return
            }
            
            guard let currentUserID = Auth.auth().currentUser?.uid else {
                completion(false)
                return
            }
            
            self?.usersRef.child(currentUserID).child("picUrl").setValue(picUrl, withCompletionBlock: { (error, ref) in
                
                guard error == nil else {
                    completion(false)
                    return
                }
                
                completion(true)
            })
        })
    }
    
    // MARK: User Check Helper Method
    
    func isCurrentUser(_ userID: String) -> Bool? {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return nil
        }
        
        return currentUserId == userID
    }
    
    // MARK: Token Saving
    
    func saveTokenToDatabase() {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        guard let token = Messaging.messaging().fcmToken else {
            return
        }
        
        let tokenData: [String: String] = [token: "true"]
        usersRef.child(currentUserId).child("notificationTokens").setValue(tokenData)
    }
    
}
