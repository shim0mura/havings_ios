//
//  TimelineViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/20.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import GoogleMobileAds


class TimelineViewController: UIViewController, BannerUtil {

    private let textViewTag: Int = 10
    private let iconImageTag: Int = 11
    private let targetThumbnailTag: Int = 12
    private let targetNameTag: Int = 13
    
    private let maxActer = 3
    private var beforeLoad: Bool = true
    private var isLoading: Bool = false
    private var timelineEntity: TimelineEntity = TimelineEntity()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        self.tableView.estimatedRowHeight = 40
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.timelineEntity.getNextTimeline(0, callback: {_ in
            self.beforeLoad = false
            self.tableView.reloadData()
        })
        
        self.title = NSLocalizedString("Prompt.Timeline", comment: "")
        self.tableView.tableFooterView = UIView()
        
        showAd(bannerView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension TimelineViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.beforeLoad {
            return 1
        }else{
            return self.timelineEntity.timeline?.count ?? 0
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
            
            let notification = self.timelineEntity.timeline![indexPath.row]
            let result = NSMutableAttributedString()
            let type = notification.type!
            
            switch type {
                
            case .Favorite:
                icon.image = UIImage(named: "ic_favorite_pink_300_36dp")
                
                guard let acter = notification.acterUsers?.first, let target = notification.targetItems?.first else {
                    cell.hidden = true
                    return cell
                }
                
                let tapStr = NSMutableAttributedString(string: acter.name!, attributes: defaultAttr)
                tapStr.addAttribute(NSLinkAttributeName, value: "havings://user/\(acter.id!)", range: NSMakeRange(0, tapStr.length))
                result.appendAttributedString(tapStr)
                
                let normalStr = NSMutableAttributedString(string: NSLocalizedString("Prompt.User.Honorific", comment: ""), attributes: defaultAttr)
                result.appendAttributedString(normalStr)
                
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Notifications.Act", comment: ""), attributes: defaultAttr))
                
                let targetStr = NSMutableAttributedString(string: target.name!, attributes: defaultAttr)
                targetStr.addAttribute(NSLinkAttributeName, value: "havings://item/\(target.id!)", range: NSMakeRange(0, targetStr.length))
                result.appendAttributedString(targetStr)
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Timeline.Favorite", comment: ""), attributes: defaultAttr))

                textview.attributedText = result

            case .ImageFavorite:
                icon.image = UIImage(named: "ic_favorite_pink_300_36dp")
                
                guard let acter = notification.acterUsers?.first, let target = notification.targetItemImages?.first else {
                    cell.hidden = true
                    return cell
                }
                
                let tapStr = NSMutableAttributedString(string: acter.name!, attributes: defaultAttr)
                tapStr.addAttribute(NSLinkAttributeName, value: "havings://user/\(acter.id!)", range: NSMakeRange(0, tapStr.length))
                result.appendAttributedString(tapStr)
                
                let normalStr = NSMutableAttributedString(string: NSLocalizedString("Prompt.User.Honorific", comment: ""), attributes: defaultAttr)
                result.appendAttributedString(normalStr)
                
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Notifications.Act", comment: ""), attributes: defaultAttr))
                
                let targetStr = NSMutableAttributedString(string: target.itemName!, attributes: defaultAttr)
                targetStr.addAttribute(NSLinkAttributeName, value: "havings://item/\(target.itemId!)", range: NSMakeRange(0, targetStr.length))
                result.appendAttributedString(targetStr)
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Timeline.ImageFavorite", comment: ""), attributes: defaultAttr))
                
                textview.attributedText = result

            case .Comment:
                icon.image = UIImage(named: "ic_chat_bubble_yellow_400_36dp")
                
                guard let acter = notification.acterUsers?.first, let target = notification.targetItems?.first else {
                    cell.hidden = true
                    return cell
                }
                
                let tapStr = NSMutableAttributedString(string: acter.name!, attributes: defaultAttr)
                tapStr.addAttribute(NSLinkAttributeName, value: "havings://user/\(acter.id!)", range: NSMakeRange(0, tapStr.length))
                result.appendAttributedString(tapStr)
                
                let normalStr = NSMutableAttributedString(string: NSLocalizedString("Prompt.User.Honorific", comment: ""), attributes: defaultAttr)
                result.appendAttributedString(normalStr)
                
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Notifications.Act", comment: ""), attributes: defaultAttr))
                
                let targetStr = NSMutableAttributedString(string: target.name!, attributes: defaultAttr)
                targetStr.addAttribute(NSLinkAttributeName, value: "havings://item/\(target.id!)", range: NSMakeRange(0, targetStr.length))
                result.appendAttributedString(targetStr)
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Timeline.Comment", comment: ""), attributes: defaultAttr))
                
                textview.attributedText = result
                
            case .Follow:
                icon.image = UIImage(named: "ic_person_add_green_400_36dp")
                
                guard let acter = notification.acterUsers?.first, let target = notification.targetUsers?.first else {
                    cell.hidden = true
                    return cell
                }
                
                let tapStr = NSMutableAttributedString(string: acter.name!, attributes: defaultAttr)
                tapStr.addAttribute(NSLinkAttributeName, value: "havings://user/\(acter.id!)", range: NSMakeRange(0, tapStr.length))
                result.appendAttributedString(tapStr)
                
                let normalStr = NSMutableAttributedString(string: NSLocalizedString("Prompt.User.Honorific", comment: ""), attributes: defaultAttr)
                result.appendAttributedString(normalStr)
                
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Notifications.Act", comment: ""), attributes: defaultAttr))
                
                let targetStr = NSMutableAttributedString(string: target.name!, attributes: defaultAttr)
                targetStr.addAttribute(NSLinkAttributeName, value: "havings://user/\(target.id!)", range: NSMakeRange(0, targetStr.length))
                result.appendAttributedString(targetStr)
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Timeline.Follow", comment: ""), attributes: defaultAttr))
                textview.attributedText = result

                
            case .CreateItem:
                icon.image = UIImage(named: "ic_add_item_36dp")
                
                guard let acter = notification.acterUsers?.first, let target = notification.targetItems?.first else {
                    cell.hidden = true
                    return cell
                }
                
                let tapStr = NSMutableAttributedString(string: acter.name!, attributes: defaultAttr)
                tapStr.addAttribute(NSLinkAttributeName, value: "havings://user/\(acter.id!)", range: NSMakeRange(0, tapStr.length))
                result.appendAttributedString(tapStr)
                
                let normalStr = NSMutableAttributedString(string: NSLocalizedString("Prompt.User.Honorific", comment: ""), attributes: defaultAttr)
                result.appendAttributedString(normalStr)
                
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Notifications.Act", comment: ""), attributes: defaultAttr))
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Timeline.CreateItem.Item", comment: ""), attributes: defaultAttr))

                let targetStr = NSMutableAttributedString(string: target.name!, attributes: defaultAttr)
                targetStr.addAttribute(NSLinkAttributeName, value: "havings://item/\(target.id!)", range: NSMakeRange(0, targetStr.length))
                result.appendAttributedString(targetStr)
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Timeline.CreateItem", comment: ""), attributes: defaultAttr))
                
                textview.attributedText = result
                
            case .CreateList:
                icon.image = UIImage(named: "ic_add_list_36dp")
                
                guard let acter = notification.acterUsers?.first, let target = notification.targetItems?.first else {
                    cell.hidden = true
                    return cell
                }
                
                let tapStr = NSMutableAttributedString(string: acter.name!, attributes: defaultAttr)
                tapStr.addAttribute(NSLinkAttributeName, value: "havings://user/\(acter.id!)", range: NSMakeRange(0, tapStr.length))
                result.appendAttributedString(tapStr)
                
                let normalStr = NSMutableAttributedString(string: NSLocalizedString("Prompt.User.Honorific", comment: ""), attributes: defaultAttr)
                result.appendAttributedString(normalStr)
                
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Notifications.Act", comment: ""), attributes: defaultAttr))
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Timeline.CreateList.List", comment: ""), attributes: defaultAttr))
                
                textview.attributedText = result
                
                let targetStr = NSMutableAttributedString(string: target.name!, attributes: defaultAttr)
                targetStr.addAttribute(NSLinkAttributeName, value: "havings://item/\(target.id!)", range: NSMakeRange(0, targetStr.length))
                result.appendAttributedString(targetStr)
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Timeline.CreateList", comment: ""), attributes: defaultAttr))

                textview.attributedText = result
                
            case .Dump:
                icon.image = UIImage(named: "ic_dump_36dp")
                
                guard let acter = notification.acterUsers?.first, let target = notification.targetItems?.first else {
                    cell.hidden = true
                    return cell
                }
                
                let tapStr = NSMutableAttributedString(string: acter.name!, attributes: defaultAttr)
                tapStr.addAttribute(NSLinkAttributeName, value: "havings://user/\(acter.id!)", range: NSMakeRange(0, tapStr.length))
                result.appendAttributedString(tapStr)
                
                let normalStr = NSMutableAttributedString(string: NSLocalizedString("Prompt.User.Honorific", comment: ""), attributes: defaultAttr)
                result.appendAttributedString(normalStr)
                
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Notifications.Act", comment: ""), attributes: defaultAttr))
                
                let targetStr = NSMutableAttributedString(string: target.name!, attributes: defaultAttr)
                targetStr.addAttribute(NSLinkAttributeName, value: "havings://item/\(target.id!)", range: NSMakeRange(0, targetStr.length))
                result.appendAttributedString(targetStr)
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Timeline.Dump", comment: ""), attributes: defaultAttr))
                textview.attributedText = result
                
            case .AddImage:
                icon.image = UIImage(named: "ic_photo_36dp")
                
                guard let acter = notification.acterUsers?.first, let target = notification.targetItemImages?.first else {
                    cell.hidden = true
                    return cell
                }
                
                let tapStr = NSMutableAttributedString(string: acter.name!, attributes: defaultAttr)
                tapStr.addAttribute(NSLinkAttributeName, value: "havings://user/\(acter.id!)", range: NSMakeRange(0, tapStr.length))
                result.appendAttributedString(tapStr)
                
                let normalStr = NSMutableAttributedString(string: NSLocalizedString("Prompt.User.Honorific", comment: ""), attributes: defaultAttr)
                result.appendAttributedString(normalStr)
                
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Notifications.Act", comment: ""), attributes: defaultAttr))
                
                let targetStr = NSMutableAttributedString(string: target.itemName!, attributes: defaultAttr)
                targetStr.addAttribute(NSLinkAttributeName, value: "havings://item/\(target.itemId!)", range: NSMakeRange(0, targetStr.length))
                result.appendAttributedString(targetStr)
                result.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Prompt.Timeline.AddImage", comment: ""), attributes: defaultAttr))
                textview.attributedText = result
                
            default:
                break
            }
            
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = self.tableView.contentOffset.y + self.tableView.bounds.size.height
        let reachBottom = offset >= self.tableView.contentSize.height
        
        if reachBottom {
            
            let next = self.timelineEntity.hasNextEvent ?? false
            if next && !self.isLoading {
                let footer = tableView.dequeueReusableCellWithIdentifier("loadingMore")!
                self.isLoading = true
                self.tableView.tableFooterView = footer
                let lastId: Int = self.timelineEntity.timeline?.last?.eventId ?? 0
                self.timelineEntity.getNextTimeline(lastId, callback: {_ in
                    self.tableView.tableFooterView = nil
                    self.tableView.reloadData()
                    self.isLoading = false
                })
            }
        }
    }
}

extension TimelineViewController: UITextViewDelegate {
    
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

extension TimelineViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "icon_type_item")
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text: String = NSLocalizedString("Prompt.Timeline.isEmpty", comment: "")
        
        let font = UIFont.systemFontOfSize(16)
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName : UIColor.darkGrayColor()])
    }
}