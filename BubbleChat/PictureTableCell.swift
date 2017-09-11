//
//  PictureTableCell.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

class PictureTableCell: UITableViewCell {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var userImageView: UIImageView!
    
    // MARK: LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    // MARK: Setup Views
    
    private func setupViews() {
        
        selectionStyle = .none
    }
    
}
