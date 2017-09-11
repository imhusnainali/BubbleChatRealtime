//
//  MessageCollectionCell.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

class MessageCollectionCell: UICollectionViewCell {
    
    // MARK: Properties
    
    var chatController: ChatController?
    
    let bubbleView: UIView = {
        let bubbleView = UIView()
        bubbleView.layer.cornerRadius = 9.0
        bubbleView.backgroundColor = .clear
        bubbleView.layer.masksToBounds = true
        bubbleView.isUserInteractionEnabled = true
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        return bubbleView
    }()
    
    let messageTextView: UITextView = {
        let messageTextView = UITextView()
        messageTextView.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam eget magna arcu. Vivamus quis posuere orci. Aliquam porta commodo posuere. Suspendisse vel lacinia diam, in sodales dolor."
        messageTextView.font = UIFont.systemFont(ofSize: 17.0)
        messageTextView.textColor = .white
        messageTextView.isScrollEnabled = false
        messageTextView.isSelectable = false
        messageTextView.isEditable = false
        messageTextView.isUserInteractionEnabled = false
        messageTextView.backgroundColor = UIColor.clear
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        return messageTextView
    }()
    
    let messageImageView: UIImageView = {
        let messageImageView = UIImageView()
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.layer.cornerRadius = 16
        messageImageView.layer.masksToBounds = true
        messageImageView.contentMode = .scaleAspectFill
        messageImageView.isHidden = true
        messageImageView.isUserInteractionEnabled = true
        return messageImageView
    }()
    
    let timestampLabel: UILabel = {
        let timestampLabel = UILabel()
        timestampLabel.font = UIFont(name: "HelveticaNeue", size: 11.5)
        timestampLabel.text = "19:17"
        timestampLabel.textColor = UIColor.lightGray.withAlphaComponent(0.75)
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        return timestampLabel
    }()
    
    let userImageView: UIImageView = {
        let userImageView = UIImageView()
        userImageView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.25)
        userImageView.layer.cornerRadius = 20.0
        userImageView.layer.masksToBounds = true
        userImageView.contentMode = .scaleAspectFill
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        return userImageView
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    var timestampLeftAnchor: NSLayoutConstraint?
    var timestampRightAnchor: NSLayoutConstraint?
    
    var imageLeftAnchor: NSLayoutConstraint?
    var imageRightAnchor: NSLayoutConstraint?
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(bubbleView)
        contentView.addSubview(userImageView)
        contentView.addSubview(timestampLabel)
        bubbleView.addSubview(messageTextView)
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    private func setupConstraints() {
        
        timestampLeftAnchor = timestampLabel.leftAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: 5)
        timestampRightAnchor = timestampLabel.rightAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: -5)
        timestampRightAnchor?.isActive = false
        timestampLeftAnchor?.isActive = true
        timestampLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant:6).isActive = true
        
        timestampRightAnchor?.priority = 999
        timestampLeftAnchor?.priority = 999

        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 8.0)
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: userImageView.leftAnchor, constant: -8.0)
        bubbleViewRightAnchor?.isActive = true
        bubbleViewLeftAnchor?.isActive = false
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 240.0)
        bubbleWidthAnchor?.isActive = true
        bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        imageLeftAnchor = userImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8.0)
        imageRightAnchor = userImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8.0)
        imageLeftAnchor?.isActive = false
        imageRightAnchor?.isActive = true
        userImageView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        userImageView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        messageTextView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8.0).isActive = true
        messageTextView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        messageTextView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -8.0).isActive = true
        messageTextView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
    }
    
    // MARK: Outgoing Bubble Setup
    
    func setupOutgoingBubble() {
        
        bubbleView.backgroundColor = UIColor.rgb(125, green: 212, blue: 247, alpha: 1)
        
        messageTextView.textColor = UIColor.white
        
        bubbleViewRightAnchor?.isActive = true
        bubbleViewLeftAnchor?.isActive = false
        
        timestampRightAnchor?.isActive = true
        timestampLeftAnchor?.isActive = false
        
        imageLeftAnchor?.isActive = false
        imageRightAnchor?.isActive = true
    }
    
    // MARK: Incoming Bubble Setup
    
    func setupIncomingBubble() {
        
        bubbleView.backgroundColor = UIColor.white
        
        messageTextView.textColor = UIColor.lightGray
        
        bubbleViewRightAnchor?.isActive = false
        bubbleViewLeftAnchor?.isActive = true
        
        timestampRightAnchor?.isActive = false
        timestampLeftAnchor?.isActive = true
        
        imageLeftAnchor?.isActive = true
        imageRightAnchor?.isActive = false
    }
    
    
}


