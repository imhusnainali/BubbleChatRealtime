//
//  Protocols.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

protocol PlaceholderTextViewDelegate: class {
    func placeholderTextViewDidChangeText(_ text:String)
    func placeholderTextViewDidEndEditing(_ text:String)
}

protocol OnboardingPageControllerDelegate: class {
    func onboardingPageController(_ onboardingPageController: OnboardingPageController, didUpdatePageCount count: Int)
    func onboardingPageController(_ onboardingPageController: OnboardingPageController, didUpdatePageIndex index: Int)
}
