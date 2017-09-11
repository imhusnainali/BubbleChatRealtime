//
//  InputBarView.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

class InputBarView: UIView {
    
    // MARK: Properties
    
    lazy var textView : PlaceholderTextView = {
        var textView = PlaceholderTextView()
        textView.layer.cornerRadius = 6.0
        textView.placeholder = "Type your message here..."
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textColor = .darkGray
        textView.showsVerticalScrollIndicator = true
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 10)
        textView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textView)
        return textView
    }()
    
    lazy var sendButton: UIButton = {
        var sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 19.0)
        sendButton.setTitleColor(UIColor.rgb(125, green: 212, blue: 247, alpha: 1), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(sendButton)
        return sendButton
    }()
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Layout
    
    private func setupConstraints() {
        
        textView.topAnchor.constraint(equalTo: topAnchor,constant:10).isActive = true
        textView.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant:-10).isActive = true
        textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant:-10).isActive = true
        textView.leftAnchor.constraint(equalTo: leftAnchor, constant:10).isActive = true
        
        sendButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
        sendButton.topAnchor.constraint(equalTo: topAnchor,constant:10).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant:-10).isActive = true
    }
    
}
