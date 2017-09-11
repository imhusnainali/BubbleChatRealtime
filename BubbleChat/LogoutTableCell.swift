//
//  LogoutTableCell.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

class LogoutTableCell: UITableViewCell {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var button: GradientButton!
    
    // MARK: LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    private func setupViews() {
        
        selectionStyle = .none
        
        button.layer.cornerRadius = button.frame.height/2
        button.layer.masksToBounds = true
    }
    
}
