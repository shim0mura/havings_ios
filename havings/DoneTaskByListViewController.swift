//
//  DoneTaskByListViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/19.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class DoneTaskByListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let taskNameTag: Int = 10
    private let taskRepeatTag: Int = 11
    private let taskListTag: Int = 12
    private let taskCountTag: Int = 13
    private let taskActiveTag: Int = 14
    private let taskDoneDateTag: Int = 10
    
    var taskByTupple: [(task: TaskEntity, list: ItemEntity)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension DoneTaskByListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let done = self.taskByTupple[section].task
        return done.events?.count ?? 0
        
        //return self.taskWrapper.tasks?[section].events?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /*
        if self.loadingNextItem {
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("loading")! as UITableViewCell
            return cell
        }else{
            let cell : ItemTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("itemCell") as! ItemTableViewCell
            
            if let item = self.parentItem.owningItems?[indexPath.row] {
                cell.setItem(item)
            }
            return cell
        }*/
        //let cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
        //cell.textLabel?.text = "row \(indexPath.row)"
        
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("date")! as UITableViewCell
        let task = self.taskByTupple[indexPath.section].task
        let date: UILabel = cell.viewWithTag(self.taskDoneDateTag) as! UILabel
        date.text = String(format: NSLocalizedString("Prompt.DoneTask.DoneDate", comment: ""), DateTimeFormatter.getFullStr(task.events![indexPath.row]))
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.taskByTupple.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("taskHeader")! as UITableViewCell
        let task = self.taskByTupple[section]
        let taskName: UILabel = cell.viewWithTag(self.taskNameTag) as! UILabel
        let taskRepeat: UILabel = cell.viewWithTag(self.taskRepeatTag) as! UILabel
        let taskList: UILabel = cell.viewWithTag(self.taskListTag) as! UILabel
        let taskCount: UILabel = cell.viewWithTag(self.taskCountTag) as! UILabel
        let taskActive: UIImageView = cell.viewWithTag(self.taskActiveTag) as! UIImageView
        
        taskName.text = task.task.timer?.name
        taskRepeat.text = task.task.timer?.getIntervalString()
        taskList.text = task.list.name
        let count: Int = task.task.events?.count ?? 0
        taskCount.text = "\(count)"
        if task.task.timer?.isActive == false {
            taskActive.hidden = false
        }else if task.task.timer?.isActive == true {
            taskActive.hidden = true
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 68
    }
    
}