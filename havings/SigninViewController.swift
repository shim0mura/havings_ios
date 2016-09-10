//
//  SigninViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/08/12.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class SigninViewController: UIViewController, PostAlertUtil {

    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var passowordField: UITextField!
    
    let MAIL_TAG = 2
    let PASSWORD_TAG = 3
    
    var isMailEmpty :Bool = true
    var isPasswordEmpty :Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mailField.tag = MAIL_TAG
        self.passowordField.tag = PASSWORD_TAG
        self.mailField.delegate = self
        self.passowordField.delegate = self
        
        self.mailField.addBottomBorderWithColor(UIColorUtil.borderColor, width: 1)
        self.passowordField.addBottomBorderWithColor(UIColorUtil.borderColor, width: 1)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func tapBack(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func tapSignin(sender: AnyObject) {
        let validationResult: SessionValueCombination = SessionValueCombination.isValidToSignin(mailField.text, password: passowordField.text)
        
        if validationResult != .Valid{
            let alert :UIAlertController = UIAlertController(title: validationResult.rawValue, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        let spinnerAlert = self.showConnectingSpinner()

        API.call(Endpoint.Session.Login(mail: mailField.text!, password: passowordField.text!)) { response in
            switch response {
            case .Success(let result):
                spinnerAlert.dismissViewControllerAnimated(false, completion: nil)

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
                spinnerAlert.dismissViewControllerAnimated(false, completion: nil)
                self.simpleAlertDialog(NSLocalizedString("Prompt.FailureToAceess", comment: ""), message: nil)
            }
        }
    }
    
    @IBAction func twitterSignin(sender: AnyObject) {
    }
    
    @IBAction func facebookSignin(sender: AnyObject) {
    }
    
    @IBAction func instagramSignin(sender: AnyObject) {
    }
    
    @IBAction func hatenaSignin(sender: AnyObject) {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            let next:OAuthViewController = segue.destinationViewController as! OAuthViewController
            let account = OAuthViewController.OAuthAccount(rawValue: identifier)!
            next.account = account
            print(segue.identifier)
        
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension SigninViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField.tag {
        case MAIL_TAG:
            isMailEmpty = textField.text?.isEmpty ?? true
            passowordField.becomeFirstResponder()
        case PASSWORD_TAG:
            isPasswordEmpty = textField.text?.isEmpty ?? true
            tapSignin(textField)
        default:
            break;
        }
        return true
    }
    
}
