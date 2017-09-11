//
//  UserProfileController.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

class UserProfileController: UITableViewController {
        
    // MARK: Properties
    
    var userId: String?
    
    // MARK: Private Properties
    
    private let cellIdentifier = "cellIdentifier"
    private let buttonCellIdentifier = "buttonCellIdentifier"
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = ""
        
        tableView.register(UINib(nibName: "PictureTableCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.register(UINib(nibName: "ButtonTableCell", bundle: nil), forCellReuseIdentifier: buttonCellIdentifier)
        
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
        if indexPath.row == 0 {
            return UIScreen.main.bounds.size.width
        } else {
            return 110.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PictureTableCell
            
            if let userId = self.userId {
                
                NetworkingService.shared.getUser(userId, completion: { [weak self] (user) in
                    
                    AsyncImageLoadingManager.shared.loadImageAsyncFromUrl(urlString: user.picUrl, completion: { (success, image) in
                        if success && image != nil {
                            cell.userImageView.image = image
                        }
                    })
                    
                    self?.title = user.name
                })
            }
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: buttonCellIdentifier, for: indexPath) as! ButtonTableCell
            cell.button.addTarget(self, action: #selector(handleShowChatScreen), for: .touchUpInside)
            return cell
        }
        
    }
    
    // MARK: Database - Send Message
    
    func handleShowChatScreen() {
        performSegue(withIdentifier: "ChatController", sender: self)
    }
    
    // MARK: PrepareForSegue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ChatController" {
            
            guard let destinationController = segue.destination as? ChatController else {
                return
            }
            
            guard let userId = self.userId else {
                return
            }
            
            destinationController.userId = userId
        }
    }
    
}

