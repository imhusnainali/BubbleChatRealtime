//
//  SwitchTableCell.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

class SwitchTableCell: UITableViewCell {

    // MARK: IBOutlets
    
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    private func setupViews() {
        
    }
    
    
}
