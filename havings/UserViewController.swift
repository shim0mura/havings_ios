//
//  UserViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/13.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import Alamofire
import GoogleMobileAds


class UserViewController: UIViewController, PostAlertUtil, ShareSheet, BannerUtil {

    private enum SegmentState {
        case OwningItems
        case Images
        case Graph
        
        func getIndex() -> Int{
            switch self {
            case .OwningItems:
                return 0
            case .Images:
                return 1
            case .Graph:
                return 2
            }
        }
        
        mutating func setState(index: Int){
            switch index {
            case 0:
                self = .OwningItems
            case 1:
                self = .Images
            case 2:
                self = .Graph
            default:
                self = .OwningItems
            }
        }
    }
    
    private enum SortType {
        case Nest
        case List
        
        mutating func setState(){
            switch self {
            case .Nest:
                self = .List
            case .List:
                self = .Nest
            }
        }
    }
    
    private let segmentControlTag: Int = 100

    private let headerImageTag: Int = 10
    private let gradientLayerTag: Int = 11
    private let userThumbnailTag: Int = 12
    private let userNameTag: Int = 13
    private let itemCountTag: Int = 14
    private let followCountContainerTag: Int = 15
    private let followCountTag: Int = 16
    private let followerCountContainerTag: Int = 17
    private let followerCountTag: Int = 18
    private let favoriteCountContainerTag: Int = 19
    private let favoriteCountTag: Int = 20
    private let dumpCountContainerTag: Int = 21
    private let dumpCountTag: Int = 22
    private let actionFollowContainerTag: Int = 23
    private let actionFollowImageTag: Int = 24
    private let actionFollowLabelTag: Int = 25
    private let actionShareContainerTag: Int = 26
    private let userDescLabelTag: Int = 27
    
    private let nestedItemIconTag: Int = 40
    private let nestedItemNameTag: Int = 41
    private let nestedItemCountTag: Int = 42
    
    private let itemImageTag: Int = 50
    private let itemImageNameTag: Int = 51
    private let itemImageFavoriteCountTag: Int = 52
   
    private var beforeLoad: Bool = true
    private var loadingNextImage: Bool = false
    
    var userId: Int = 0
    var selfUserId: Int = 0
    var userEntity: UserEntity? = UserEntity()
    private var headerCell: UITableViewCell? = nil
    private var headerHeight: Double = 0
    private var segState: SegmentState = .OwningItems
    private var segmentControll : UISegmentedControl?{
        didSet{
            self.segmentControll?.selectedSegmentIndex = self.segState.getIndex()
        }
    }
    private var scrollPositionBySegState = [
        SegmentState.OwningItems: 0.0,
        SegmentState.Images: 0.0,
        SegmentState.Graph: 0.0
    ]
    private var isSending: Bool = false
    
