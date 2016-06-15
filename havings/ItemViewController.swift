//
//  ItemViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/05/27.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

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
    
    private var segState : Int = 0
    private var itemEntity: ItemEntity?
    private var loadingNextItem: Bool = false
    private var loadingNextImage: Bool = false
    
    private var headerHeight: Double = 0.0
    private var scrollPositionBySegState = [
        0: 0.0,
        1: 0.0,
        2: 0.0
    ]
    
    private var headerCell: UITableViewCell? = nil
    
    @IBOutlet var baseTable: UITableView!
    var segment : UISegmentedControl?
    
    @IBAction func segtap(sender: AnyObject) {
        print(6786)
        let seg : UISegmentedControl = sender as! UISegmentedControl
        print(seg.selectedSegmentIndex)
        
        //print("current section \(baseTable.indexPathsForVisibleRows?.last?.section)")
        //print("current section \(baseTable.indexPathsForVisibleRows?.first?.section)")

        
        print("contentOffset before \(baseTable.contentOffset.y)")
        let offset = baseTable.contentOffset
        //scrollPositionBySegState[self.segState] = baseTable.contentOffset
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
            //scrollPositionBySegState[segState]!["current"] = 0
        }
        
        print(headerHeight)
        print(offsetY)
        print(scrollPositionBySegState[segState]!)
        
        self.segState = seg.selectedSegmentIndex
        self.loadingNextItem = true
        self.loadingNextImage = true
        
        let top = NSIndexPath(forRow: 0, inSection: 0)
        //self.baseTable.scrollToRowAtIndexPath(aa, atScrollPosition: .Top, animated: true)
        //self.baseTable.setContentOffset(CGPoint(x: 0, y: 100), animated: false)
        self.baseTable.scrollToRowAtIndexPath(top, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        baseTable.reloadData(){
            print("contentOffset after \(self.baseTable.contentOffset.y)")
            
            self.baseTable.layoutIfNeeded()
            print(self.scrollPositionBySegState[self.segState]!)

            if underSegcon {
                
                
                if self.scrollPositionBySegState[self.segState] < 1 {
                    self.baseTable.setContentOffset(CGPoint(x:0, y: self.headerHeight - 64), animated: false)
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

        API.call(Endpoint.Item.Get(id: 2)) { response in
            switch response {
            case .Success(let result):
                print(result.name)
                print(result.id)
                print(result.owningItems?.count)
                if let ii = result.owningItems?.first {
                    print(ii.name)
                    print(ii.id)
                }
                
                self.itemEntity = result
                self.baseTable.reloadData()
            case .Failure(let error):
                print("failure \(error)")
            }
        }
        let cell : ItemImageCell = baseTable.dequeueReusableCellWithIdentifier("itemImages") as! ItemImageCell
        cell.layoutSubviews()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return section == 0 ? 0 : 50
        if section == 0 {
            return 1
        }else if let item = itemEntity {
            if segState == 0 {
                if item.owningItems != nil {
                    return (item.owningItems?.count)!
                }else{
                    return 0
                }
            }else if segState == 1 {
                if item.itemImages?.images != nil {
                    return (item.itemImages!.images!.count)
                }else{
                    return 0
                }
            }else {
                return 1
            }
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = indexPath.section == 0 ? "hh" : "itemCell"
        if indexPath.section == 0 {
            let cell : UITableViewCell = baseTable.dequeueReusableCellWithIdentifier(identifier)! as UITableViewCell
            
            if itemEntity != nil {
                if self.headerCell == nil {
                    self.headerCell = setItemData(cell)
                }
            }
            
            return headerCell ?? cell
            
        }else if segState == 0{
            
            let cell : ItemTableViewCell = baseTable.dequeueReusableCellWithIdentifier(identifier) as! ItemTableViewCell
            let item = itemEntity.flatMap{(i: ItemEntity) -> ItemEntity? in
                i.owningItems?[indexPath.row] ?? nil
            }
            
            if let i = item {
                cell.setItem(i)
            }
            
            return cell
        }else if segState == 1 {
            let cell : ItemImageCell = baseTable.dequeueReusableCellWithIdentifier("itemImages") as! ItemImageCell
            let itemImage: ItemImageEntity? = itemEntity?.itemImages?.images.flatMap{$0[indexPath.row] ?? nil}
            
            if itemImage != nil {
                cell.setItem(itemImage!)                
            }
            
            return cell
        }else {
            let cell = baseTable.dequeueReusableCellWithIdentifier("simpleChartCell") as! SimpleTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.setNavigationController(self.navigationController)
            cell.setChart(self.itemEntity?.countProperties)
            return cell
        }

    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            print("page header")
            return nil
        }else{
            print("segment control header")
            let cell : UITableViewCell = baseTable.dequeueReusableCellWithIdentifier("segmentControl")!
            let segcon = cell.viewWithTag(segmentControlTag) as! UISegmentedControl
            segcon.selectedSegmentIndex = segState
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        baseTable.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = self.baseTable.contentOffset.y + self.baseTable.bounds.size.height
        let reachBottom = offset >= self.baseTable.contentSize.height

        if reachBottom {
            print("reach bottom \(segState)")
            switch segState {
            case 0:
                let nextItem = itemEntity?.hasNextItem ?? false
                if nextItem && !loadingNextItem {
                    let footer = baseTable.dequeueReusableCellWithIdentifier("header")!
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
            case 1:
                let nextImages = itemEntity?.itemImages?.hasNextImage ?? false
                if nextImages && !loadingNextImage {
                    let footer = baseTable.dequeueReusableCellWithIdentifier("header")!
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
        if itemEntity?.isList?.boolValue == true {
            itemTypeIcon.image = UIImage(named: "icon_type_list_white")
        }else{
            itemTypeIcon.image = UIImage(named: "icon_type_item_white")
        }
        
        let itemName: UILabel = cell.contentView.viewWithTag(itemNameTag) as! UILabel
        itemName.text = itemEntity?.name!
        
        let itemCount: UILabel = cell.contentView.viewWithTag(itemCountTag) as! UILabel
        itemCount.text = String(itemEntity?.count ?? 0)
        
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
        
        let tagList: TagListView = cell.contentView.viewWithTag(tagListTag) as! TagListView
        tagList.textFont = UIFont.systemFontOfSize(17)
        itemEntity?.tags?.forEach{
            tagList.addTag($0)
        }
        
        let desc: UILabel = cell.contentView.viewWithTag(descriptionTag) as! UILabel
        desc.text = itemEntity?.description
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        print("777777777777777")
        print(cell.bounds.height)
        
        return cell
    }

}
