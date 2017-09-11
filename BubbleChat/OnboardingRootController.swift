//
//  OnboardingRootController.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

class OnboardingRootController: UIViewController {
    
    // MARK: @IBOutlets
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: GradientButton!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: Properties
    
    var onboardingPageController: OnboardingPageController? {
        didSet {
            onboardingPageController?.onboardingDelegate = self
        }
    }
    
    // MARK: LifeCycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loginButton.alpha = 0.0
        signUpButton.alpha = 0.0
        pageControl.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.6, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.loginButton.alpha = 1.0
            self.signUpButton.alpha = 1.0
            self.pageControl.alpha = 1.0
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.layer.masksToBounds = true
        signUpButton.layer.cornerRadius = signUpButton.frame.height/2
        
        pageControl.addTarget(self, action: #selector(didChangePageControlValue), for: .valueChanged)
    }
    
    // MARK: PrepareForSegue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let onboardingPageController = segue.destination as? OnboardingPageController {
            self.onboardingPageController = onboardingPageController
        }
        
    }
    
    // MARK: Did Change Page Method
    
    func didChangePageControlValue() {
        onboardingPageController?.scrollToViewController(index: pageControl.currentPage)
    }
    
}


// MARK: OnboardingPageControllerDelegate

extension OnboardingRootController: OnboardingPageControllerDelegate {
    
    func onboardingPageController(_ onboardingPageController: OnboardingPageController, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func onboardingPageController(_ onboardingPageController: OnboardingPageController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
    
}
