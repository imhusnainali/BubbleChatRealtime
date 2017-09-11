//
//  LoginController.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

class LoginController: UITableViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginButton: GradientButton!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: Properties
    
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavBar()
        
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleHideKeyboard)))
    }
    
    // MARK: Setup UI
    
    private func setupUI() {
                
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = loginButton.frame.height/2
    }
    
    // MARK: Setup Navigation Bar
    
    private func setupNavBar() {
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }
    
    // MARK: User Interaction
    
    func handleHideKeyboard() {
        tableView.endEditing(true)
    }
    
    // MARK: Database - Login User
    
    @IBAction func handleLogin(_ sender: UIButton) {
        
        handleHideKeyboard()
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        
        activityIndicator.startAnimating()
        
        NetworkingService.shared.loginAccount(email, password: password) { [weak self] (success) in
            
            guard success else {
                self?.activityIndicator.stopAnimating()
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController else {
                self?.activityIndicator.stopAnimating()
                return
            }
            
            tabBarController.selectedIndex = 3
            
            guard let appKeyWindow = UIApplication.shared.keyWindow else {
                self?.activityIndicator.stopAnimating()
                return
            }
            
            self?.activityIndicator.removeFromSuperview()
            
            NetworkingService.shared.getCurrentUser({ (currentUser) in
                
                let defaults = UserDefaults.standard
                defaults.setValue(currentUser.name, forKey: AppDefaults.kUserNameKey)
                defaults.setValue(currentUser.email, forKey: AppDefaults.kUserEmailKey)
                defaults.setValue(currentUser.picUrl, forKey: AppDefaults.kUserPicUrlKey)
                
                appKeyWindow.rootViewController = tabBarController
            })
   1
        }
    }
    
}
