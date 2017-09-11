//
//  ProfileTableCell.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

class ProfileTableCell: UITableViewCell {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var addButton: GradientButton!
    
    // MARK: LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    private func setupViews() {
        
        selectionStyle = .none
        
        addButton.layer.masksToBounds = true
        addButton.layer.cornerRadius = addButton.frame.height/2
        
        userImageView.layer.masksToBounds = true
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = userImageView.frame.height/2
        userImageView.backgroundColor = UIColor.rgb(246, green: 246, blue: 246, alpha: 1)
        
    }
}
