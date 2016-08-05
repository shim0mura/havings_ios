//
//  DumpItemListViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/16.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class DumpItemListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var userId: Int = 0
    private var loadingNextItem: Bool = true
    private var parentItem: ItemEntity = ItemEntity()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        self.tableView.estimatedRowHeight = 110
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.registerNib(UINib(nibName: "ItemTableViewCell", bundle: nil), forCellReuseIdentifier: "itemCell")
        
        self.reloadDumpItems(0, callback: {})
        
        self.title = NSLocalizedString("Prompt.DumpList", comment: "")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadDumpItems(page: Int, callback: () -> Void){
        self.loadingNextItem = true
        API.call(Endpoint.Item.GetDumpItem(userId: self.userId, page: page)) { response in
            self.loadingNextItem = false
            switch response {
            case .Success(let result):
                
                self.parentItem.hasNextItem = result.hasNextItem
                self.parentItem.nextPageForItem = result.nextPageForItem
                self.parentItem.owningItems = [self.parentItem.owningItems, result.owningItems].flatMap{$0}.flatMap{$0}
                
                self.tableView.reloadData()
                
                callback()
            case .Failure(let error):
                print("failure \(error)")
            }
        }
    }

}

extension DumpItemListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.loadingNextItem {
            return 1
        }else{
            return self.parentItem.owningItems?.count ?? 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if self.loadingNextItem {
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("loading")! as UITableViewCell
            return cell
        }else{
            let cell : ItemTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("itemCell") as! ItemTableViewCell
            
            if let item = self.parentItem.owningItems?[indexPath.row] {
                cell.setItem(item)
            }
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let nextItem = self.parentItem.owningItems![indexPath.row]
        let sb: UIStoryboard = UIStoryboard(name: "Item", bundle: nil)
        let next = sb.instantiateInitialViewController() as! ItemViewController
        next.itemId = nextItem.id
        self.navigationController?.pushViewController(next, animated: true)
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = self.tableView.contentOffset.y + self.tableView.bounds.size.height
        let reachBottom = offset >= self.tableView.contentSize.height
        
        if reachBottom {
            
            let nextItem = self.parentItem.hasNextItem ?? false
            if nextItem && !loadingNextItem {
                let footer = tableView.dequeueReusableCellWithIdentifier("loading")!
                self.loadingNextItem = true
                self.tableView.tableFooterView = footer
                self.reloadDumpItems((self.parentItem.nextPageForItem ?? 0), callback: {
                    self.tableView.tableFooterView = nil
                })
            }
        }
    }
    
}

extension DumpItemListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "icon_type_item")
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text: String = NSLocalizedString("Prompt.User.Dump.Empty", comment: "")
        
        let font = UIFont.systemFontOfSize(16)
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName : UIColor.darkGrayColor()])
    }
}
