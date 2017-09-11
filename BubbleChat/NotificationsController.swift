//
//  NotificationsController.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

class NotificationsController: UITableViewController {
    
    // MARK: Private Properties
    
    private var indexPathsArray = [Int:Bool]()
    private let cellIdentifier = "cellIdentifier"
    
    // MARK: LifeCycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NetworkingService.shared.notifications.removeAll()
        tableView.reloadData()
        
        NetworkingService.shared.notificationWasAddedObserver({ [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.insertRows(at: [IndexPath(row: NetworkingService.shared.notifications.count-1, section: 0)], with: .fade)
            self?.tableView.endUpdates()
        })
        
        NetworkingService.shared.notificationWasRemovedObserver({ [weak self] (index) in
            self?.tableView.beginUpdates()
            self?.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
            self?.tableView.endUpdates()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NetworkingService.shared.removeAllNotificationsObserver()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
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
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NetworkingService.shared.notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NotificationCell
        
        let notification = NetworkingService.shared.notifications[indexPath.row]
                
        NetworkingService.shared.getUser(notification.senderId, completion: { (user) in
            
            AsyncImageLoadingManager.shared.loadImageAsyncFromUrl(urlString: user.picUrl, completion: { (success, image) in
                if success && image != nil {
                    cell.userImageView.image = image
                }
            })
 
            cell.userNameLabel.text = "\(user.name)"
            
            let notificationDate = Date(timeIntervalSince1970: TimeInterval(notification.timestamp))
            
            cell.timestampLabel.text = notificationDate.formatDateToString()
        })
        
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
    
    
}

