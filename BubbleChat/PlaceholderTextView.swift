//
//  PlaceholderTextView.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

class PlaceholderTextView: UITextView {
    
    // MARK: Properties
    
    weak var placeholderDelegate: PlaceholderTextViewDelegate?
    
    var placeholder: String? {
        didSet {
            placeholderLabel?.text = placeholder
            setNeedsLayout()
        }
    }
    
    var placeholderColor = UIColor.lightGray.withAlphaComponent(0.75)
    
    var placeholderFont = UIFont.systemFont(ofSize: 16.5) {
        didSet {
            placeholderLabel?.font = placeholderFont
        }
    }
    
    // MARK: Private Properties

    private var placeholderLabel: UILabel?
    
    // MARK: Initializers
    
    init() {
        super.init(frame: CGRect.zero, textContainer: nil)
        awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(PlaceholderTextView.textDidChangeHandler(notification:)), name: .UITextViewTextDidChange, object: nil)
        
        placeholderLabel = UILabel()
        placeholderLabel?.textColor = placeholderColor
        placeholderLabel?.text = placeholder
        placeholderLabel?.textAlignment = .left
        placeholderLabel?.numberOfLines = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        placeholderLabel?.font = placeholderFont
        
        var height:CGFloat = placeholderFont.lineHeight
       
        if let placeholderText = placeholderLabel?.text {
            
            let defaultWidth = bounds.size.width
            
            let textView = UITextView()
            textView.text = placeholderText
            textView.font = UIFont.systemFont(ofSize: 16.5)
            let textViewSize = textView.sizeThatFits(CGSize(width: defaultWidth,
                                                               height: CGFloat.greatestFiniteMagnitude))
            let expectedHeight = textViewSize.height
            
            if expectedHeight > height {
                height = expectedHeight
            }
        }
        placeholderLabel?.frame = CGRect(x: 8, y: 0, width: bounds.size.width - 5, height: height)
        
        if text.isEmpty {
            addSubview(placeholderLabel!)
            bringSubview(toFront: placeholderLabel!)
        } else {
            placeholderLabel?.removeFromSuperview()
        }
    }
    
    // MARK: Notification Handler
    
    func textDidChangeHandler(notification: Notification) {
        layoutSubviews()
    }
    
}

extension PlaceholderTextView : UITextViewDelegate {
    
    // MARK: UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderDelegate?.placeholderTextViewDidChangeText(textView.text)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderDelegate?.placeholderTextViewDidEndEditing(textView.text)
    }
}
