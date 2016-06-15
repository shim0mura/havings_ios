//
//  HomeViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/05/25.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        API.call(Endpoint.User.Get) { response in
            switch response {
            case .Success(let result):
                print(result.name)
                print(result.id)
            case .Failure(let error):
                print("failure \(error)")
            }
        }
        
        // Do any additional setup after loading the view.
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
        let next: UIViewController = storyboard.instantiateInitialViewController()!
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
