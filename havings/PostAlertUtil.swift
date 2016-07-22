//
//  PostAlertUtil.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/30.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import UIKit

protocol PostAlertUtil {
    
}

extension PostAlertUtil where Self: UIViewController {

    func showConnectingSpinner() -> UIAlertController{
        let spinnerAlert = UIAlertController(title: nil, message: NSLocalizedString("Prompt.WaitForPost", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        
        let spinnerIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        
        spinnerIndicator.center = CGPointMake(135.0, 65.5)
        spinnerIndicator.color = UIColor.blackColor()
        spinnerIndicator.startAnimating()
        
        spinnerAlert.view.addSubview(spinnerIndicator)
        self.presentViewController(spinnerAlert, animated: false, completion: nil)
        return spinnerAlert
    }
    
    func simpleAlertDialog(title: String, message: String?){
        let alert :UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(defaultAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showFailedAlert(errors: Dictionary<String, AnyObject>){
        let keys = errors.keys.sort()
        var alertTitle = NSLocalizedString("Prompt.FailureToAceess", comment: "")
        if !keys.isEmpty {
            let key: String = keys.first!
            let errorMessages = errors[key] as! [String]
            if let message = errorMessages.first {
                alertTitle = "\(key)\(message)"
            }
        }
        self.simpleAlertDialog(alertTitle, message: nil)
    }

}