    private var nestedItems: [(depth: Int, item: ItemEntity)] = []
    private var buttonSort: UIBarButtonItem? = nil
    private var sortType: SortType = .Nest
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerNib(UINib(nibName: "ItemTableViewCell", bundle: nil), forCellReuseIdentifier: "itemCell")
        self.tableView.registerNib(UINib(nibName: "SimpleGraphViewCell", bundle: nil), forCellReuseIdentifier: "simpleChartCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = 110
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        let tokenManager = TokenManager.sharedManager
        if let ui = tokenManager.getUserId() {
            self.selfUserId = ui
            if self.userId == 0 {
                self.userId = ui
            }
        }
        
        loadUser()

        self.tableView.tableFooterView = UIView()

        showAd(bannerView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUser(){
        self.beforeLoad = true
        self.tableView.reloadData()
        API.call(Endpoint.User.Get(userId: self.userId)) { response in
            self.beforeLoad = false
            
            switch response {
            case .Success(let result):
                self.userEntity = result
                if let home = result.nestedItemFromHome {
                    self.setNestedItem(home, depth: 0)
                    self.setSortButton()
                }
                self.title = result.name
                self.tableView.reloadData()
            case .Failure(let error):
                self.userEntity = nil
                print("failure \(error)")
                
                let alert: UIAlertController = UIAlertController(title: NSLocalizedString("Prompt.Error", comment: ""), message: NSLocalizedString("Prompt.FailureToAceess", comment: ""), preferredStyle:  UIAlertControllerStyle.Alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Ok", comment: ""), style: UIAlertActionStyle.Default, handler:{
                    (action: UIAlertAction!) -> Void in
                    if let nav = self.navigationController {
                        nav.popViewControllerAnimated(true)
                    }else{
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
                
                alert.addAction(defaultAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func setSortButton(){
        switch self.segState {
        case .OwningItems:
            if let button = self.buttonSort {
                self.navBar.setRightBarButtonItems([button], animated: true)
            }else{
                let buttonSort = UIBarButtonItem()
                buttonSort.image = UIImage(named: "ic_swap_horiz_black_36dp")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                buttonSort
                buttonSort.target = self
                buttonSort.action = #selector(UserViewController.changeItemSort)
                self.buttonSort = buttonSort
                self.navBar.setRightBarButtonItems([buttonSort], animated: true)
            }
        default:
            self.navBar.setRightBarButtonItems([], animated: true)
        }
        
    }
    
    func changeItemSort(){
        self.sortType.setState()
        self.tableView.reloadData()
        let top = NSIndexPath(forRow: 0, inSection: 1)
        self.tableView.scrollToRowAtIndexPath(top, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        print("seg tap")
        
        print("contentOffset before \(self.tableView.contentOffset.y)")
        let offset = self.tableView.contentOffset
        let offsetY = Double(offset.y)
        
        if self.headerCell != nil {
            self.headerHeight = Double(headerCell!.bounds.height)
            print("headerHeight: \(self.headerHeight)")
        }
        
        let underSegcon = offsetY > (headerHeight - 65)
        if underSegcon {
            self.scrollPositionBySegState[segState] = offsetY
        }else{
            self.scrollPositionBySegState.keys.forEach{
                self.scrollPositionBySegState[$0] = 0
            }
        }
        
        self.segState.setState(sender.selectedSegmentIndex)
        self.setSortButton()

        //self.loadingNextItem = true
        self.loadingNextImage = true
        
        let top = NSIndexPath(forRow: 0, inSection: 0)
        //self.baseTable.scrollToRowAtIndexPath(aa, atScrollPosition: .Top, animated: true)
        //self.baseTable.setContentOffset(CGPoint(x: 0, y: 100), animated: false)
        self.tableView.scrollToRowAtIndexPath(top, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        
        self.tableView.reloadData(){
            print("contentOffset after \(self.tableView.contentOffset.y)")
            
            self.tableView.layoutIfNeeded()
            
            if underSegcon {
                
                
                if self.scrollPositionBySegState[self.segState] < 1 {
                    self.tableView.setContentOffset(CGPoint(x:0, y: self.headerHeight), animated: false)
                    print("set top")
                }else{
                    self.tableView.setContentOffset(CGPoint(x:0, y: self.scrollPositionBySegState[self.segState]!), animated: false)
                    print("set to current")
                }
            }else{
                self.tableView.setContentOffset(offset, animated: false)
                print("set nothing")
                
            }
            
            //self.loadingNextItem = false
            self.loadingNextImage = false
            
        }
        
    }
    
    @IBAction func tapFollowing(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "UserList", bundle: nil)
        let next: UserListViewController = storyboard.instantiateInitialViewController() as! UserListViewController
        next.userListStyle = UserListViewController.UserListStyle.Following
        next.relatedId = self.userEntity!.id!
        
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    @IBAction func tapFollower(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "UserList", bundle: nil)
        let next: UserListViewController = storyboard.instantiateInitialViewController() as! UserListViewController
        next.userListStyle = UserListViewController.UserListStyle.Followed
        next.relatedId = self.userEntity!.id!
        
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    @IBAction func tapFavorite(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "UserFavorite", bundle: nil)
        let next: UserFavoriteViewController = storyboard.instantiateInitialViewController() as! UserFavoriteViewController
        //next.userId = UserListViewController.UserListStyle.Followed
        next.userId = self.userEntity!.id!
        
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    @IBAction func tapDump(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "DumpItemList", bundle: nil)
        let next: DumpItemListViewController = storyboard.instantiateInitialViewController() as! DumpItemListViewController
        //next.userId = UserListViewController.UserListStyle.Followed
        next.userId = self.userEntity!.id!
        
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    

    @IBAction func tapShare(sender: AnyObject) {
        if let user = self.userEntity {
            showShareSheet(user.name!, itemPath: user.path!)
        }
    }


    
    @IBAction func tapActionFollow(sender: AnyObject) {
        
        guard self.isSending == false else{
            return
        }
        
        guard let userId = self.userEntity?.id, let header = self.headerCell else {
            return
        }
        
        if self.userEntity?.relation == 3 {
            let alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle:  UIAlertControllerStyle.ActionSheet)

            let notificationSetting: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Setting.Choose.Notification", comment: ""), style: UIAlertActionStyle.Default, handler:{(action: UIAlertAction!) -> Void in
                let storyboard: UIStoryboard = UIStoryboard(name: "Setting", bundle: nil)
                let next = storyboard.instantiateInitialViewController()
                self.presentViewController(next!, animated: true, completion: nil)
            })
            
            let profileEdit: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Setting.Choose.ProfileEdit", comment: ""), style: UIAlertActionStyle.Default, handler:{(action: UIAlertAction!) -> Void in
                let storyboard: UIStoryboard = UIStoryboard(name: "ProfileEdit", bundle: nil)
                let next = storyboard.instantiateInitialViewController() as! ProfileEditViewController
                next.finishDelegate = self
                self.presentViewController(next, animated: true, completion: nil)
            })
            
            let howToUse: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Setting.Choose.HowToUse", comment: ""), style: UIAlertActionStyle.Default, handler:{(action: UIAlertAction!) -> Void in
                    print("defaultAction_2")
            })
            
            let logout: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Setting.Choose.Logout", comment: ""), style: UIAlertActionStyle.Default, handler:{(action: UIAlertAction!) -> Void in
                API.call(Endpoint.Session.SignOut) { response in
                    switch response {
                    case .Success(let result):
                        print("success to logout\(result)")
                        
                        let tokenManager = TokenManager.sharedManager
                        tokenManager.resetTokenAndUid()
                        self.view.window!.rootViewController?.dismissViewControllerAnimated(false, completion: nil)

                    case .Failure(let error):
                        print("failure \(error)")
                        let tokenManager = TokenManager.sharedManager
                        tokenManager.resetTokenAndUid()
                        self.view.window!.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
                    }
                }
            })
            
            
            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler:{
                (action: UIAlertAction!) -> Void in
            })
            
            alert.addAction(cancelAction)
            alert.addAction(notificationSetting)
            alert.addAction(profileEdit)
            alert.addAction(howToUse)
            alert.addAction(logout)
            
            presentViewController(alert, animated: true, completion: nil)
            /*
            let storyboard: UIStoryboard = UIStoryboard(name: "ProfileEdit", bundle: nil)
            let next = storyboard.instantiateInitialViewController()
            self.presentViewController(next!, animated: true, completion: nil)
            */
        }
        
        let completeHandler = { (response: Result<GenericResult, NSError>) in
            switch response {
            case .Success(let result):
                self.isSending = false
                if let errors = result.errors as? Dictionary<String, AnyObject> {
                    self.showFailedAlert(errors)
                    return
                }else{
                    self.toggleActionFollowButtonAppearance(header)
                }
            case .Failure(let error):
                self.isSending = false
                print("failure \(error)")
                self.simpleAlertDialog(NSLocalizedString("Prompt.Follow.Failed", comment: ""), message: nil)
            }
        }
        
        if self.userEntity?.relation == 1 || self.userEntity?.relation == 2 {
            self.isSending = true
            API.call(Endpoint.Follow.UnFollow(userId: userId), completion: completeHandler)
        }else if self.userEntity?.relation == 0 {
            self.isSending = true
            API.call(Endpoint.Follow.Follow(userId: userId), completion: completeHandler)
        }
        
    }
    
    
    func setNestedItem(parentItem: ItemEntity, depth: Int){
        parentItem.owningItems?.forEach{
            self.nestedItems.append((depth: depth, item: $0))
            
            if let grandChildItems = $0.owningItems where grandChildItems.count > 0 {
                self.setNestedItem($0, depth: depth + 1)
            }
        }
    }

}

