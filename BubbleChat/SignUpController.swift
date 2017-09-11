//
//  SignUpController.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

class SignUpController: UITableViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var signUpButton: GradientButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailtextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: Properties
    
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavBar()
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowPicker)))
        imageView.isUserInteractionEnabled = true
        
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleHideKeyboard)))
    }
    
    // MARK: Setup UI
    
    private func setupUI() {
        
        signUpButton.layer.masksToBounds = true
        signUpButton.layer.cornerRadius = signUpButton.frame.height/2
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.width/2
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
    
    // MARK: Show Image Picker
    
    func handleShowPicker(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: Database - Register User
    
    @IBAction func handleSignUp(_ sender: UIButton) {
        
        handleHideKeyboard()
        
        guard let email = emailtextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let picture = imageView.image else { return }
        guard let name = nameTextField.text else { return }
        
        activityIndicator.startAnimating()
        
        NetworkingService.shared.createAccount(email, password: password, name: name, completion: { [weak self] (success) in
            
            guard success else {
                self?.activityIndicator.stopAnimating()
                return
            }
            
            NetworkingService.shared.uploadImageToStorage(picture: picture, completion: { (success, picUrl) in
                
                guard success, let picUrl = picUrl else {
                    self?.activityIndicator.stopAnimating()
                    return
                }
                
                NetworkingService.shared.saveAccountDataOnDatabase(email, password: password, name: name, picUrl: picUrl) { (success) in
                    
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
                    
                    let defaults = UserDefaults.standard
                    defaults.setValue(name, forKey: AppDefaults.kUserNameKey)
                    defaults.setValue(email, forKey: AppDefaults.kUserEmailKey)
                    defaults.setValue(picUrl, forKey: AppDefaults.kUserPicUrlKey)

                    NetworkingService.shared.saveTokenToDatabase()
                    
                    appKeyWindow.rootViewController = tabBarController
                }
            })
        })
        
    }
    
}


extension SignUpController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            imageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}





