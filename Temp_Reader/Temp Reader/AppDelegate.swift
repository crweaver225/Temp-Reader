//
//  AppDelegate.swift
//  Temp Reader
//
//  Created by Christopher Weaver on 12/9/17.
//  Copyright © 2017 Christopher Weaver. All rights reserved.
//

import UIKit
import PusherSwift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var pusher: Pusher!
    var keyID : String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       
        
        let sql = SQL()
        
        if  UserDefaults.standard.bool(forKey: "first_time") != true  {
            sql.generateTablesForFirstTime()
            UserDefaults.standard.set(true, forKey: "first_time")
        }
        
        
        let keyIDQuery = "select key_id from limit_values"
        let results = sql.getRows(keyIDQuery, directory: nil)
        
        if !results.isEmpty {
            let result = results[0]
            if let keyIDResult = result["key_id"] as? String{
                
                self.keyID = keyIDResult
            }
        }
        
        let options = PusherClientOptions(
            host: .cluster("us2")
        )
        pusher = Pusher(key: "325f37e004ea9f71daa4", options: options)
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // Handle user allowing / declining notification permission. Example:
            if (granted) {
                
                DispatchQueue.main.async(execute: {
                    application.registerForRemoteNotifications()
                    
                })
            } else {
                print("User declined notification permissions")
            }
        }
        
        let rootViewController = MainViewController()
        
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.tintColor = UIColor.lightGray
        
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken : Data) {
        
        if let keyID = self.keyID {
            pusher.nativePusher.register(deviceToken: deviceToken)
      
            pusher.nativePusher.subscribe(interestName: keyID)
        }
    
    }
    
    private func application(application: UIApplication, didReceiveRemoteNotification notification : [NSObject : AnyObject]) {
        print(notification)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

