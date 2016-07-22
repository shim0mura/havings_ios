//
//  SearchResultViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/21.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class SearchResultViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var searchResult: SearchResultEntity = SearchResultEntity()
    var tag: String = ""
    private var loadingNextItem: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.registerNib(UINib(nibName: "ItemTableViewCell", bundle: nil), forCellReuseIdentifier: "itemCell")
        
        if !tag.isEmpty {
            let footer = tableView.dequeueReusableCellWithIdentifier("loading")!
            self.loadingNextItem = true
            self.tableView.tableFooterView = footer.contentView
            
            self.searchResult.getNextPage(tag, page: 1, callback: {
                self.loadingNextItem = false
                self.tableView.tableFooterView = nil
                self.tableView.reloadData()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SearchResultViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return self.searchResult.items?.count ?? 0
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        
        // TODO: SearchViewControllerと共通化
        let cell : ItemTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("itemCell") as! ItemTableViewCell
        let item = self.searchResult.items![indexPath.row]
        cell.setItem(item)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("touch!!")
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let item = self.searchResult.items?[indexPath.row]
        if let id = item?.id {
            let next = UIStoryboard(name: "Item", bundle: nil).instantiateInitialViewController() as! ItemViewController
            next.itemId = id
            self.navigationController?.pushViewController(next, animated: true)
        }
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = self.tableView.contentOffset.y + self.tableView.bounds.size.height
        let reachBottom = offset >= self.tableView.contentSize.height
        
        if reachBottom {
            
            let nextItem = self.searchResult.hasNextPage ?? false
            if nextItem && !loadingNextItem {
                let footer = tableView.dequeueReusableCellWithIdentifier("loading")!
                self.loadingNextItem = true
                self.tableView.tableFooterView = footer.contentView
                self.searchResult.getNextPage(tag, page: (self.searchResult.currentPage ?? 0), callback: {
                    self.tableView.tableFooterView = nil
                    self.tableView.reloadData()
                })
            }
        }
    }
    
}