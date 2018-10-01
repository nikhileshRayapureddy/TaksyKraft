//
//  AppDelegate.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 29/06/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var isServerReachable : Bool = false
    var reachability: Reachability?
    let gcmMessageIDKey = "gcm.notification.data"

    var window: UIWindow?
    var navCtrl = UINavigationController()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        var vc = UIViewController()
        if TaksyKraftUserDefaults.getLoginStatus()
        {
            vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
        }
        else
        {
            vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            navCtrl.isNavigationBarHidden = true
       }
        
        navCtrl = UINavigationController(rootViewController: vc)
        self.window?.rootViewController = navCtrl
        self.window?.backgroundColor = Color_NavBarTint
        IQKeyboardManager.sharedManager().enable = true
        
        
        self.setupReachability(hostName: "", useClosures: true)
        self.startNotifier()
        print("reachable = ",isServerReachable)
        isServerReachable = (reachability?.isReachable)!
        print("reachable after= ",isServerReachable)

        /* FCM Notification
         
        Server Key : 'AAAApHZyuKs:APA91bE6925GxJ-ddKWrPRmawa6vtzhigdWrz0xFcqPnZIJA6rgmm0DGQNNdUTR1sTVV-oHrp5GBAdI88NySielktYJ_-GHFpprqdEoh449qgGSs_DGIemWnIbvjRRZ_RlXjymN_uUM-'
        Web API Key : 'AIzaSyD3oQZWqM86S0v_rQxa27a2kzvhETRwHL4'
        Sender ID : '706361866411'
         
         */
        FirebaseApp.configure()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        let likeAction = UNNotificationAction(identifier: "like", title: "Like", options: [])
        let replyAction = UNNotificationAction(identifier: "reply", title: "Reply", options: [])
        let archiveAction = UNNotificationAction(identifier: "archive", title: "Archive", options: [])
        let  ccommentAction = UNTextInputNotificationAction(identifier: "comment", title: "Comment", options: [])
        
        
        let localCat =  UNNotificationCategory(identifier: "category", actions: [likeAction], intentIdentifiers: [], options: [])
        
        let customCat =  UNNotificationCategory(identifier: "recipe", actions: [likeAction,ccommentAction], intentIdentifiers: [], options: [])
        
        let emailCat =  UNNotificationCategory(identifier: "email", actions: [replyAction, archiveAction], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([localCat, customCat, emailCat])

        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self

        return true
    }

    // MARK: - Notification Delegates
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        // Print full message.
        print(userInfo)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
        
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
        
    }

    // MARK: - Core Data stack

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "TaksyKraft")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if #available(iOS 10.0, *) {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        } else {
            // Fallback on earlier versions
        }

    }
    //MARK:- Loader  methods
    func showLoader(message:String)
    {
        
        
        self.performSelector(onMainThread: #selector(showLoaderr(message:)), with: message, waitUntilDone: false)
        
    }
    
    func showLoaderr(message : String)
    {
        let vwBgg = self.window!.viewWithTag(123453)
        if vwBgg == nil
        {
            let vwBg = UIView( frame:self.window!.frame)
            vwBg.backgroundColor = UIColor.clear
            vwBg.tag = 123453
            self.window!.addSubview(vwBg)
            
            let imgVw = UIImageView (frame: vwBg.frame)
            imgVw.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            vwBg.addSubview(imgVw)
            
            let height = vwBg.frame.size.height/2.0
            
            let lblText = UILabel(frame:CGRect(x: 0, y: height-60, width: vwBg.frame.size.width, height: 30))
            lblText.font = UIFont(name: "OpenSans", size: 17)
            
            if message == ""
            {
                lblText.text =  "Loading ..."
            }
            else
            {
                lblText.text = message
            }
            lblText.textAlignment = NSTextAlignment.center
            lblText.backgroundColor = UIColor.clear
            lblText.textColor =   UIColor.white// Color_AppGreen
            // lblText.textColor = Color_NavBarTint
            vwBg.addSubview(lblText)
            
            let indicator = UIActivityIndicatorView(activityIndicatorStyle:.whiteLarge)
            indicator.center = vwBg.center
            vwBg.addSubview(indicator)
            indicator.startAnimating()
            
            vwBg.addSubview(indicator)
            indicator.bringSubview(toFront: vwBg)
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
        }
    }
    func removeloder()
    {
        self.performSelector(onMainThread:#selector(removeloderr), with: nil, waitUntilDone: false)
    }
    func removeloderr()
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        let vwBg = self.window!.viewWithTag(123453)
        if vwBg != nil
        {
            vwBg!.removeFromSuperview()
        }
        
    }
    // MARK: - Reachability
    
    func setupReachability(hostName: String?, useClosures: Bool) {
        
        let reachabil = hostName == "" ? Reachability() : Reachability(hostname: hostName!)
        reachability = reachabil
        if useClosures {
            reachability?.whenReachable = { reachability in
                DispatchQueue.main.async {
                    self.isServerReachable = true
                }
            }
            reachability?.whenUnreachable = { reachability in
                DispatchQueue.main.async {
                    self.isServerReachable = false
                }
            }
            print("reachable setup = ",isServerReachable)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: reachability)
        }
    }
    
    func startNotifier() {
        print("--- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
            
            return
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        reachability = nil
    }
    func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            isServerReachable = true
        } else {
            isServerReachable = false
        }
    }
    
    deinit {
        stopNotifier()
    }

}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.

        if let data = userInfo[gcmMessageIDKey],let aps = userInfo["aps"] as? [String:AnyObject]{
            
            let alert = aps["alert"] as! [String:AnyObject]
            let title = alert["title"] as! String
            let json = self.convertStringToDictionary(data as! String)
            print("json: \(json)")
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Notification", message: title, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in

                }))
                alert.addAction(UIAlertAction(title: "Go", style: .default, handler: { (action) in
                    DispatchQueue.main.async {
                        if let currVC = self.navCtrl.visibleViewController as? ExpensesViewController
                        {
                            currVC.isFromNotification = true
                            currVC.json = json as AnyObject
                            currVC.reloadVCForNotification()
                        }
                        else
                        {
                            let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExpensesViewController") as! ExpensesViewController
                            vc.isFromNotification = true
                            vc.json = json as AnyObject
                            self.navCtrl.pushViewController(vc, animated: false)
                        }

                    }
                }))

                self.navCtrl.visibleViewController?.present(alert, animated: true, completion: nil)
            }
            

            // Print full message.
            
        }
        // Print full message.
        print(userInfo)
        
        let not = NotificationBO()
        not.value = (userInfo["value"] as? String) ?? ""
        not.id = (userInfo["id"] as? String) ?? ""
        not.body = (userInfo["body"] as? String) ?? ""
        not.image = (userInfo["image"] as? String) ?? ""
        not.date = (userInfo["created"] as? String) ?? ""
        not.comment = (userInfo["comment"] as? String) ?? ""
        not.title = (userInfo["title"] as? String) ?? ""
        not.uuid = (userInfo["uuid"] as? String) ?? ""
        not.type = (userInfo["type"] as? String) ?? ""
        

        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let data = userInfo[gcmMessageIDKey] {
            print("data: \(data)")
            let json = self.convertStringToDictionary(data as! String)
            print("json: \(json)")

            // Print full message.
            let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExpensesViewController") as! ExpensesViewController
            vc.isFromNotification = true
            vc.json = json as AnyObject
            self.navCtrl.pushViewController(vc, animated: false)

        }
//        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExpensesViewController") as! ExpensesViewController
//        vc.isFromNotification = true
//        
//        self.navCtrl.pushViewController(vc, animated: false)

        //called when app is removed from background and we get the alert
        completionHandler()
    }
    func convertStringToDictionary(_ text: String) -> [String:AnyObject] {
        if let data = text.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                return (json as AnyObject) as! [String : AnyObject]
            } catch {
                print("Something went wrong")
            }
        }
        return ["":"" as AnyObject]
    }
    

}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        TaksyKraftUserDefaults.setFCMToken(object: fcmToken)
        if TaksyKraftUserDefaults.getAccessToken() != ""
        {
            let layer = ServiceLayer()
            layer.updateFCMKey(token: fcmToken, successMessage: { (response) in
                DispatchQueue.main.async {
                 print("Updated fcm key in server Successfully")
                    
                }
            }) { (error) in
                DispatchQueue.main.async {
                 print("Failed to update fcm key in server")
                }

            }
        }
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
        
    }
    // [END ios_10_data_message]
}
