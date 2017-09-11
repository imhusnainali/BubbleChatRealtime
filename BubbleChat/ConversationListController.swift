//
//  ConversationListController.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

class ConversationListController: UITableViewController {
    
    // MARK: Private Properties
    
    private var indexPathsArray = [Int:Bool]()
    
    private let cellIdentifier = "cellIdentifier"
    
    // MARK: LifeCycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NetworkingService.shared.lastMessages.removeAll()
        tableView.reloadData()
        
        NetworkingService.shared.conversationWasAddedObserver { [weak self] in
            
            self?.tableView.beginUpdates()
            self?.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            self?.tableView.endUpdates()
        }
        
        NetworkingService.shared.conversationWasChangedObserver { [weak self] (index) in
            
            self?.tableView.beginUpdates()
            self?.tableView.moveRow(at: IndexPath(row: index, section: 0), to: IndexPath(row: 0, section: 0))
            self?.tableView.endUpdates()
            
            self?.tableView.beginUpdates()
            self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            self?.tableView.endUpdates()
        }
        
        NetworkingService.shared.conversationWasRemovedObserver ({ [weak self] (index) in
            
            self?.tableView.beginUpdates()
            self?.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .right)
            self?.tableView.endUpdates()
        })
 
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NetworkingService.shared.removeAllConversationObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ConversationTableCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    // MARK: Memory Warning
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        NetworkingService.shared.messages.removeAll(keepingCapacity: false)
        NetworkingService.shared.lastMessages.removeAll(keepingCapacity: false)
        NetworkingService.shared.users.removeAll(keepingCapacity: false)
        NetworkingService.shared.notifications.removeAll(keepingCapacity: false)
        
        AsyncImageLoadingManager.shared.emptyAllCache()
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "ChatController", sender: selectedCell)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NetworkingService.shared.lastMessages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ConversationTableCell
        
        let lastMessage = NetworkingService.shared.lastMessages[indexPath.row]
        
        cell.userImageView.image = UIImage()
        cell.timestampLabel.text = ""
        cell.userMessageLabel.text = ""
        cell.userNameLabel.text = ""
        
        if let partnerId = NetworkingService.shared.getPartnerIdUsing(NetworkingService.shared.lastMessages[indexPath.row].conversationId) {
            
            NetworkingService.shared.getUser(partnerId, completion: { (user) in
                
                cell.userNameLabel.text = user.name
                
                AsyncImageLoadingManager.shared.loadImageAsyncFromUrl(urlString: user.picUrl, completion: { (success, image) in
                    if success && image != nil {
                        cell.userImageView.image = image
                    }
                })
                
                cell.userMessageLabel.text = lastMessage.text
                
                let lastMessageDate = Date(timeIntervalSince1970: TimeInterval(lastMessage.timestamp))
                cell.timestampLabel.text = lastMessageDate.formatDateToString()
                
            })
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPathsArray[indexPath.row] == nil {
            
            cell.alpha = 0.0
            
            UIView.animate(withDuration: 0.5, animations: {
                cell.alpha = 1.0
            })
            
        }
        
        if indexPathsArray[indexPath.row] == nil {
            indexPathsArray[indexPath.row] = true
        }
    }
    
    // MARK: PrepareForSegue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ChatController" {
            
            guard let destinationController = segue.destination as? ChatController else {
                return
            }
            
            guard let selectedCell = sender as? UITableViewCell else {
                return
            }
            
            guard let selectedIndex = tableView.indexPath(for: selectedCell) else {
                return
            }
            
            guard let partnerId = NetworkingService.shared.getPartnerIdUsing(NetworkingService.shared.lastMessages[selectedIndex.row].conversationId) else {
                return
            }
            
            destinationController.userId = partnerId
            destinationController.hidesBottomBarWhenPushed = true
        }
        
    }
    
}

