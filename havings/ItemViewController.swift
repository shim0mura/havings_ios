//
//  ItemViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/05/27.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import XLActionController
import Alamofire

class ItemViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PostAlertUtil {
    
    private enum SegmentState {
        case OwningItems
        case ItemImages
        case Graph
        
        func getIndex(itemType: ItemType) -> Int{
            switch self {
            case .OwningItems:
                switch itemType {
                case .Item:
                    return -1
                case .List:
                    return 0
                }
            case .ItemImages:
                switch itemType {
                case .Item:
                    return 0
                case .List:
                    return 1
                }
            case .Graph:
                switch itemType {
                case .Item:
                    return 1
                case .List:
                    return 2
                }
            }
        }
        
        mutating func setState(index: Int, itemType: ItemType){
            switch itemType {
            case .Item:
                if index == 0 {
                    self = .ItemImages
                }else if index == 1 {
                    self = .Graph
                }
            case .List:
                if index == 0 {
                    self = .OwningItems
                }else if index == 1 {
                    self = .ItemImages
                }else if index == 2 {
                    self = .Graph
                }
            }
        }
        
    }
    
    private enum ItemType {
        case Item
        case List
    }
    
    private let segmentControlTag: Int = 100
    private let gradientLayerTag: Int = 101
    
    private let headerImageTag: Int = 10
    private let itemTypeIconTag: Int = 11
    private let itemNameTag: Int = 12
    private let itemCountTag: Int = 13
    private let userNameTag: Int = 14
    private let likeCountTag: Int = 15
    private let commentCountTag: Int = 16
    private let tagListTag: Int = 17
    private let descriptionTag: Int = 18
    private let userThumbnailTag: Int = 19
    private let favoriteImageTag: Int = 20
    private let commentImageTag: Int = 21
    private let isPrivateTag: Int = 22
    private let breadCrumbTag: Int = 23
    private let doneTaskCountainerTag: Int = 24
    private let doneTaskCountTag: Int = 25
    private let shareImageTag: Int = 26
    private let etcMenuImageTag: Int = 27
    
    private let timerNameTag: Int = 30
    private let timerRepeatTag: Int = 31
    private let timerAlarmTag: Int = 32
    private let timerProgressTag: Int = 33
    
    private let toolContainerTag: Int = 70
    
    private var itemEntity: ItemEntity?
    private var loadingNextItem: Bool = false
    private var loadingNextImage: Bool = false
    
    private var headerHeight: Double = 0.0
    private var scrollPositionBySegState = [
        SegmentState.OwningItems: 0.0,
        SegmentState.ItemImages: 0.0,
        SegmentState.Graph: 0.0
    ]
    
    private var userId = 0
    private var section0rows: Int = 1
    private var timerState: TimerOwnState = .CanNotHaveTimer
    private var segState: SegmentState = .OwningItems
    private var itemType: ItemType = .List
    private var isSending: Bool = false
    private var beforeLoading: Bool = true
    
    private var headerCell: UITableViewCell? = nil
    
    @IBOutlet var baseTable: UITableView!
    var segmentControll : UISegmentedControl?{
        didSet{
            if self.itemType == .Item {
                self.segmentControll?.removeSegmentAtIndex(0, animated: true)
            }
            self.segmentControll?.selectedSegmentIndex = self.segState.getIndex(self.itemType)
        }
    }
    
    var itemId: Int!
    
