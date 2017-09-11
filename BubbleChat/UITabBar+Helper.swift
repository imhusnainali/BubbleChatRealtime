//
//  UITabBar+Helper.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

extension UITabBarItem {
    
    func tabBarItemShowingOnlyImage() -> UITabBarItem {
        self.imageInsets = UIEdgeInsets(top:5,left:0,bottom:-5,right:0)
        self.titlePositionAdjustment = UIOffsetMake(0, -10000.0);
        return self
    }
    
}
