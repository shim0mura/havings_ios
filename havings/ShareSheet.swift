//
//  ShareSheet.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/08/29.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import UIKit
import Social

protocol ShareSheet {

}

extension ShareSheet where Self: UIViewController {

    func showShareSheet(itemName: String, itemPath: String){
        let alert: UIAlertController = UIAlertController(title:NSLocalizedString("Prompt.Item.Share", comment: ""), message: nil, preferredStyle:  UIAlertControllerStyle.ActionSheet)
        
        let twitterAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Item.Share.Twitter", comment: ""), style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            var composeView : SLComposeViewController!
            composeView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            composeView.setInitialText(itemName + " " + ApiManager.getBaseUrl() + itemPath + " #havings")
            self.presentViewController(composeView, animated: true, completion: nil)
            
        })
        
        let facebookAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Item.Share.Facebook", comment: ""), style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            var composeView : SLComposeViewController!
            composeView = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            composeView.setInitialText(itemName + " " + ApiManager.getBaseUrl() + itemPath + " #havings")
            self.presentViewController(composeView, animated: true, completion: nil)
        })
        
        let lineAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Item.Share.Line", comment: ""), style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            let text: String! = itemName + " " + ApiManager.getBaseUrl() + itemPath
            let encodeMessage: String! = text.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            let messageURL: NSURL = NSURL(string: "line://msg/text/" + encodeMessage)!
            if (UIApplication.sharedApplication().canOpenURL(messageURL)) {
                UIApplication.sharedApplication().openURL( messageURL )
            }
        })
        
        let copyAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Item.Share.Copy", comment: ""), style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            let text: String! = itemName + " " + ApiManager.getBaseUrl() + itemPath
            let board = UIPasteboard.generalPasteboard()
            board.setValue(text, forPasteboardType: "public.text")
            self.view.makeToast(NSLocalizedString("Prompt.Item.Share.Copy.Success", comment: ""))
        })
        
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        alert.addAction(twitterAction)
        alert.addAction(facebookAction)
        alert.addAction(lineAction)
        alert.addAction(copyAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
}
