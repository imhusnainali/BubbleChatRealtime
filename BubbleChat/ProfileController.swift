//
//  ProfileController.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit

class ProfileController: UITableViewController {
    
    // MARK: IBOutlets
    
    // MARK: Properties
    
    // MARK: Private Properties
    
    private var indexPathsArray = [Int:Bool]()
    
    private let profileCellIdentifier = "profileCellIdentifier"
    private let optionCellIdentifier = "optionCellIdentifier"
    private let logoutCellIdentifier = "logoutCellIdentifier"
    private let switchCellIdentifier = "switchCellIdentifier"
    
    // MARK: LifeCycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ProfileTableCell", bundle: nil), forCellReuseIdentifier: profileCellIdentifier)
        
        tableView.register(UINib(nibName: "OptionTableCell", bundle: nil), forCellReuseIdentifier: optionCellIdentifier)
        
        tableView.register(UINib(nibName: "LogoutTableCell", bundle: nil), forCellReuseIdentifier: logoutCellIdentifier)
        
        tableView.register(UINib(nibName: "SwitchTableCell", bundle: nil), forCellReuseIdentifier: switchCellIdentifier)
        
    }
    
    // MARK: Memory Warning
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        NetworkingService.shared.lastMessages.removeAll(keepingCapacity: false)
        NetworkingService.shared.users.removeAll(keepingCapacity: false)
        NetworkingService.shared.messages.removeAll(keepingCapacity: false)
        NetworkingService.shared.notifications.removeAll(keepingCapacity: false)
        
        AsyncImageLoadingManager.shared.emptyAllCache()
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 250.0
        } else if indexPath.row == 4 {
            return 130
        } else {
            return 50.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            
        case 0:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: profileCellIdentifier, for: indexPath) as! ProfileTableCell
            
            let defaults = UserDefaults.standard
            
            if let userName = defaults.string(forKey: AppDefaults.kUserNameKey), let userPicUrl = defaults.string(forKey: AppDefaults.kUserPicUrlKey) {
                                
                cell.userNameLabel.text = userName
                
                AsyncImageLoadingManager.shared.loadImageAsyncFromUrl(urlString: userPicUrl, completion: { (success, image) in
                    if success && image != nil {
                        cell.userImageView.image = image
                    }
                })
                
            } else {
                
                NetworkingService.shared.getCurrentUser({ (currentUser) in
                    
                    cell.userNameLabel.text = currentUser.name
                    defaults.setValue(currentUser.name, forKey: AppDefaults.kUserNameKey)
                    defaults.setValue(currentUser.email, forKey: AppDefaults.kUserEmailKey)

                    AsyncImageLoadingManager.shared.loadImageAsyncFromUrl(urlString: currentUser.picUrl, completion: { (success, image) in
                        if success && image != nil {
                            cell.userImageView.image = image
                            defaults.setValue(currentUser.picUrl, forKey: AppDefaults.kUserPicUrlKey)
                        }
                    })
                })
            }
            
            cell.addButton.addTarget(self, action: #selector(handleShowPicker), for: .touchUpInside)
            cell.userImageView.isUserInteractionEnabled = true
            cell.userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowPicker)))
            
            return cell
            
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: optionCellIdentifier, for: indexPath) as! OptionTableCell
            
            cell.titleLabel.text = "Name"
            
            let defaults = UserDefaults.standard
            
            if let userName = defaults.string(forKey: AppDefaults.kUserNameKey) {
                
                cell.subtitleLabel.text = userName
                
            } else {
                
                NetworkingService.shared.getCurrentUser({ (currentUser) in
                    cell.subtitleLabel.text = currentUser.name
                    defaults.setValue(currentUser.name, forKey: AppDefaults.kUserNameKey)
                })
                
            }
            
            return cell
            
            
        case 2:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: optionCellIdentifier, for: indexPath) as! OptionTableCell
            
            cell.titleLabel.text = "Email"
            
            let defaults = UserDefaults.standard
            
            if let userEmail = defaults.string(forKey: AppDefaults.kUserEmailKey) {
                
                cell.subtitleLabel.text = userEmail
                
            } else {
                
                NetworkingService.shared.getCurrentUser({ (currentUser) in
                    cell.subtitleLabel.text = currentUser.email
                    defaults.setValue(currentUser.email, forKey: AppDefaults.kUserEmailKey)
                })
        
            }
            
            return cell
            
        case 3:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: switchCellIdentifier, for: indexPath) as! SwitchTableCell
           
            let defaults = UserDefaults.standard
    
            cell.titleLabel.text = "Notifications"
            cell.switchControl.isOn = defaults.bool(forKey: AppDefaults.kIsNotificationEnabled)
            
            return cell
            
        case 4:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: logoutCellIdentifier, for: indexPath) as! LogoutTableCell
            cell.button.setTitle("Logout", for: .normal)
            cell.button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
            return cell
            
        default: fatalError("This row doesn't exist")
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPathsArray[indexPath.row] == nil {
            
            cell.alpha = 0.0
            
            UIView.animate(withDuration: 0.5, animations: {
                cell.alpha = 1.0
            })
            
        }
        
        if indexPathsArray[indexPath.row] == nil {
            indexPathsArray[indexPath.row] = true
        }
    }
    
    // MARK: PrepareForSegue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ProfilePreviewController" {
            
            guard let destinationController = segue.destination as? ProfilePreviewController else {
                return
            }
            
            destinationController.hidesBottomBarWhenPushed = true
        }
        
    }

    // MARK: Show Image Picker
    
    func handleShowPicker(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: Database - Logout
    
    func handleLogout() {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let logoutAction = UIAlertAction(title: "Logout", style: .default) { (action) in
            
            guard let appKeyWindow = UIApplication.shared.keyWindow else {
                return
            }
            
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            let onboardingController = storyboard.instantiateViewController(withIdentifier: "OnboardingNavigationController") as? UINavigationController
            appKeyWindow.rootViewController = onboardingController
            
            NetworkingService.shared.logoutAccount()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        actionSheet.addAction(logoutAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
}


extension ProfileController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
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
            
            guard let profileImageCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileTableCell else {
                return
            }

            profileImageCell.activityIndicator.startAnimating()
   
            NetworkingService.shared.updateCurrentUserImage(selectedImage, completion: { (success) in
                
                guard success else {
                    return
                }
                
                profileImageCell.activityIndicator.stopAnimating()
                profileImageCell.userImageView.image = selectedImage
            })
        
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}







