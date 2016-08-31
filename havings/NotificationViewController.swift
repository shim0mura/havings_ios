//
//  NotificationViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/16.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class NotificationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let textViewTag: Int = 10
    private let iconImageTag: Int = 11
    
    private let maxActer = 3
    
    private var beforeLoad: Bool = true
    var notifications: [NotificationEntity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        
        self.tableView.estimatedRowHeight = 40
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        API.callArray(Endpoint.Notification.GetNotification) { response in
            self.beforeLoad = false
            switch response {
            case .Success(let result):
                self.notifications = result
                self.tableView.reloadData()
                
            case .Failure(let error):
                print("failure \(error)")
            }
        }
        
        API.call(Endpoint.Notification.ReadNotification){ response in
            switch response {
            case .Success(let result):
                print(result)
            case .Failure(let error):
                print("failure \(error)")
            }
        }
        
        self.title = NSLocalizedString("Prompt.Notification.Notification", comment: "")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.beforeLoad {
            return 1
        }else{
            return self.notifications.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if self.beforeLoad{
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("loading")! as UITableViewCell
            return cell
        }else{
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("notification")! as UITableViewCell
            //let cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")

            let textview: UITextView = cell.viewWithTag(self.textViewTag) as! UITextView
            textview.delegate = self
            let icon: UIImageView = cell.viewWithTag(self.iconImageTag) as! UIImageView

            let defaultAttr = [
                NSForegroundColorAttributeName: UIColor.darkTextColor(),
                NSFontAttributeName: UIFont.systemFontOfSize(15)
            ]
            
            let notification = self.notifications[indexPath.row]
            let result = NSMutableAttributedString()
            let type = notification.type!
            
            if notification.unread == true {
                cell.backgroundColor = UIColorUtil.unreadColor
            }else{
                cell.backgroundColor = UIColor.whiteColor()
            }
            
            switch type {
                
            case .Timer:
                let acters: Int = (notification.acterTimers?.count > self.maxActer) ? self.maxActer : notification.acterTimers!.count
                icon.image = UIImage(named: "ic_alarm_light_gray_18dp")
                
                let item = notification.targetItems![0]
                let itemStr = NSMutableAttributedString(string: item.name!, attributes: defaultAttr)
                itemStr.addAttribute(NSLinkAttributeName, value: "havings://item/\(item.id!)", range: NSMakeRange(0, itemStr.length))
                result.appendAttributedString(itemStr)
                let task = NSMutableAttributedString(string: NSLocalizedString("Prompt.Notifications.Timer.Item", comment: ""), attributes: defaultAttr)
                result.appendAttributedString(task)
                
                for i in 0..<acters {
                    
                    let u = notification.acterTimers![i]
                    let tapStr = NSMutableAttributedString(string: u.name!, attributes: defaultAttr)
                    tapStr.addAttribute(NSLinkAttributeName, value: "havings://item/\(item.id!)", range: NSMakeRange(0, tapStr.length))
                    result.appendAttributedString(tapStr)
                    
                    if (i < acters - 1) && (acters > 0) {
                        let normalStr = NSMutableAttributedString(string: ", ", attributes: defaultAttr)
                        result.appendAttributedString(normalStr)
                    }
                    
                }
                
                if notification.acterTimers!.count > self.maxActer {
                    let others = String(format: NSLocalizedString("Unit.GeneralItems.Others", comment: ""), notification.acterTimers!.count - self.maxActer)
                    result.appendAttributedString(NSMutableAttributedString(string: others, attributes: defaultAttr))
                }
                
                let expire = NSMutableAttributedString(string: NSLocalizedString("Prompt.Notifications.Timer.Expire", comment: ""), attributes: defaultAttr)
                result.appendAttributedString(expire)
                
                textview.attributedText = result
                
            case .Favorite:
                let acters: Int = (notification.acterUsers?.count > self.maxActer) ? self.maxActer : notification.acterUsers!.count
                icon.image = UIImage(named: "ic_favorite_pink_300_36dp")
                
                for i in 0..<acters {
                    
                    let u = notification.acterUsers![i]
                    let tapStr = NSMutableAttributedString(string: u.name!, attributes: defaultAttr)
                    tapStr.addAttribute(NSLinkAttributeName, value: "havings://user/\(u.id!)", range: NSMakeRange(0, tapStr.length))
                    result.appendAttributedString(tapStr)
                    
                    var honorific = NSLocalizedString("Prompt.User.Honorific", comment: "")
                    if (i < acters - 1) && (acters > 0) {
                        honorific = honorific + ", "
                    }
                    
                    let normalStr = NSMutableAttributedString(string: honorific, attributes: defaultAttr)
                    result.appendAttributedString(normalStr)
                    
                }
                
                if notification.acterUsers?.count > self.maxActer {
                    let others = String(format: NSLocalizedString("Prompt.User.Honorific.Others", comment: ""), notification.acterUsers!.count - self.maxActer)
                    result.appendAttributedString(NSMutableAttributedString(string: others, attributes: defaultAttr))
                }
                
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Notifications.Act", comment: ""), attributes: defaultAttr))
                
                let item = notification.targetItems![0]
                let itemStr = NSMutableAttributedString(string: item.name!, attributes: defaultAttr)
                itemStr.addAttribute(NSLinkAttributeName, value: "havings://item/\(item.id!)", range: NSMakeRange(0, itemStr.length))
                result.appendAttributedString(itemStr)
                
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Notifications.Favorite.Favorite", comment: ""), attributes: defaultAttr))
                
                textview.attributedText = result
                
                
            case .ImageFavorite:
                let acters: Int = (notification.acterUsers?.count > self.maxActer) ? self.maxActer : notification.acterUsers!.count
                icon.image = UIImage(named: "ic_favorite_pink_300_36dp")
                
                for i in 0..<acters {
                    
                    let u = notification.acterUsers![i]
                    let tapStr = NSMutableAttributedString(string: u.name!, attributes: defaultAttr)
                    tapStr.addAttribute(NSLinkAttributeName, value: "havings://user/\(u.id!)", range: NSMakeRange(0, tapStr.length))
                    result.appendAttributedString(tapStr)
                    
                    var honorific = NSLocalizedString("Prompt.User.Honorific", comment: "")
                    if (i < acters - 1) && (acters > 0) {
                        honorific = honorific + ", "
                    }
                    
                    let normalStr = NSMutableAttributedString(string: honorific, attributes: defaultAttr)
                    result.appendAttributedString(normalStr)
                    
                }
                
                if notification.acterUsers?.count > self.maxActer {
                    let others = String(format: NSLocalizedString("Prompt.User.Honorific.Others", comment: ""), notification.acterUsers!.count - self.maxActer)
                    result.appendAttributedString(NSMutableAttributedString(string: others, attributes: defaultAttr))
                }
                
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Notifications.Act", comment: ""), attributes: defaultAttr))
                
                let image = notification.targetItemImages![0]
                let itemStr = NSMutableAttributedString(string: image.itemName!, attributes: defaultAttr)
                itemStr.addAttribute(NSLinkAttributeName, value: "havings://item/\(image.itemId!)", range: NSMakeRange(0, itemStr.length))
                result.appendAttributedString(itemStr)
                
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Notifications.ImageFavorite.Favorite", comment: ""), attributes: defaultAttr))
                
                textview.attributedText = result
                
            case .Comment:
                let acters: Int = (notification.acterUsers?.count > self.maxActer) ? self.maxActer : notification.acterUsers!.count
                icon.image = UIImage(named: "ic_chat_bubble_yellow_400_36dp")
                
                for i in 0..<acters {
                    
                    let u = notification.acterUsers![i]
                    let tapStr = NSMutableAttributedString(string: u.name!, attributes: defaultAttr)
                    tapStr.addAttribute(NSLinkAttributeName, value: "havings://user/\(u.id!)", range: NSMakeRange(0, tapStr.length))
                    result.appendAttributedString(tapStr)
                    
                    var honorific = NSLocalizedString("Prompt.User.Honorific", comment: "")
                    if (i < acters - 1) && (acters > 0) {
                        honorific = honorific + ", "
                    }
                    
                    let normalStr = NSMutableAttributedString(string: honorific, attributes: defaultAttr)
                    result.appendAttributedString(normalStr)
                    
                }
                
                if notification.acterUsers?.count > self.maxActer {
                    let others = String(format: NSLocalizedString("Prompt.User.Honorific.Others", comment: ""), notification.acterUsers!.count - self.maxActer)
                    result.appendAttributedString(NSMutableAttributedString(string: others, attributes: defaultAttr))
                }
                
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Notifications.Act", comment: ""), attributes: defaultAttr))
                
                let item = notification.targetItems![0]
                let itemStr = NSMutableAttributedString(string: item.name!, attributes: defaultAttr)
                itemStr.addAttribute(NSLinkAttributeName, value: "havings://item/\(item.id!)", range: NSMakeRange(0, itemStr.length))
                result.appendAttributedString(itemStr)
                
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Notifications.Comment", comment: ""), attributes: defaultAttr))
                
                textview.attributedText = result
                
            case .Follow:
                let acters: Int = (notification.acterUsers?.count > self.maxActer) ? self.maxActer : notification.acterUsers!.count
                icon.image = UIImage(named: "ic_person_add_green_400_36dp")
                
                for i in 0..<acters {
                    
                    let u = notification.acterUsers![i]
                    let tapStr = NSMutableAttributedString(string: u.name!, attributes: defaultAttr)
                    tapStr.addAttribute(NSLinkAttributeName, value: "havings://user/\(u.id!)", range: NSMakeRange(0, tapStr.length))
                    result.appendAttributedString(tapStr)
                    
                    var honorific = NSLocalizedString("Prompt.User.Honorific", comment: "")
                    if (i < acters - 1) && (acters > 0) {
                        honorific = honorific + ", "
                    }
                    
                    let normalStr = NSMutableAttributedString(string: honorific, attributes: defaultAttr)
                    result.appendAttributedString(normalStr)
                    
                }
                
                if notification.acterUsers?.count > self.maxActer {
                    let others = String(format: NSLocalizedString("Prompt.User.Honorific.Others", comment: ""), notification.acterUsers!.count - self.maxActer)
                    result.appendAttributedString(NSMutableAttributedString(string: others, attributes: defaultAttr))
                }
                
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Notifications.Follow.You", comment: ""), attributes: defaultAttr))
                
                textview.attributedText = result
                
                
            default:
                break
            }
            
            /*
            let tapStr = NSMutableAttributedString(string: "tappable")
            tapStr.addAttribute(NSLinkAttributeName, value: "hjlkfsjhlafsffa", range: NSMakeRange(0, 3))
            let normalStr = NSMutableAttributedString(string: " normal\n normal\n sssss\n fff")
            
            result.appendAttributedString(tapStr)
            result.appendAttributedString(normalStr)
            
            textview.attributedText = result
            */
            
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
}

extension NotificationViewController: UITextViewDelegate {

    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        let str = URL.absoluteString
        let rep = ""
        
        let regexUser: NSRegularExpression
        let regexItem: NSRegularExpression
        do {
            let patternUser = "havings://user/"
            regexUser = try NSRegularExpression(pattern: patternUser, options: [])
            let patternItem = "havings://item/"
            regexItem = try NSRegularExpression(pattern: patternItem, options: [])

            let convertedUser = regexUser.stringByReplacingMatchesInString(str, options: [], range: NSMakeRange(0, str.characters.count), withTemplate: rep)
            let convertedItem = regexItem.stringByReplacingMatchesInString(str, options: [], range: NSMakeRange(0, str.characters.count), withTemplate: rep)
            
            if let userId = Int(convertedUser) {
                print("userId: \(userId)")
                let storyboard: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
                let next: UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
                let nextVC: UserViewController = next.visibleViewController as! UserViewController
                nextVC.userId = userId
                self.navigationController?.pushViewController(nextVC, animated: true)
            }else if let itemId = Int(convertedItem){
                print("itemId: \(itemId)")
                let storyboard: UIStoryboard = UIStoryboard(name: "Item", bundle: nil)
                let next: ItemViewController = storyboard.instantiateInitialViewController() as! ItemViewController
                next.itemId = itemId
                self.navigationController?.pushViewController(next, animated: true)
            }
            
        } catch let error as NSError {
            print(error)
        }

        return false
    }
    
}

extension NotificationViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "icon_type_item")
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text: String = NSLocalizedString("Prompt.Notifications.Empty", comment: "")
        
        let font = UIFont.systemFontOfSize(16)
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName : UIColor.darkGrayColor()])
    }
}