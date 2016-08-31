//
//  AppDelegate.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/05/21.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import Kingfisher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let downloader = KingfisherManager.sharedManager.downloader
        downloader.trustedHosts = Set(["havings.com"])

        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barTintColor = UIColorUtil.darkMainColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        UITabBar.appearance().translucent = false
        UITabBar.appearance().barTintColor = UIColorUtil.darkMainColor
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("deviceToken = \(deviceToken)")
        
        let tokenManager = TokenManager.sharedManager

        if let token = tokenManager.getDeviceToken() {
            
            let currentToken: String = String(deviceToken)
            
            if token.isEmpty {
                print("device token not detected")
                print(deviceToken)
                
                let tokenEntity = DeviceTokenEntity()
                tokenEntity.token = String(deviceToken)
                API.call(Endpoint.DeviceToken.Post(tokenEntity: tokenEntity)){ response in
                    switch response {
                    case .Success( _):
                        tokenManager.setDeviceToken(tokenEntity.token!)
                    case .Failure(let error):
                        print("post failed")
                        print(error)
                    }
                }
            
            }else{
                
                print("device token detected")
                print(token)
                print(currentToken)
                
                if token != currentToken {
                    let tokenEntity = DeviceTokenEntity()
                    tokenEntity.token = currentToken
                    API.call(Endpoint.DeviceToken.Update(tokenEntity: tokenEntity)){ response in
                        switch response {
                        case .Success( _):
                            tokenManager.setDeviceToken(tokenEntity.token!)
                        case .Failure(let error):
                            print("failed")
                            print(error)
                        }
                    }
                }
            }
            
        }
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to get token, error: \(error)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
                
        switch application.applicationState {
        case .Inactive:
            if let id = userInfo["item"] {
                print(id)
                let itemId = id as! Int
                let notification = NSNotification(
                    name:"timer",
                    object: nil,
                    userInfo:[
                        "itemId": itemId,
                    ]
                )
                    
                NSNotificationCenter.defaultCenter().postNotification(notification)
            }
            
            break
        case .Active:
            // アプリ起動時にPush通知を受信したとき
            break
        case .Background:
            // アプリがバックグラウンドにいる状態でPush通知を受信したとき
            break
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension UITableView {
    func reloadData(completion: ()->()) {
        UIView.animateWithDuration(0, animations: { self.reloadData() })
        { _ in completion() }
    }
}

