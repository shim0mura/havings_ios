//
//  ViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/05/21.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        /*
        API.call(Endpoint.User.Get) { response in
            switch response {
            case .Success(let result):
                print("success \(result)")
                print(result.location)
            case .Failure(let error):
                print("failure \(error)")
            }
        }
        */
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool){
        let tokenManager = TokenManager.sharedManager
        var storyboard : UIStoryboard
        
        if tokenManager.isTokenAndUidSaved() {
            storyboard = UIStoryboard(name: "Home", bundle: nil)
        }else{
            storyboard = UIStoryboard(name: "Signup", bundle: nil)
        }
        
        if let next :UIViewController = storyboard.instantiateInitialViewController() {
            presentViewController(next, animated: true, completion: nil)
        }
    }

}

