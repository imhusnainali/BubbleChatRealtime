//
//  AppDelegate.swift
//  BubbleChat
//
//  Created by Aleks on 9/4/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import FirebaseMessaging
import FirebaseInstanceID

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        
        // TODO: Handle notifications for each single conversation, directly in ConversationsController, with the text of all the unread messages in bold, like on Messenger for example.
        // For now, we reset the badge to zero at every fresh launch.
        application.applicationIconBadgeNumber = 0
        
        setupWindow()
        setupNavBar()
        setupTabBar()
        setupAppDefaults()
        setupRootController()
        
        return true
    }

    private func setupRootController() {
        guard Auth.auth().currentUser != nil else {
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            let onboardingController = storyboard.instantiateViewController(withIdentifier: "OnboardingNavigationController") as? UINavigationController
            window?.rootViewController = onboardingController
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController
        homeController?.selectedIndex = 3
        window?.rootViewController = homeController
    }
    
    private func setupWindow() {
        window?.backgroundColor = .white
    }
    
    private func setupNavBar() {
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.lightGray.withAlphaComponent(0.65)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 18.0)!, NSForegroundColorAttributeName: UIColor.darkGray.withAlphaComponent(0.55)]
        let backButtonImage = #imageLiteral(resourceName: "back_arrow").withRenderingMode(.alwaysTemplate).resizableImage(withCapInsets: UIEdgeInsets(top: 3,left: 3,bottom: 3,right: 3), resizingMode: .stretch)
        UINavigationBar.appearance().backIndicatorImage = backButtonImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backButtonImage
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-60, -60), for: .default)
    }
    
    private func setupTabBar() {
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().backgroundColor = UIColor.white
    }

    private func setupAppDefaults() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [AppDefaults.kIsNotificationEnabled: true ])
    }
    
    
    
}

extension AppDelegate : MessagingDelegate {
    
    // MARK: MessagingDelegate
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        NSLog("Did Receive Remote Message: %@", remoteMessage.appData)
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        NSLog("FCM Registration Token Is: %@", fcmToken)
    }
}

