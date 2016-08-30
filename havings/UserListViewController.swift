//
//  UserListViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/11.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import Alamofire
import DZNEmptyDataSet

class UserListViewController: UIViewController {
    
    enum UserListStyle {
        case ItemFavoritedUser
        case ImageFavoritedUser
        case Following
        case Followed
    }
    
    private let userThumbnailTag: Int = 10
    private let userNameLabelTag: Int = 11
    private let itemCountLabelTag: Int = 12
    
    var userListStyle: UserListStyle = .ItemFavoritedUser
    var relatedId: Int = 0
    private var userList: [UserEntity] = []
    private var beforeLoad = true
    
    @IBOutlet weak var tableView: UITableView!
    
    // フォローボタンはつけない方針(androidではつけちゃってるけど...)
    // 特にフォローボタンをつける必要性を感じられなくなったため
    // (ユーザーページならまだしも、一覧ページではそのユーザーをフォローするかどうかの情報は十分に得られない)
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self

        let completionHandler = { (response: Result<[UserEntity], NSError>) in
            self.beforeLoad = false
            switch response {
            case .Success(let result):
                self.userList = result
                self.tableView.reloadData()
                
            case .Failure(let error):
                print(error)
                
            }
        }
        
        switch self.userListStyle {
        case .ItemFavoritedUser:
            self.title = NSLocalizedString("Prompt.UserList.ItemFavoritedUser", comment: "")
            API.callArray(Endpoint.User.GetItemFavoritedUser(itemId: self.relatedId), completion: completionHandler)
        case .ImageFavoritedUser:
            self.title = NSLocalizedString("Prompt.UserList.ImageFavoritedUser", comment: "")
            API.callArray(Endpoint.User.GetImageFavoritedUser(imageId: self.relatedId), completion: completionHandler)
        case .Following:
            self.title = NSLocalizedString("Prompt.UserList.FollowingUser", comment: "")
            API.callArray(Endpoint.User.GetFollowingUser(userId: self.relatedId), completion: completionHandler)
            break
        case .Followed:
            self.title = NSLocalizedString("Prompt.UserList.FollowedUser", comment: "")
            API.callArray(Endpoint.User.GetFollowedUser(userId: self.relatedId), completion: completionHandler)

            break
        }
        self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.beforeLoad {
            return 1
        }else{
            return self.userList.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if self.beforeLoad {
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("loading")! as UITableViewCell
            return cell
        }else{
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("userCell")! as UITableViewCell
            
            let userThumbnail: UIImageView = cell.viewWithTag(self.userThumbnailTag) as! UIImageView
            let userNameLabel: UILabel = cell.viewWithTag(self.userNameLabelTag) as! UILabel
            let itemCountLabel: UILabel = cell.viewWithTag(self.itemCountLabelTag) as! UILabel
            
            let user = self.userList[indexPath.row]
            
            if let thumbnailPath = user.image {
                let urlString = ApiManager.getBaseUrl() + thumbnailPath
                userThumbnail.kf_setImageWithURL(NSURL(string: urlString)!, completionHandler: { (image, error, cacheType, imageURL) -> () in
                    userThumbnail.layer.cornerRadius = userThumbnail.frame.size.width/2
                    userThumbnail.clipsToBounds = true
                })
            }else{
                userThumbnail.image = UIImage(named: "user_thumb")
                userThumbnail.layer.cornerRadius = userThumbnail.frame.size.width/2
                userThumbnail.clipsToBounds = true
            }
            
            userNameLabel.text = user.name
            let count = user.count == nil ? "0" : "\(user.count!)"
            itemCountLabel.text = String(format: NSLocalizedString("Prompt.UserList.ItemCount", comment: ""), count)
            
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let storyboard: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
        let next: UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        let nextVC: UserViewController = next.visibleViewController as! UserViewController
        nextVC.userId = userList[indexPath.row].id!
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    /*
     func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
     return 0
     }
     */
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /*
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "セクション \(section)"
    }
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return " "
    }*/
    
}

extension UserListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "icon_type_item")
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text: String
        switch self.userListStyle {
        case .ItemFavoritedUser:
            text = NSLocalizedString("Prompt.UserList.ItemFavoritedUser.Empty", comment: "")
        case .ImageFavoritedUser:
            text = NSLocalizedString("Prompt.UserList.ImageFavoritedUser.Empty", comment: "")
        case .Following:
            text = NSLocalizedString("Prompt.UserList.FollowingUser.Empty", comment: "")
        case .Followed:
            text = NSLocalizedString("Prompt.UserList.FollowedUser.Empty", comment: "")
        }
        
        let font = UIFont.systemFontOfSize(16)
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName : UIColor.darkGrayColor()])
    }
}
