//
//  HomeTabViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/08/27.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class HomeTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeTabViewController.handlePushNotification), name: "timer", object: nil)
        
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func handlePushNotification(notification: NSNotification) {

        self.selectedIndex = 0
        if let nav = self.selectedViewController as? UINavigationController, let itemId = notification.userInfo!["itemId"] as? Int {
            let storyboard: UIStoryboard = UIStoryboard(name: "Item", bundle: nil)
            let next: ItemViewController = storyboard.instantiateInitialViewController() as! ItemViewController
            next.itemId = itemId
            nav.pushViewController(next, animated: true)
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0

        }
    }

}
