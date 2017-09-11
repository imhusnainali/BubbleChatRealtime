//
//  ProfilePreviewController.swift
//  BubbleChat
//
//  Created by Aleks on 9/5/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

class ProfilePreviewController: UITableViewController {

    // MARK: Private Properties
    
    private let cellIdentifier = "cellIdentifier"
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = ""
        
        tableView.register(UINib(nibName: "PictureTableCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
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
        return UIScreen.main.bounds.size.width
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PictureTableCell
        
        NetworkingService.shared.getCurrentUser({ [weak self] (currentUser) in
            
            AsyncImageLoadingManager.shared.loadImageAsyncFromUrl(urlString: currentUser.picUrl, completion: { (success, image) in
                if success && image != nil {
                    cell.userImageView.image = image
                }
            })
            
            self?.title = currentUser.name
        })
        
        return cell
    }

    
}
