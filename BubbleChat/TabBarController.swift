//
//  TabBarController.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: LifeCycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBar.barTintColor = UIColor.white
        tabBar.unselectedItemTintColor = UIColor.rgb(238, green: 238, blue: 238, alpha: 1)
        
        let icon1 = UITabBarItem(title: "Friends", image: UIImage(named: "friendsIcon")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "selected_friendsIcon")?.withRenderingMode(.alwaysOriginal))
        let icon2 = UITabBarItem(title: "Chat", image: UIImage(named: "bubbleIcon")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "selected_bubbleIcon")?.withRenderingMode(.alwaysOriginal))
        let icon4 = UITabBarItem(title: "Profile", image: UIImage(named: "profileIcon")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "selected_profileIcon")?.withRenderingMode(.alwaysOriginal))
        let icon3 = UITabBarItem(title: "Notification", image: UIImage(named: "notificationIcon")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "selected_notificationIcon")?.withRenderingMode(.alwaysOriginal))
        
        guard let tabOne = self.viewControllers?[0], let tabTwo = self.viewControllers?[1], let tabThree = self.viewControllers?[2], let tabFour = self.viewControllers?[3] else {
            return
        }
        
        tabOne.tabBarItem = icon1
        tabTwo.tabBarItem = icon2
        tabThree.tabBarItem = icon3
        tabFour.tabBarItem = icon4
        
        _ = tabOne.tabBarItem.tabBarItemShowingOnlyImage()
        _ = tabTwo.tabBarItem.tabBarItemShowingOnlyImage()
        _ = tabThree.tabBarItem.tabBarItemShowingOnlyImage()
        _ = tabFour.tabBarItem.tabBarItemShowingOnlyImage()
    }
    
    // MARK: UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
}


