//
//  ChatController.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

class ChatController: UICollectionViewController, UIGestureRecognizerDelegate {
    
    // MARK: Private Properties
    
    private let messageCellIdentifier = "cellIdentifier"
        
    // MARK: Properties
    
    var userId: String?
    
    lazy var accessoryView: InputBarView = {
        let accessoryView = InputBarView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 60))
        accessoryView.sendButton.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        return accessoryView
    }()
    
    override var inputAccessoryView: UIView {
        return accessoryView
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    // MARK: LifeCycle
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let userId = self.userId else {
            return
        }
        
        NetworkingService.shared.getUser(userId, completion: { [weak self] (user) in
            self?.title = user.name
        })
        
        guard let conversationId = NetworkingService.shared.generatePushIdUsing(userId) else {
            return
        }
        
        NetworkingService.shared.messages.removeAll()
        
        collectionView?.reloadData()
        
        NetworkingService.shared.messageWasAddedObserver(conversationId, { [weak self] in
            self?.collectionView?.insertItems(at: [IndexPath(item: NetworkingService.shared.messages.count-1, section: 0)])
        })
        
        NetworkingService.shared.messageWasRemovedObserver(conversationId, { [weak self] (index) in
            self?.collectionView?.deleteItems(at: [IndexPath(item: index, section: 0)])
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let userId = self.userId else {
            return
        }
        
        guard let conversationId = NetworkingService.shared.generatePushIdUsing(userId) else {
            return
        }
        
        NetworkingService.shared.removeAllMessagesObserver(conversationId)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        becomeFirstResponder()
        reloadInputViews()
        
        guard NetworkingService.shared.messages.count > 0 else {
            return
        }
        
        collectionView?.scrollToItem(at: IndexPath(item: NetworkingService.shared.messages.count-1, section: 0), at: .bottom, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.showsVerticalScrollIndicator = true
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.contentInset = UIEdgeInsets(top: 15.0, left: 0, bottom: 15.0, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.rgb(248, green: 248, blue: 248, alpha: 1)
        collectionView?.register(MessageCollectionCell.self, forCellWithReuseIdentifier: messageCellIdentifier)
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleHideKeyboard)))
    }
    
    // MARK: Memory Warning
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        NetworkingService.shared.lastMessages.removeAll(keepingCapacity: false)
        NetworkingService.shared.users.removeAll(keepingCapacity: false)
        NetworkingService.shared.messages.removeAll(keepingCapacity: false)
        NetworkingService.shared.notifications.removeAll(keepingCapacity: false)
        
        AsyncImageLoadingManager.shared.emptyAllCache()
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NetworkingService.shared.messages.count
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messageCellIdentifier, for: indexPath) as! MessageCollectionCell
        
        cell.chatController = self
        
        let message = NetworkingService.shared.messages[indexPath.item]
        
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(NetworkingService.shared.messages[indexPath.item].text).width + 32.0
        
        cell.messageTextView.text = NetworkingService.shared.messages[indexPath.item].text
        
        let timestampDate = Date(timeIntervalSince1970: TimeInterval(message.timestamp))
        cell.timestampLabel.text = timestampDate.formatDateToString()
        
        if let bool = NetworkingService.shared.isCurrentUser(message.senderId) {
            
            switch bool {
                
            case true :
                
                NetworkingService.shared.getCurrentUser({ (currentUser) in
                    
                    AsyncImageLoadingManager.shared.loadImageAsyncFromUrl(urlString: currentUser.picUrl, completion: { (success, image) in
                        if success && image != nil {
                            cell.userImageView.image = image
                        }
                    })
                    
                })
                
                cell.setupOutgoingBubble()
                
            case false :
                
                NetworkingService.shared.getUser(message.senderId, completion: { (user) in
                    
                    AsyncImageLoadingManager.shared.loadImageAsyncFromUrl(urlString: user.picUrl, completion: { (success, image) in
                        if success && image != nil {
                            cell.userImageView.image = image
                        }
                    })
                    
                })
                
                cell.setupIncomingBubble()
                
            }
            
        }
        
        return cell
    }
    
    // MARK: User Interaction - Hide Keyboard
    
    func handleHideKeyboard() {
        accessoryView.textView.resignFirstResponder()
    }
    
    // MARK: Database - Send Message
    
    func handleSendMessage() {
        
        guard let userId = self.userId else {
            return
        }
        
        guard let messageContent = accessoryView.textView.text, messageContent != "" else {
            return
        }
        
        accessoryView.textView.text = ""
        accessoryView.textView.placeholder = "Type your message here..."

        NetworkingService.shared.sendMessage(messageContent, toUserId: userId, completion: { [weak self] (success) in
            
            guard success else {
                return
            }
   
            guard NetworkingService.shared.messages.count > 0 else {
                return
            }
            
            self?.collectionView?.scrollToItem(at: IndexPath(item: NetworkingService.shared.messages.count-1, section: 0), at: .bottom, animated: true)
            
        })
        
    }
    
    // MARK: Database - Remove Conversation
    
    @IBAction func handleRemoveConversation(_ sender: UIBarButtonItem) {
        
        handleHideKeyboard()
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let showProfileAction = UIAlertAction(title: "Show Profile", style: .default) { (action) in
        
            self.performSegue(withIdentifier: "UserProfileController", sender: self)
        }
        
        let removeAction = UIAlertAction(title: "Remove Conversation", style: .destructive) { (action) in
            
            guard let userId = self.userId else {
                return
            }
            
            guard let conversationId = NetworkingService.shared.generatePushIdUsing(userId) else {
                return
            }
            
            NetworkingService.shared.removeConversation(conversationId, completion: { [weak self] (success) in
                self?.navigationController?.popToRootViewController(animated: true)
            })
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        actionSheet.addAction(removeAction)
        actionSheet.addAction(showProfileAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    // MARK: PrepareForSegue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "UserProfileController" {
            
            guard let destinationController = segue.destination as? UserProfileController else {
                return
            }
            
            guard let userId = self.userId else {
                return
            }
            
            destinationController.userId = userId
        }
        
    }
    
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 240.0, height: 1000.0)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17.0)], context: nil)
    }
    
}

extension ChatController: UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionViewFlowLayoutDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let message = NetworkingService.shared.messages[indexPath.item]
        
        let height = estimateFrameForText(message.text).height + 20.0
        
        return CGSize(width: UIScreen.main.bounds.size.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 { return UIEdgeInsets.zero } else { return UIEdgeInsetsMake(20.0, 0, 0, 0) }
    }
    
}
