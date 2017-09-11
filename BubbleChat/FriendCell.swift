//
//  FriendCell.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var sendButton: GradientButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var shouldOpenChat: ((FriendCell) -> Void)?
    
    // MARK: LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    // MARK: Setup Views
    
    private func setupViews() {
        
        userImageView.layer.masksToBounds = true
        userImageView.layer.cornerRadius = userImageView.frame.height/2
        
        sendButton.layer.cornerRadius = sendButton.frame.height/2
        sendButton.layer.masksToBounds = true
    }
    
    // MARK: User Interaction
    
    @IBAction func handleSendMessageTapped(_ sender: GradientButton) {
        shouldOpenChat?(self)
    }
    

    
}
