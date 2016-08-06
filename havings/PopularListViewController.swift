//
//  PopularListViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/21.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class PopularListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var pickup: PickupEntity = PickupEntity()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.registerNib(UINib(nibName: "ItemTableViewCell", bundle: nil), forCellReuseIdentifier: "itemCell")
        self.title = NSLocalizedString("Prompt.PopularList", comment: "")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension PopularListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return self.pickup.popularList?.count ?? 0
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        
        // TODO: SearchViewControllerと共通化
        let cell : ItemTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("itemCell") as! ItemTableViewCell
        let item = self.pickup.popularList![indexPath.row]
        cell.setItem(item)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("touch!!")
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let item = self.pickup.popularList![indexPath.row]
        if let id = item.id {
            let next = UIStoryboard(name: "Item", bundle: nil).instantiateInitialViewController() as! ItemViewController
            next.itemId = id
            self.navigationController?.pushViewController(next, animated: true)
        }
        
    }
}
