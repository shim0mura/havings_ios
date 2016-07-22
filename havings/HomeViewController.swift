//
//  HomeViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/05/25.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    private var leftBarButton: ENMBadgedBarButtonItem?
    private var count: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        API.call(Endpoint.User.GetSelf) { response in
            switch response {
            case .Success(let result):
                print(result.name)
                print(result.id)
            case .Failure(let error):
                print("failure \(error)")
            }
        }
        

        setUpLeftBarButton()
    }
    
    func setUpLeftBarButton() {
        let image = UIImage(named: "icon_type_item")
        let button = UIButton(type: .Custom)
        button.frame = CGRectMake(0.0, 0.0, 20, 20)
        /*
        if let knownImage = image {
            button.frame = CGRectMake(0.0, 0.0, 20, 20)
        } else {
            button.frame = CGRectZero;
        }*/
        
        button.setBackgroundImage(image, forState: UIControlState.Normal)
        button.addTarget(self,
                         action: #selector(HomeViewController.testtest),
                         forControlEvents: UIControlEvents.TouchUpInside)
        
        let newBarButton = ENMBadgedBarButtonItem(customView: button, value: "\(10)")
        self.leftBarButton = newBarButton
        navigationItem.rightBarButtonItem = self.leftBarButton
    }
    
    func testtest(){
        print("test")
        self.count = self.count + 2
        self.leftBarButton?.badgeValue = "\(count)"
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Notification", bundle: nil)
        let next = storyboard.instantiateInitialViewController()
        self.navigationController?.pushViewController(next!, animated: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapLogout(sender: AnyObject) {
        API.call(Endpoint.Session.SignOut) { response in
            switch response {
            case .Success(let result):
                print("success to logout\(result)")
                
                let tokenManager = TokenManager.sharedManager
                tokenManager.resetTokenAndUid()
                let storyboard : UIStoryboard = UIStoryboard(name: "Signup", bundle: nil)
                if let next :UIViewController = storyboard.instantiateInitialViewController() {
                    self.presentViewController(next, animated: true, completion: nil)
                }
            case .Failure(let error):
                print("failure \(error)")
            }
        }
    }

    @IBAction func toV1(sender: AnyObject) {
        let v1view : UIViewController = FirstViewController()
        self.navigationController?.pushViewController(v1view, animated: true)

    }
    
    @IBAction func toV2(sender: AnyObject) {
        //let v1view : UIViewController = ItemViewController()
        let storyboard: UIStoryboard = UIStoryboard(name: "Item", bundle: nil)
        let next: ItemViewController = storyboard.instantiateInitialViewController() as! ItemViewController
        next.itemId = 2
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    @IBAction func toUser(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
        let next: UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        let nextVC: UserViewController = next.visibleViewController as! UserViewController
        nextVC.userId = 10
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func toDone(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "DoneTasks", bundle: nil)
        let next: DoneTaskViewController = storyboard.instantiateInitialViewController() as! DoneTaskViewController
        next.itemId = 2
        self.navigationController?.pushViewController(next, animated: true)
    }

}
