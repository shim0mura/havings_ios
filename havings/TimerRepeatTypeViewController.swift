//
//  TimerRepeatTypeViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/05.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class TimerRepeatTypeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var timer: TimerEntity = TimerEntity()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.title = NSLocalizedString("Prompt.Timer.RepeatTypeSelect", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let index = tableView.indexPathForSelectedRow?.row
        print(segue.destinationViewController)
        if segue.destinationViewController is TimerRepeatEditViewController {
            let next = segue.destinationViewController as! TimerRepeatEditViewController
            next.repeatType = (index == 1) ? TimerEntity.TimerRepeatBy.ByDay : TimerEntity.TimerRepeatBy.ByWeek
            next.timer = self.timer
        }
    }

}

extension TimerRepeatTypeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("noRepeat")! as UITableViewCell
        //let cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
            cell.textLabel?.text = "なし"
        
            return cell
        }else if indexPath.row == 1 {
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("repeatType")! as UITableViewCell
            cell.textLabel?.text = TimerEntity.TimerRepeatBy.ByDay.description
            cell.accessoryType = .DisclosureIndicator
            return cell
        }else{
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("repeatType")! as UITableViewCell
            cell.textLabel?.text = TimerEntity.TimerRepeatBy.ByWeek.description
            cell.accessoryType = .DisclosureIndicator
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    /*
     func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
     return 0
     }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "セクション \(section)"
    }
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return " "
    }
    */
    
    
}
