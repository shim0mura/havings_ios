//
//  TimerListViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/24.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class TimerListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var timers: [TimerEntity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        
        self.title = NSLocalizedString("Prompt.TimerList", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TimerListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timers.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("timerCell")! as UITableViewCell
        let t = self.timers[indexPath.row]
        TimerPresenter.setTimerDescription(cell, timer: t)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let timer = self.timers[indexPath.row]
        if let id = timer.listId {
            let storyboard: UIStoryboard = UIStoryboard(name: "Item", bundle: nil)
            let next: ItemViewController = storyboard.instantiateInitialViewController() as! ItemViewController
            next.itemId = id
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
}