//
//  UserFavoriteViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/16.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class UserFavoriteViewController: UIViewController, PostAlertUtil {

    private enum FavoriteType {
        case Item
        case Image
        
        mutating func setType(index: Int){
            if index == 0 {
                self = .Item
            }else if index == 1 {
                self = .Image
            }
        }
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    var userId: Int = 0
    
    private let itemImageTag: Int = 50
    private let itemImageNameTag: Int = 51
    private let itemImageFavoriteCountTag: Int = 52
    
    private var loadingNextItem: Bool = true
    private var loadingNextImage: Bool = true
    private var favoriteItem: ItemEntity = ItemEntity()
    private var favoriteImage: ItemImageListEntity = ItemImageListEntity()
    private var favoriteType: FavoriteType = .Item
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        self.tableView.estimatedRowHeight = 110
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.registerNib(UINib(nibName: "ItemTableViewCell", bundle: nil), forCellReuseIdentifier: "itemCell")

        self.initFavoriteItem()
        self.tableView.tableFooterView = UIView()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func segmentChange(sender: UISegmentedControl) {
        self.favoriteType.setType(sender.selectedSegmentIndex)
        initFavoriteImage()
        self.tableView.reloadData()
        if self.tableView.numberOfRowsInSection(0) != 0 {
            let top = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.scrollToRowAtIndexPath(top, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        }
    }
    
    func initFavoriteItem(){
        if self.favoriteItem.hasNextItem == nil && self.favoriteItem.nextPageForItem == nil {
            self.favoriteItem.getNextFavoriteItem(userId: self.userId, page: 0, callback: {_ in
                self.loadingNextItem = false
                self.tableView.reloadData()
            })
        }
    }
    
    func initFavoriteImage(){
        if self.favoriteImage.hasNextImage == nil && self.favoriteImage.nextPageForImage == nil {
            self.favoriteImage.getNextFavoriteImage(userId: self.userId, page: 0, callback: {_ in
                self.loadingNextImage = false
                self.tableView.reloadData()
            })
        }
    }
}

extension UserFavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.favoriteType {
        case .Item:
            if self.loadingNextItem {
                return 1
            }else{
                return self.favoriteItem.owningItems?.count ?? 0
            }
        case .Image:
            if self.loadingNextImage {
                return 1
            }else{
                return self.favoriteImage.images?.count ?? 0
            }
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch self.favoriteType {
        case .Item:
            if self.loadingNextItem {
                let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("loading")! as UITableViewCell
                return cell
            }else{
                
                let cell : ItemTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("itemCell") as! ItemTableViewCell
                
                if let item = self.favoriteItem.owningItems?[indexPath.row] {
                    cell.setItem(item)
                }
                return cell
            }
        case .Image:
            if self.loadingNextImage {
                let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("loading")! as UITableViewCell
                return cell
            }else{
                
                let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("itemImages")!
                
                guard let image = self.favoriteImage.images?[indexPath.row] else {
                    return cell
                }
                
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
            }
        }
        
        
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch self.favoriteType {
        case .Item:
            let nextItem = self.favoriteItem.owningItems![indexPath.row]
            let sb: UIStoryboard = UIStoryboard(name: "Item", bundle: nil)
            let next = sb.instantiateInitialViewController() as! ItemViewController
            next.itemId = nextItem.id
            self.navigationController?.pushViewController(next, animated: true)
        case .Image:
            let storyboard: UIStoryboard = UIStoryboard(name: "ItemImage", bundle: nil)
            let next: ItemImageViewController = storyboard.instantiateViewControllerWithIdentifier("item_image") as! ItemImageViewController
            next.itemImageEntity = self.favoriteImage.images![indexPath.row]
            
            self.navigationController?.pushViewController(next, animated: true)
        }

    }
    
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = self.tableView.contentOffset.y + self.tableView.bounds.size.height
        let reachBottom = offset >= self.tableView.contentSize.height
        
        if reachBottom {

            switch self.favoriteType {
            case .Item:
                let nextItem = self.favoriteItem.hasNextItem ?? false
                if nextItem && !loadingNextItem {
                    let footer = tableView.dequeueReusableCellWithIdentifier("loading")!
                    self.loadingNextItem = true
                    self.tableView.tableFooterView = footer
                    self.favoriteItem.getNextFavoriteItem(userId: self.userId, page: self.favoriteItem.nextPageForItem ?? 0){result in
                        self.tableView.tableFooterView = nil
                        self.tableView.reloadData(){
                            self.loadingNextItem = false
                        }
                    }
                }
            case .Image:
                let nextImages = self.favoriteImage.hasNextImage ?? false
                if nextImages && !self.loadingNextImage {
                    let footer = self.tableView.dequeueReusableCellWithIdentifier("loading")!
                    footer.hidden = false
                    self.loadingNextImage = true
                    self.tableView.tableFooterView = footer
                    
                    self.favoriteImage.getNextFavoriteImage(userId: self.userId, page: self.favoriteImage.nextPageForImage ?? 0){result in
                        self.tableView.tableFooterView = nil
                        self.tableView.reloadData(){
                            self.loadingNextImage = false
                        }
                    }
                }
            }
        }
        
    }
}

extension UserFavoriteViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "icon_type_item")
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text: String
        switch self.favoriteType {
        case .Item:
            text = NSLocalizedString("Prompt.User.Favorite.Item.Empty", comment: "")
        case .Image:
            text = NSLocalizedString("Prompt.User.Favorite.Image.Empty", comment: "")
        }
        
        let font = UIFont.systemFontOfSize(16)
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName : UIColor.darkGrayColor()])
    }
}