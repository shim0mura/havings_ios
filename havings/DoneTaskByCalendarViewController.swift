//
//  DoneTaskByCalendarViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/19.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import FSCalendar

class DoneTaskByCalendarViewController: UIViewController {
    
    @IBOutlet weak var calendarView: FSCalendar!
    
    @IBOutlet weak var tableView: UITableView!

    var taskByEvent: [NSDate: [(timer: TimerEntity, itemName: String, actrualDate: NSDate)]] = [:]
    
    private let taskNameTag: Int = 10
    private let taskRepeatTag: Int = 11
    private let taskListTag: Int = 12
    private let taskDoneTag: Int = 13
    private let dateTag: Int = 20
    private let eventCountTag: Int = 21
    
    private var selectedDate: NSDate = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.calendarView.dataSource = self
        self.calendarView.delegate = self

        calendarView.appearance.cellShape = .Rectangle
        calendarView.allowsSelection = true
        calendarView.allowsMultipleSelection = false
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.calendarView.reloadData()
    }

}

extension DoneTaskByCalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func calendar(calendar: FSCalendar, appearance: FSCalendarAppearance, fillColorForDate date: NSDate) -> UIColor? {
        
        if let content = self.taskByEvent[date] {
            if content.count == 1 {
                return UIColor(red: 0.55, green: 0.94, blue: 0.29, alpha: 0.25)
            }else if content.count == 2 {
                return UIColor(red: 0.55, green: 0.94, blue: 0.29, alpha: 0.6)
            }else{
                return UIColor(red: 0.55, green: 0.94, blue: 0.29, alpha: 0.9)
            }
        }else{
            return nil
        }
    }
    
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate) {
        self.selectedDate = date
        self.tableView.reloadData()
    }

}

extension DoneTaskByCalendarViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskByEvent[self.selectedDate]?.count ?? 0
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
        
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("doneEvent")! as UITableViewCell
        let task = self.taskByEvent[self.selectedDate]![indexPath.row]
        let timer: UILabel = cell.viewWithTag(self.taskNameTag) as! UILabel
        let repeating: UILabel = cell.viewWithTag(self.taskRepeatTag) as! UILabel
        let list: UILabel = cell.viewWithTag(self.taskListTag) as! UILabel
        let date: UILabel = cell.viewWithTag(self.taskDoneTag) as! UILabel
        
        timer.text = task.timer.name
        repeating.text = task.timer.getIntervalString()
        list.text = task.itemName
        
        date.text = String(format: NSLocalizedString("Prompt.DoneTask.DoneDate", comment: ""), DateTimeFormatter.getFullStr(task.actrualDate))
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (self.taskByEvent.count > 0) ? 1 : 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("sectionHeader")! as UITableViewCell
        let task = self.taskByEvent[self.selectedDate]
        
        let date: UILabel = cell.viewWithTag(self.dateTag) as! UILabel
        let eventCount: UILabel = cell.viewWithTag(self.eventCountTag) as! UILabel
        date.text = String(format: NSLocalizedString("Prompt.DoneTask.DoneByDay", comment: ""), DateTimeFormatter.getStrWithWeekday(selectedDate))
        let count = task?.count ?? 0
        eventCount.text = "\(count)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}