extension UserViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // section0: userの情報
        // section1: アイテム、画像、グラフなどのsegmentControllで操作するもの
        return 2;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            if userEntity == nil && !self.beforeLoad{
                return 0
            }else{
                return 1            
            }
        }else if section == 1 {
            switch self.segState {
            case .OwningItems:
                if self.beforeLoad {
                    return 0
                }else{
                    let count = self.nestedItems.count
                    if count == 0 {
                        return 1
                    }else{
                        return count
                    }
                }
            case .Images:
                if self.beforeLoad {
                    return 0
                }else if let images = self.userEntity?.homeList?.itemImages {
                    let count = images.images?.count ?? 0
                    if count == 0 {
                        return 1
                    }else{
                        return count
                    }
                }else{
                    return 0
                }
            case .Graph:
                return 1
            }
            
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            let cell: UITableViewCell
            if self.beforeLoad {
                cell = self.tableView.dequeueReusableCellWithIdentifier("loading")! as UITableViewCell
            }else{
                if let c = self.headerCell {
                    cell = c
                }else{
                    cell = self.tableView.dequeueReusableCellWithIdentifier("header")! as UITableViewCell
                    self.setHeaderCell(cell)
                    self.headerCell = cell
                }

            }

            return cell
        }else{
            switch self.segState {
            case .OwningItems:
                
                if self.nestedItems.count == 0 {
                    let cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
                    cell.textLabel?.text = NSLocalizedString("Prompt.User.Item.Empty", comment: "")
                    return cell
                }
                
                let i = self.nestedItems[indexPath.row]
                
                switch self.sortType {
                case .Nest:
                    let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("nestedItem")! as UITableViewCell
                    let iconImage: UIImageView = cell.viewWithTag(self.nestedItemIconTag) as! UIImageView
                    let itemName: UILabel = cell.viewWithTag(self.nestedItemNameTag) as! UILabel
                    let itemCount: UILabel = cell.viewWithTag(self.nestedItemCountTag) as! UILabel
                    
                    
                    let colorBase = 1 - (0.03 * Double(i.depth))
                    let indentDepth = i.depth > 5 ? 5 : i.depth
                    cell.contentView.layoutMargins = UIEdgeInsetsMake(0, CGFloat(15 * indentDepth), 0, 0)
                    
                    cell.backgroundColor = UIColor(red: CGFloat(colorBase), green: CGFloat(colorBase), blue: CGFloat(colorBase), alpha: 1.0)
                    
                    if i.item.isList == true {
                        iconImage.image = UIImage(named: "icon_type_list_light")
                    }else{
                        iconImage.image = UIImage(named: "icon_type_item")
                    }
                    
                    itemName.text = i.item.name
                    itemCount.text = String(format: NSLocalizedString("Prompt.Item.CountLabel", comment: ""), String(i.item.count!))
                    
                    return cell
                    
                case .List:
                    let cell : ItemTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("itemCell") as! ItemTableViewCell
                    
                    cell.setItem(i.item)
                    return cell
                }
            case .Images:

                
                guard let imageList = self.userEntity?.homeList?.itemImages, let images = imageList.images where !images.isEmpty else {
                    let cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
                    cell.textLabel?.text = NSLocalizedString("Prompt.User.Image.Empty", comment: "")
                    return cell
                }

                
                let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("itemImages")!
                
                let image = images[indexPath.row]
                
                let imageView: UIImageView = cell.viewWithTag(self.itemImageTag) as! UIImageView
                let imageItemName: UILabel = cell.viewWithTag(self.itemImageNameTag) as! UILabel
                let imageFavorite: UILabel = cell.viewWithTag(self.itemImageFavoriteCountTag) as! UILabel
                
                if let imagePath = image.url {
                    let urlString = ApiManager.getBaseUrl() + imagePath
                    imageView.kf_setImageWithURL(NSURL(string: urlString)!)
                }else{
                    imageView.image = nil
                    imageView.backgroundColor = UIColor(red:0.01, green:0.60, blue:0.96, alpha:1.0)
                }
                imageItemName.text = image.itemName
                imageFavorite.text = String(image.imageFavoriteCount!)
                
                return cell
            case .Graph:
                let cell = self.tableView.dequeueReusableCellWithIdentifier("simpleChartCell") as! SimpleTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.setNavigationController(self.navigationController)
                cell.setChart(self.userEntity?.homeList?.countProperties)
                return cell
            }
        }
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            return nil
        }else if !self.beforeLoad{

            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("segmentedControl")!
            self.segmentControll = cell.viewWithTag(self.segmentControlTag) as? UISegmentedControl
            return cell
        }else{
            return nil
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("touch!!")
        
        if indexPath.section == 0 {
            
        }else if indexPath.section == 1{
            
            switch self.segState {
            case .OwningItems:
                let nextItem = self.nestedItems[indexPath.row].item
                let next = UIStoryboard(name: "Item", bundle: nil).instantiateInitialViewController() as! ItemViewController
                next.itemId = nextItem.id
                self.navigationController?.pushViewController(next, animated: true)
                
                print("item touch")
            case .Images:
                
                let storyboard: UIStoryboard = UIStoryboard(name: "ItemImage", bundle: nil)
                let next: ItemImageViewController = storyboard.instantiateViewControllerWithIdentifier("item_image") as! ItemImageViewController
                next.itemImageEntity = self.userEntity?.homeList?.itemImages?.images![indexPath.row]
                
                self.navigationController?.pushViewController(next, animated: true)
 
                print("image touch")
            default:
                break
            }
            
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = self.tableView.contentOffset.y + self.tableView.bounds.size.height
        let reachBottom = offset >= self.tableView.contentSize.height
        
        if reachBottom {
            print("reach bottom \(segState)")
            switch self.segState {
            case .Images:
                let nextImages = self.userEntity?.homeList?.itemImages?.hasNextImage ?? false
                if nextImages && !self.loadingNextImage {
                    let footer = self.tableView.dequeueReusableCellWithIdentifier("imageLoad")!
                    footer.hidden = false
                    print(footer)
                    self.loadingNextImage = true
                    self.tableView.tableFooterView = footer
                    
                    self.userEntity?.homeList?.itemImages?.getNextUserImages(userId: (self.userEntity!.id)!, page: self.userEntity?.homeList?.itemImages?.nextPageForImage ?? 0){result in
                        self.tableView.tableFooterView = nil
                        self.tableView.reloadData(){
                            self.loadingNextImage = false
                        }
                    }
                }
                
                
            default:
                break
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 44
    }
    
    func setHeaderCell(cell: UITableViewCell) -> UITableViewCell {
        let grad: UIView = cell.contentView.viewWithTag(self.gradientLayerTag)!
        let startColor = UIColor(red:0.8, green:0.8, blue:0.8, alpha:0).CGColor
        let endColor = UIColor(white: 0, alpha: 0.5).CGColor
        let layer = CAGradientLayer()
        layer.colors = [startColor, endColor]
        layer.frame = grad.bounds

        grad.layer.insertSublayer(layer, atIndex: 0)
        
        let headerImage: UIImageView = cell.contentView.viewWithTag(self.headerImageTag) as! UIImageView
        if let thumbnailPath = self.userEntity?.backGroundImage {
            let urlString = ApiManager.getBaseUrl() + thumbnailPath
            headerImage.kf_setImageWithURL(NSURL(string: urlString)!)
        }else{
            headerImage.image = nil
            headerImage.backgroundColor = UIColor(red:0.01, green:0.60, blue:0.96, alpha:1.0)
        }
        
        let userName: UILabel = cell.contentView.viewWithTag(self.userNameTag) as! UILabel
        userName.text = userEntity?.name
        
        let itemCount: UILabel = cell.contentView.viewWithTag(self.itemCountTag) as! UILabel
        let count = self.userEntity?.count ?? 0
        itemCount.text = String(format: NSLocalizedString("Prompt.User.itemCount", comment: ""), String(count))
        
        let userThumbnail: UIImageView = cell.contentView.viewWithTag(self.userThumbnailTag) as! UIImageView
        if let userThumbnailPath = self.userEntity?.image {
            let urlString = ApiManager.getBaseUrl() + userThumbnailPath
            userThumbnail.kf_setImageWithURL(NSURL(string: urlString)!)
        }else{
            userThumbnail.image = UIImage(named: "user_thumb")
        }
        userThumbnail.layer.cornerRadius = userThumbnail.frame.size.width * 0.5
        userThumbnail.layer.borderWidth = 2.0
        userThumbnail.layer.borderColor = UIColor.lightGrayColor().CGColor
        userThumbnail.clipsToBounds = true
        
        let followingContainer = cell.contentView.viewWithTag(self.followCountContainerTag)
        followingContainer?.userInteractionEnabled = true
        let followingLabel: UILabel = cell.contentView.viewWithTag(self.followCountTag) as! UILabel
        followingLabel.text = String(self.userEntity?.followingCount ?? 0)
        
        let followerContainer = cell.contentView.viewWithTag(self.followerCountContainerTag)
        followerContainer?.userInteractionEnabled = true
        let followerLabel: UILabel = cell.contentView.viewWithTag(self.followerCountTag) as! UILabel
        followerLabel.text = String(self.userEntity?.followerCount ?? 0)
        
        let favoriteContainer = cell.contentView.viewWithTag(self.favoriteCountContainerTag)
        favoriteContainer?.userInteractionEnabled = true
        let favoriteLabel: UILabel = cell.contentView.viewWithTag(self.favoriteCountTag) as! UILabel
        let itemFavorite: Int = self.userEntity?.favoritesCount ?? 0
        let imageFavorite: Int = self.userEntity?.imageFavoritesCount ?? 0
        favoriteLabel.text = String(itemFavorite + imageFavorite)
        
        let dumpContaier = cell.contentView.viewWithTag(self.dumpCountContainerTag)
        dumpContaier?.userInteractionEnabled = true
        let dumpLabel: UILabel = cell.contentView.viewWithTag(self.dumpCountTag) as! UILabel
        dumpLabel.text = String(self.userEntity?.dumpItemsCount ?? 0)
        
        let desc: UILabel = cell.contentView.viewWithTag(self.userDescLabelTag) as! UILabel
        desc.text = userEntity?.description
        
        let actionFollowContainer = cell.contentView.viewWithTag(self.actionFollowContainerTag)
        actionFollowContainer?.userInteractionEnabled = true
        let actionFollowImage: UIImageView = cell.contentView.viewWithTag(self.actionFollowImageTag) as! UIImageView
        let actionFollowLabel: UILabel = cell.contentView.viewWithTag(self.actionFollowLabelTag) as! UILabel
        if self.userEntity?.relation == 3 {
            actionFollowImage.image = UIImage(named: "ic_settings_black_36dp")
            actionFollowLabel.text = NSLocalizedString("Prompt.User.Action.Edit", comment: "")
        }else if self.userEntity?.relation == 2 || self.userEntity?.relation == 1 {
            actionFollowImage.image = UIImage(named: "ic_done_black_36dp")
            actionFollowLabel.text = NSLocalizedString("Prompt.User.Action.Following", comment: "")
        }
        
        let actionShareContainer = cell.contentView.viewWithTag(self.actionShareContainerTag)
        actionShareContainer?.userInteractionEnabled = true

        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    func toggleActionFollowButtonAppearance(cell: UITableViewCell){

        let actionFollowImage: UIImageView = cell.contentView.viewWithTag(self.actionFollowImageTag) as! UIImageView
        let actionFollowLabel: UILabel = cell.contentView.viewWithTag(self.actionFollowLabelTag) as! UILabel
        
        if self.userEntity?.relation == 1 || self.userEntity?.relation == 2 {
            self.userEntity?.relation = 0
        }else if self.userEntity?.relation == 0 {
            self.userEntity?.relation = 1
        }
        
        if self.userEntity?.relation == 2 || self.userEntity?.relation == 1 {
            actionFollowImage.image = UIImage(named: "ic_done_black_36dp")
            actionFollowLabel.text = NSLocalizedString("Prompt.User.Action.Following", comment: "")
        }else if self.userEntity?.relation == 0 {
            actionFollowImage.image = UIImage(named: "ic_person_add_black_18dp")
            actionFollowLabel.text = NSLocalizedString("Prompt.User.Action.Follow", comment: "")
        }
    }
}

extension UserViewController: FinishProfileUpdateDelegate {
    func finish() {
        self.view.makeToast(NSLocalizedString("Prompt.ProfileEdit.Success", comment: ""))
        
        headerCell = nil
        loadUser()
    }
}

protocol FinishProfileUpdateDelegate: class {
    func finish()
}
