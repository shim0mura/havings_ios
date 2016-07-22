//
//  SignupViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/05/21.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var mail: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    let USERNAME_TAG = 1
    let MAIL_TAG = 2
    let PASSWORD_TAG = 3
    
    var isUserNameEmpty :Bool = true
    var isMailEmpty :Bool = true
    var isPasswordEmpty :Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userName.delegate = self
        self.userName.tag = USERNAME_TAG
        self.mail.tag     = MAIL_TAG
        self.password.tag = PASSWORD_TAG
        self.mail.delegate = self
        self.password.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapSignupButton(sender: AnyObject) {
        let validationResult :SessionValueCombination = SessionValueCombination.isValid(userName.text, mail: mail.text, password: password.text)
        
        if validationResult != .Valid{
            let alert :UIAlertController = UIAlertController(title: validationResult.rawValue, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        API.call(Endpoint.Session.Login(mail: mail.text!, password: password.text!)) { response in
            switch response {
            case .Success(let result):
                print("success \(result)")
                print(result.token)
                print(result.uid)
                let tokenManager = TokenManager.sharedManager
                if let token = result.token, let uid = result.uid, let userId = result.id {
                    tokenManager.saveTokenAndUid(token: token, uid: uid, userId: userId)
                }
                
                let storyboard : UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                if let next :UIViewController = storyboard.instantiateInitialViewController() {
                    self.presentViewController(next, animated: true, completion: nil)
                }
            case .Failure(let error):
                print("failure \(error)")
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField.tag {
        case USERNAME_TAG:
            isUserNameEmpty = textField.text?.isEmpty ?? true
            mail.becomeFirstResponder()
        case MAIL_TAG:
            isMailEmpty = textField.text?.isEmpty ?? true
            password.becomeFirstResponder()
        case PASSWORD_TAG:
            isPasswordEmpty = textField.text?.isEmpty ?? true
            tapSignupButton(textField)
        default:
            break;
        }
        return true
    }
    
    @IBAction func loginByTwitter(sender: AnyObject) {
        
    }
    
    @IBAction func test(sender: AnyObject) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Form", bundle: nil)
        let n = storyboard.instantiateViewControllerWithIdentifier("select_list_image") as? ListImagePickupViewController
        if let listImageSelectVC = n {
            listImageSelectVC.listName = "テストのlistName"
            self.presentViewController(listImageSelectVC, animated: true, completion: nil)
        }

        
    }
    
    
}