    @IBAction func segtap(sender: AnyObject) {
        print(6786)
        let seg : UISegmentedControl = sender as! UISegmentedControl
        print(seg.selectedSegmentIndex)
        
        print("contentOffset before \(baseTable.contentOffset.y)")
        let offset = baseTable.contentOffset
        let offsetY = Double(offset.y)
        
        if headerCell != nil {
            headerHeight = Double(headerCell!.bounds.height)
        }
        
        let underSegcon = offsetY > (headerHeight - 65)
        if underSegcon {
            scrollPositionBySegState[segState] = offsetY
        }else{
            scrollPositionBySegState.keys.forEach{
                scrollPositionBySegState[$0] = 0
            }
        }
        
        self.segState.setState(seg.selectedSegmentIndex, itemType: self.itemType)
        self.loadingNextItem = true
        self.loadingNextImage = true
        
        let top = NSIndexPath(forRow: 0, inSection: 0)
        //self.baseTable.scrollToRowAtIndexPath(aa, atScrollPosition: .Top, animated: true)
        //self.baseTable.setContentOffset(CGPoint(x: 0, y: 100), animated: false)
        self.baseTable.scrollToRowAtIndexPath(top, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        baseTable.reloadData(){
            print("contentOffset after \(self.baseTable.contentOffset.y)")
            
            self.baseTable.layoutIfNeeded()

            if underSegcon {
                
                if self.scrollPositionBySegState[self.segState] < 1 {
                    //self.baseTable.setContentOffset(CGPoint(x:0, y: self.headerHeight - 64), animated: false)
                    self.baseTable.setContentOffset(CGPoint(x:0, y: self.headerHeight), animated: false)

                    print("set top")
                }else{
                    self.baseTable.setContentOffset(CGPoint(x:0, y: self.scrollPositionBySegState[self.segState]!), animated: false)
                    print("set to current")
                }
            }else{
                self.baseTable.setContentOffset(offset, animated: false)
                print("set nothing")

            }
            
            self.loadingNextItem = false
            self.loadingNextImage = false
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseTable.registerNib(UINib(nibName: "ItemTableViewCell", bundle: nil), forCellReuseIdentifier: "itemCell")
        baseTable.registerNib(UINib(nibName: "SimpleGraphViewCell", bundle: nil), forCellReuseIdentifier: "simpleChartCell")
        self.baseTable.estimatedRowHeight = 110
        self.baseTable.rowHeight = UITableViewAutomaticDimension

        API.call(Endpoint.Item.Get(id: self.itemId)) { response in
            switch response {
            case .Success(let result):
                self.beforeLoading = false
                
                self.itemEntity = result
                if result.isList == true {
                    self.itemType = .List
                }else{
                    self.itemType = .Item
                }
                self.segState.setState(0, itemType: self.itemType)
                self.setSection0RowCount(result)
                
                self.title = result.name
                
                self.baseTable.reloadData()
            case .Failure(let error):
                print("failure \(error)")
            }
        }
        let cell : ItemImageCell = baseTable.dequeueReusableCellWithIdentifier("itemImages") as! ItemImageCell
        cell.layoutSubviews()
        
        let tokenManager = TokenManager.sharedManager
        if let ui = tokenManager.getUserId() {
            self.userId = ui
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addTimer(sender: AnyObject) {
        switch self.timerState {
        case .NoTimer, .CanAddMoreTimer:
            let storyboard: UIStoryboard = UIStoryboard(name: "TimerForm", bundle: nil)
            let next: UINavigationController = storyboard.instantiateInitialViewController()! as! UINavigationController
            let vc = next.visibleViewController as! TimerFormViewController
            let timer = TimerEntity()
            timer.listId = self.itemEntity!.id
            vc.timer = timer
            vc.timerChangeDelegate = self
            vc.formType = TimerFormViewController.FormType.Add
            
            self.presentViewController(next, animated: true, completion: nil)
        default:
            break
        }
    }
    
    @IBAction func tapOwner(sender: AnyObject) {
        if let id = itemEntity?.owner?.id {
            let storyboard: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
            let next: UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
            let nextVC: UserViewController = next.visibleViewController as! UserViewController
            nextVC.userId = id
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    @IBAction func tapLikeCount(sender: AnyObject) {
        if let id = itemEntity?.id {
            let storyboard: UIStoryboard = UIStoryboard(name: "UserList", bundle: nil)
            let next: UserListViewController = storyboard.instantiateInitialViewController() as! UserListViewController
            next.userListStyle = UserListViewController.UserListStyle.ItemFavoritedUser
            next.relatedId = id
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
    @IBAction func tapCommentCount(sender: AnyObject) {
        if let id = itemEntity?.id {
            let storyboard: UIStoryboard = UIStoryboard(name: "Comment", bundle: nil)
            let next: CommentViewController = storyboard.instantiateInitialViewController() as! CommentViewController
            next.itemId = id
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
    @IBAction func tapDoneCount(sender: AnyObject) {
        if self.userId == self.itemEntity?.owner?.id {
            let storyboard: UIStoryboard = UIStoryboard(name: "DoneTasks", bundle: nil)
            let next: DoneTaskViewController = storyboard.instantiateInitialViewController() as! DoneTaskViewController
            next.itemId = (self.itemEntity!.id)!
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
    @IBAction func tapShare(sender: AnyObject) {
        print("ssss")
    }
    
    @IBAction func tapEtcMenu(sender: AnyObject) {
        let alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle:  UIAlertControllerStyle.ActionSheet)
        
        if self.itemEntity?.owner?.id == self.userId {
            let type = (self.itemEntity?.isList == true) ? NSLocalizedString("Prompt.List", comment: "") : NSLocalizedString("Prompt.Item", comment: "")
            let editTitle = String(format: NSLocalizedString("Prompt.Item.Edit.WithType", comment: ""), type)
            
            let edit: UIAlertAction = UIAlertAction(title: editTitle, style: UIAlertActionStyle.Default, handler:{(action: UIAlertAction!) -> Void in
                let storyboard: UIStoryboard = UIStoryboard(name: "Form", bundle: nil)
                let nav: UINavigationController? = storyboard.instantiateViewControllerWithIdentifier("edit_form_navigation") as? UINavigationController
                
                guard let navigationVC = nav, let formVC: AddFormViewController = navigationVC.viewControllers.first as? AddFormViewController else {
                    return
                }
                formVC.item = self.itemEntity!
                formVC.typeAdd = false
                self.presentViewController(navigationVC, animated: true, completion: nil)
            })
            alert.addAction(edit)
            
            if self.itemEntity?.isGarbage == false {
                let dumpTitle = String(format: NSLocalizedString("Prompt.Item.Dump.WithType", comment: ""), type)
                let dump: UIAlertAction = UIAlertAction(title: dumpTitle, style: UIAlertActionStyle.Default, handler:{(action: UIAlertAction!) -> Void in
                    let next: DumpItemViewController = UIStoryboard(name: "Form", bundle: nil).instantiateViewControllerWithIdentifier("dump_item") as! DumpItemViewController
                    let item = ItemEntity()
                    item.id = self.itemEntity!.id!
                    item.isList = self.itemEntity!.isList!
                    item.owningItems = self.itemEntity!.owningItems!
                    next.item = item
                    
                    self.navigationController?.pushViewController(next, animated: true)
                })
                alert.addAction(dump)
            }
            
            let deleteTitle = String(format: NSLocalizedString("Prompt.Item.Delete.WithType", comment: ""), type)
            let delete: UIAlertAction = UIAlertAction(title: deleteTitle, style: UIAlertActionStyle.Default, handler:{(action: UIAlertAction!) -> Void in
                let next: DeleteItemViewController = UIStoryboard(name: "Form", bundle: nil).instantiateViewControllerWithIdentifier("delete_item") as! DeleteItemViewController
                let item = ItemEntity()
                item.id = self.itemEntity!.id!
                item.isList = self.itemEntity!.isList!
                item.owningItems = self.itemEntity!.owningItems!
                next.item = item
                
                self.navigationController?.pushViewController(next, animated: true)
            })
            alert.addAction(delete)
            
        }
        
        let copy: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Item.CopyUrl", comment: ""), style: UIAlertActionStyle.Default, handler:{(action: UIAlertAction!) -> Void in
            let board = UIPasteboard.generalPasteboard()
            let url = ApiManager.getBaseUrl() + "/items/\(self.itemEntity!.id!)"
            
            board.setValue(url, forPasteboardType: "public.text")
        })
        alert.addAction(copy)
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler:{
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // section0: item自体の情報(タイマー含む)
        // section1: 子アイテム、画像、グラフなどのsegmentControllで操作するもの
        return 2;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let item = self.itemEntity else {
            return 0
        }
        
        if section == 0 {
            return self.section0rows
        }else if section == 1 {
            switch self.segState {
            case .OwningItems:
                if item.owningItems != nil {
                    return (item.owningItems?.count)!
                }else{
                    return 0
                }
            case .ItemImages:
                if item.itemImages?.images != nil {
                    return (item.itemImages!.images!.count)
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
            if indexPath.row == 0 {
                let cell : UITableViewCell = baseTable.dequeueReusableCellWithIdentifier("itemHeader")! as UITableViewCell
                
                if itemEntity != nil {
                    if self.headerCell == nil {
                        self.headerCell = setItemData(cell)
                    }
                }
                
                return headerCell ?? cell
            }else if indexPath.row == 1{
                let cell = baseTable.dequeueReusableCellWithIdentifier("timerHeader")! as UITableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.userInteractionEnabled = false

                return cell
            }else{
                return self.getTimerCell(indexPath)
            }
        }else{
            switch self.segState {
            case .OwningItems:
                let cell : ItemTableViewCell = baseTable.dequeueReusableCellWithIdentifier("itemCell") as! ItemTableViewCell
                let item = itemEntity.flatMap{(i: ItemEntity) -> ItemEntity? in
                    i.owningItems?[indexPath.row] ?? nil
                }
                
                if let i = item {
                    cell.setItem(i)
                }
                return cell
            case .ItemImages:
                let cell : ItemImageCell = baseTable.dequeueReusableCellWithIdentifier("itemImages") as! ItemImageCell
                let itemImage: ItemImageEntity? = itemEntity?.itemImages?.images.flatMap{$0[indexPath.row] ?? nil}
                
                if itemImage != nil {
                    cell.setItem(itemImage!)
                }
                
                return cell
            case .Graph:
                let cell = baseTable.dequeueReusableCellWithIdentifier("simpleChartCell") as! SimpleTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.setNavigationController(self.navigationController)
                cell.setChart(self.itemEntity?.countProperties)
                return cell
            }
        }

    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if self.beforeLoading {
            let cell : UITableViewCell = baseTable.dequeueReusableCellWithIdentifier("loading")!
            return cell.contentView

        } else if section == 0 {
            print("page header")
            return nil
        }else{
            print("segment control header")
            let cell : UITableViewCell = baseTable.dequeueReusableCellWithIdentifier("segmentControl")!
            self.segmentControll = cell.viewWithTag(segmentControlTag) as? UISegmentedControl
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("touch!!")
        
        // タイマー周りのtouchイベント
        if indexPath.section == 0 {
            if timerState != TimerOwnState.CanNotHaveTimer && indexPath.section == 0 && 2...4 ~= indexPath.row {
                let selectedTimer:TimerEntity = self.itemEntity!.timers![indexPath.row - 2]
                
                let actionController: XLActionController = self.getTimerActionAlert(selectedTimer)
                presentViewController(actionController, animated: true, completion: nil)
            }
        }else if indexPath.section == 1{
            
            switch self.segState {
            case .OwningItems:
                let nextItem = self.itemEntity!.owningItems![indexPath.row]
                let next = self.storyboard?.instantiateInitialViewController() as! ItemViewController
                next.itemId = nextItem.id
                self.navigationController?.pushViewController(next, animated: true)
            case .ItemImages:
                let storyboard: UIStoryboard = UIStoryboard(name: "ItemImage", bundle: nil)
                let next: ItemImageViewController = storyboard.instantiateViewControllerWithIdentifier("item_image") as! ItemImageViewController
                next.itemImageEntity = self.itemEntity?.itemImages?.images![indexPath.row]

                self.navigationController?.pushViewController(next, animated: true)
            default:
                break
            }
            
        }
        
        baseTable.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = self.baseTable.contentOffset.y + self.baseTable.bounds.size.height
        let reachBottom = offset >= self.baseTable.contentSize.height

        if reachBottom {
            print("reach bottom \(segState)")
            switch self.segState {
            case .OwningItems:
                let nextItem = itemEntity?.hasNextItem ?? false
                if nextItem && !loadingNextItem {
                    let footer = baseTable.dequeueReusableCellWithIdentifier("loading")!
                    self.loadingNextItem = true
                    self.baseTable.tableFooterView = footer
                    self.itemEntity?.getNextOwningItem(page: self.itemEntity?.nextPageForItem ?? 0){result in
                        print(self.itemEntity?.owningItems!.count)
                        self.baseTable.tableFooterView = nil
                        self.baseTable.reloadData(){
                            self.loadingNextItem = false
                        }
                    }
                }
            case .ItemImages:
                let nextImages = itemEntity?.itemImages?.hasNextImage ?? false
                if nextImages && !loadingNextImage {
                    let footer = baseTable.dequeueReusableCellWithIdentifier("loading")!
                    self.loadingNextImage = true
                    self.baseTable.tableFooterView = footer

                    self.itemEntity?.itemImages?.getNextItemImages(itemId: (itemEntity?.id)!, page: self.itemEntity?.itemImages?.nextPageForImage ?? 0){result in
                        self.baseTable.tableFooterView = nil
                        self.baseTable.reloadData(){
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
    
    func setItemData(cell :UITableViewCell) -> UITableViewCell {
        
        let grad: UIView = cell.contentView.viewWithTag(gradientLayerTag)!
        let startColor = UIColor(red:0.8, green:0.8, blue:0.8, alpha:0).CGColor
        let endColor = UIColor(white: 0, alpha: 0.5).CGColor
        let layer = CAGradientLayer()
        layer.colors = [startColor, endColor]
        layer.frame = grad.bounds
        grad.layer.insertSublayer(layer, atIndex: 0)
        
        let headerImage: UIImageView = cell.contentView.viewWithTag(headerImageTag) as! UIImageView
        if let thumbnailPath = itemEntity?.thumbnail {
            let urlString = ApiManager.getBaseUrl() + thumbnailPath
            headerImage.kf_setImageWithURL(NSURL(string: urlString)!)
        }else{
            headerImage.image = nil
            headerImage.backgroundColor = UIColor(red:0.01, green:0.60, blue:0.96, alpha:1.0)
        }
        
        let itemTypeIcon: UIImageView = cell.contentView.viewWithTag(itemTypeIconTag) as! UIImageView
        if itemEntity?.isGarbage == true {
            itemTypeIcon.image = UIImage(named: "ic_delete_black_24dp")
        } else if itemEntity?.isList?.boolValue == true {
            itemTypeIcon.image = UIImage(named: "icon_type_list_white")
        }else{
            itemTypeIcon.image = UIImage(named: "icon_type_item_white")
        }
        
        let itemName: UILabel = cell.contentView.viewWithTag(itemNameTag) as! UILabel
        itemName.text = itemEntity?.name!
        
        let itemCount: UILabel = cell.contentView.viewWithTag(itemCountTag) as! UILabel
        itemCount.text = String(itemEntity?.count ?? 0)
        itemCount.font = UIFont.boldSystemFontOfSize(20)

        itemCount.sizeToFit()
        
        let isPrivate = cell.contentView.viewWithTag(self.isPrivateTag)
        if itemEntity?.privateType == 0 {
            isPrivate?.hidden = true
        }
        
        let breadcrumb: UILabel = cell.contentView.viewWithTag(self.breadCrumbTag) as! UILabel
        breadcrumb.text = itemEntity?.breadcrumb?.stringByReplacingOccurrencesOfString(" > ", withString: " >\n")

        let userName: UILabel = cell.contentView.viewWithTag(userNameTag) as! UILabel
        userName.text = itemEntity?.owner?.name
        
        let userThumbnail: UIImageView = cell.contentView.viewWithTag(userThumbnailTag) as! UIImageView
        if let userThumbnailPath = itemEntity!.owner?.image {
            let urlString = ApiManager.getBaseUrl() + userThumbnailPath
            userThumbnail.kf_setImageWithURL(NSURL(string: urlString)!)
        }else{
            userThumbnail.image = UIImage(named: "user_thumb")
        }
        userThumbnail.layer.cornerRadius = userThumbnail.frame.size.width * 0.5
        userThumbnail.clipsToBounds = true
        
        let likeCount: UILabel = cell.contentView.viewWithTag(likeCountTag) as! UILabel
        likeCount.text = String(itemEntity?.favoriteCount ?? 0)
        
        let commentCount: UILabel = cell.contentView.viewWithTag(commentCountTag) as! UILabel
        commentCount.text = String(itemEntity?.commentCount ?? 0)
        
        if itemEntity?.owner?.id == self.userId {
        let doneCount:UILabel = cell.contentView.viewWithTag(self.doneTaskCountTag) as! UILabel
        doneCount.text = String(itemEntity?.doneCount ?? 0)
        }
        
        let tagList: TagListView = cell.contentView.viewWithTag(tagListTag) as! TagListView
        tagList.textFont = UIFont.systemFontOfSize(17)
        itemEntity?.tags?.forEach{
            tagList.addTag($0)
        }
        
        let favoriteImage: UIImageView = cell.contentView.viewWithTag(self.favoriteImageTag) as! UIImageView
        favoriteImage.userInteractionEnabled = true
        let commentImage: UIImageView = cell.contentView.viewWithTag(self.commentImageTag) as! UIImageView
        commentImage.userInteractionEnabled = true
        let shareImage: UIImageView = cell.contentView.viewWithTag(self.shareImageTag) as! UIImageView
        shareImage.userInteractionEnabled = true
        let etcImage: UIImageView = cell.contentView.viewWithTag(self.etcMenuImageTag) as! UIImageView
        etcImage.userInteractionEnabled = true
        
        if itemEntity?.isFavorited == true {
            favoriteImage.image = UIImage(named: "ic_favorite_pink_300_36dp")
        }else{
            favoriteImage.image = UIImage(named: "ic_favorite_black_36dp")
        }
        
        let desc: UILabel = cell.contentView.viewWithTag(descriptionTag) as! UILabel
        desc.text = itemEntity?.description
        
        let toolContainer = cell.contentView.viewWithTag(self.toolContainerTag)
        toolContainer?.addTopBorderWithColor(UIColor.lightGrayColor(), width: 0.5)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }

    
    
    @IBAction func tapFavoriteItem(sender: AnyObject) {
        guard let alreadyFavorite = self.itemEntity?.isFavorited else {
            return
        }
        guard isSending == false else{
            return
        }
        
        let completeHandler = { (response: Result<GenericResult, NSError>) in
            switch response {
            case .Success(let result):
                self.isSending = false
                print(result.errors)
                print(result)
                if let errors = result.errors as? Dictionary<String, AnyObject> {
                    self.showFailedAlert(errors)
                    return
                }else{
                    self.toggleFavoriteState(!alreadyFavorite)
                    self.itemEntity!.isFavorited = !alreadyFavorite
                }
            case .Failure(let error):
                self.isSending = false
                print("failure \(error)")
                self.simpleAlertDialog(NSLocalizedString("Prompt.Favorite.Failed", comment: ""), message: nil)
            }
        }
        
        if alreadyFavorite {
            self.isSending = true
            API.call(Endpoint.Favorite.UnFavoriteItem(itemId: self.itemEntity!.id!), completion: completeHandler)
        }else{
            self.isSending = true
            API.call(Endpoint.Favorite.FavoriteItem(itemId: self.itemEntity!.id!), completion: completeHandler)
        }
    }
    
    
    
    
    func toggleFavoriteState(isFavorite: Bool){
        guard let favoriteImage = self.headerCell?.contentView.viewWithTag(favoriteImageTag) as? UIImageView else{
            return
        }
        
        if isFavorite {
            favoriteImage.image = UIImage(named: "ic_favorite_pink_300_36dp")
        }else{
            favoriteImage.image = UIImage(named: "ic_favorite_black_36dp")
        }
    }
    
    
    @IBAction func tapComment(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Comment", bundle: nil)
        let next: CommentViewController = storyboard.instantiateInitialViewController() as! CommentViewController
        next.itemId = self.itemEntity!.id!
        
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    
    
    func setSection0RowCount(item: ItemEntity){
        let isList = item.isList ?? false
        let isGarbage = item.isGarbage ?? false
        // 通常ヘッダーがあるので、最低row1行必要
        
        var result: Int = 1
        
        if !isList || (item.owner!.id != self.userId) || isGarbage {
            // 自分のじゃないアイテム、またはリストじゃない
            // (タイマーを追加できないアイテム)
            self.timerState = .CanNotHaveTimer
        }else if let timers = item.timers where !timers.isEmpty {
            // タイマーあり
            // タイマーヘッダー(1)とタイマーの数だけ
            result = result + 1 + timers.count
            if timers.count < TimerPresenter.MAX_TIMERS_PER_LIST {
                // 追加ボタンを置くため
                result = result + 1
                self.timerState = .CanAddMoreTimer
            }else{
                self.timerState = .HaveTimerMax
            }
            
        }else{
            // タイマーなし(タイマーヘッダーと追加ボタンを置く)
            result = result + 1 + 1
            self.timerState = .NoTimer
        }
        self.section0rows = result

    }
    
    func getTimerCell(indexPath: NSIndexPath) -> UITableViewCell {
        guard 2...4 ~= indexPath.row else {
            return UITableViewCell(style: .Default, reuseIdentifier: "cell")
        }
        
        switch self.timerState{
        case .CanAddMoreTimer:
            let index = self.itemEntity!.timers!.count - (indexPath.row - 2)
            if 1...2 ~= index {
                let cell : UITableViewCell = baseTable.dequeueReusableCellWithIdentifier("timerCell")!
                self.setTimerDescription(cell, timer: self.itemEntity!.timers![indexPath.row - 2])
                return cell
            }else{
                let cell = baseTable.dequeueReusableCellWithIdentifier("timerAddButton")!
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                return cell
            }
        case .HaveTimerMax:
            let cell : UITableViewCell = baseTable.dequeueReusableCellWithIdentifier("timerCell")!
            self.setTimerDescription(cell, timer: self.itemEntity!.timers![indexPath.row - 2])
            return cell
        case .NoTimer:
            let cell = baseTable.dequeueReusableCellWithIdentifier("timerAddButton")!
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        case .CanNotHaveTimer:
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
            cell.userInteractionEnabled = false
            return cell
        }
    }
    
    func setTimerDescription(cell: UITableViewCell, timer: TimerEntity){
        let timerName: UILabel = cell.viewWithTag(timerNameTag) as! UILabel
        let timerRepeat: UILabel = cell.viewWithTag(timerRepeatTag) as! UILabel
        let timerAlarm: UILabel = cell.viewWithTag(timerAlarmTag) as! UILabel
        let timerProgress: UIProgressView = cell.viewWithTag(timerProgressTag) as! UIProgressView

        let noticePrompt = (timer.overDueFrom == nil) ? NSLocalizedString("Prompt.Timer.NoticeAt", comment: "") : NSLocalizedString("Prompt.Timer.NoticeAgainAt", comment: "")
        let percentage = timer.getPercentageUntilDueDate()
        let weekday = DateTimeFormatter.getWeekday(timer.nextDueAt!)
        let formatStr = String(format: NSLocalizedString("Format.Timer.MDHM", comment: ""), weekday)
        timerName.text = timer.name
        timerRepeat.text = timer.getIntervalString() + NSLocalizedString("Prompt.Timer.NoticeAt", comment: "") + " " + timer.getRemainingTimeString()
        //timerRemaining.text = timer.getRemainingTimeString()
        timerAlarm.text = DateTimeFormatter.getStrFromDate(timer.nextDueAt!, format: formatStr) + noticePrompt
        timerProgress.progress = percentage
        timerProgress.tintColor = timer.getProgressBarColor(percentage)
    }
    
    func getTimerActionAlert(timer: TimerEntity) -> XLActionController {
        
        let actionController: XLActionController = XLActionController()
        
        actionController.addAction(Action(ActionData(title: NSLocalizedString("Prompt.Timer.DoneNow", comment: ""), subtitle: NSLocalizedString("Prompt.Timer.DoneNow.Subtext", comment: ""), image: UIImage(named: "ic_done_black_36dp")!, id: 0), style: .Default, handler: { action in
            
            let repeatType = TimerEntity.TimerRepeatBy(rawValue: timer.repeatBy!)!
            let next: NSDate
            switch repeatType {
            case .ByDay:
                next = TimerPresenter.getNextDueAtFromMonth(timer.nextDueAt!, monthInterval: TimerEntity.TimerRepeatByDayInterval(rawValue: timer.repeatMonthInterval!)!, dayOfMonth: timer.repeatDayOfMonth!)
            case .ByWeek:
                next = TimerPresenter.getNextDueAtFromWeek(timer.nextDueAt!, weekInterval: TimerEntity.TimerRepeatByWeekInterval(rawValue: timer.repeatWeek!)!, weekday: DayOfWeek(rawValue: timer.repeatDayOfWeek!)!)
            }
            
            let message = String(format: NSLocalizedString("Prompt.Timer.DoneNow.Detail", comment: ""), DateTimeFormatter.getFullStr(next))
            let alert: UIAlertController = UIAlertController(title: NSLocalizedString("Prompt.Timer.DoneNow", comment: ""), message: message, preferredStyle:  UIAlertControllerStyle.Alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Ok", comment: ""), style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
                print("OK")
                
                let spinnerAlert = self.showConnectingSpinner()
                
                let tmpNext = timer.nextDueAt
                timer.nextDueAt = next
                
                API.call(Endpoint.Timer.Done(timerId: timer.id!, doneDate: nil)){ response in
                    switch response {
                    case .Success(let result):
                        
                        spinnerAlert.dismissViewControllerAnimated(false, completion: {
                            if let errors = result.errors as? Dictionary<String, AnyObject> {
                                self.showFailedAlert(errors)
                                return
                            }
                            
                            timer.overDueFrom = nil
                            self.changeTimer()
                            
                            print(result)
                            print("success!!")
                        })
                        
                    case .Failure(let error):
                        print(error)
                        
                        timer.nextDueAt = tmpNext
                        spinnerAlert.dismissViewControllerAnimated(false, completion: nil)
                        self.simpleAlertDialog(NSLocalizedString("Prompt.FailureToAceess", comment: ""), message: nil)
                        
                    }
                }
                
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler:{
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })
            
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(alert, animated: true, completion: nil)
                
            })
        }))
        
        actionController.addAction(Action(ActionData(title: NSLocalizedString("Prompt.Timer.AlreadyDone", comment: ""), subtitle: NSLocalizedString("Prompt.Timer.AlreadyDone.Subtext", comment: ""), image: UIImage(named: "ic_event_black_36dp")!, id: 1), style: .Default, handler: { action in
            let storyboard: UIStoryboard = UIStoryboard(name: "TimerForm", bundle: nil)
            let next: TimerChangeDueViewController = storyboard.instantiateViewControllerWithIdentifier("timer_change_due") as! TimerChangeDueViewController
            next.changeType = TimerChangeDueViewController.ChangeType.AlreadyDone
            next.timer = timer
            next.timerChangeDelegate = self
            
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(next, animated: true, completion: nil)
            })
        }))
        
        actionController.addAction(Action(ActionData(title: NSLocalizedString("Prompt.Timer.DoLater", comment: ""), subtitle: NSLocalizedString("Prompt.Timer.DoLater.Subtext", comment: ""), image: UIImage(named: "ic_redo_black_36dp")!, id: 2), style: .Default, handler: { action in
            let storyboard: UIStoryboard = UIStoryboard(name: "TimerForm", bundle: nil)
            let next: TimerChangeDueViewController = storyboard.instantiateViewControllerWithIdentifier("timer_change_due") as! TimerChangeDueViewController
            next.changeType = TimerChangeDueViewController.ChangeType.DoLater
            next.timer = timer
            next.timerChangeDelegate = self
            
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(next, animated: true, completion: nil)
            })
        }))
        
        actionController.addAction(Action(ActionData(title: NSLocalizedString("Prompt.Timer.Config", comment: ""), subtitle: "", image: UIImage(named: "ic_settings_black_36dp")!, id: 3), style: .Default, handler: { action in
            let storyboard: UIStoryboard = UIStoryboard(name: "TimerForm", bundle: nil)
            let next: TimerConfigViewController = storyboard.instantiateViewControllerWithIdentifier("timer_config") as! TimerConfigViewController
            next.timer = timer
            next.timerDelegate = self
            
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(next, animated: true, completion: nil)
            })
        }))
        
        actionController.headerData = timer.name
        
        return actionController
    }

}

extension ItemViewController: TimerConfigViewDelegate {
    func endTimer(timer: TimerEntity){
        if let index = self.itemEntity!.timers!.indexOf({$0 === timer}) {
            self.itemEntity!.timers!.removeAtIndex(index)
            self.setSection0RowCount(self.itemEntity!)
            self.baseTable.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        }
    }
}

extension ItemViewController: TimerViewChangeDelegate {
    func addTimer(timer: TimerEntity) {
        self.itemEntity!.timers!.append(timer)
        self.setSection0RowCount(self.itemEntity!)
        self.baseTable.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
    }
    
    func changeTimer(){
        self.baseTable.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
    }
}

protocol TimerConfigViewDelegate: class {
    func endTimer(timer: TimerEntity)
}

protocol TimerViewChangeDelegate: class {
    func addTimer(timer: TimerEntity)
    func changeTimer()
}


