//
//  DashboardViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/20.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import Charts
import FSCalendar

class DashboardViewController: UIViewController, PostAlertUtil, ChartViewDelegate {

    private let emptyLabelTag: Int = 10
    private let pieChartTag: Int = 20
    private let itemTypeImageTag: Int = 10
    private let itemTypeTag: Int = 11
    private let itemTypeCountTag: Int = 12
    private let itemCategoryTag: Int = 13
    private let itemCategoryCountTag: Int = 14
    private let itemDetailCategoryTag: Int = 15
    private let itemDetailCategoryCountTag: Int = 16
    private let doneTaskCalendarTag: Int = 40
    private let doneTaskHeaderTag: Int = 41
    private let doneTaskCountTag: Int = 42
    private let doneTaskNameTag: Int = 43
    private let doneTaskRepeatTag: Int = 44
    private let doneTaskItemNameTag: Int = 45
    private let doneTaskDateTag: Int = 46
    private let moreTimerButtonTag: Int = 60
    
    private let maxTimer: Int = 3
    
    private var beforeLoadingChart: Bool = true
    private var beforeLoadingTimers: Bool = true
    private var beforeLoadingTasks: Bool = true
    
    private var pieChartCell: UITableViewCell?
    private var taskCalendarCell: UITableViewCell?
    
    private var leftBarButton: ENMBadgedBarButtonItem?
    private var timers: [TimerEntity] = []
    @IBOutlet weak var tableView: UITableView!
    
    private var percentages: [ItemPercentageEntity] = [] {
        didSet {
            percentages.forEach{
                var categories: [(category: ItemPercentageEntity, isDetail: Bool)] = []
                categories.append((category: $0, isDetail: false))
                $0.childs?.forEach{cat in
                    categories.append((category: cat, isDetail: false))
                    cat.childs?.forEach{detailCat in
                        categories.append((category: detailCat, isDetail: true))
                    }
                }
                
                self.percentageByCategory[$0.type!] = categories
            }
        }
    }
    
    private var percentageByCategory: [Int: [(category:ItemPercentageEntity, isDetail:Bool)]] = [:]
    private var taskWrapper: [DoneTaskWrapperEntity] = [] {
        didSet {
            self.taskByEvent = DoneTaskWrapperEntity.setEventByDate(taskWrapper)
        }
    }
    private var taskByEvent: [NSDate: [(timer: TimerEntity, itemName: String, actrualDate: NSDate)]] = [:]
    
    private var chartSelectedType: Int? = nil
    private var selectedDate: NSDate = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Prompt.Dashboard", comment: "")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        //self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let comps: NSDateComponents = calendar.components([.Year, .Month, .Day], fromDate: NSDate())
        self.selectedDate = NSDate(year: comps.year, month: comps.month, day: comps.day, region: TimerPresenter.gregorianByRegion)
        
        API.callArray(Endpoint.ItemPercentage.GetGraph) { response in
            switch response {
            case .Success(let result):
                self.percentages = result
                self.beforeLoadingChart = false
                self.tableView.reloadData()
            case .Failure(let error):
                self.simpleAlertDialog(NSLocalizedString("Prompt.ProfileEdit.FailedToGetUserInfo", comment: ""), message: nil)
                print("failure \(error)")
            }
        }
        
        API.callArray(Endpoint.Notification.GetUnreadCount){ response in
            switch response {
            case .Success(let result):
                let count = result.count
                self.leftBarButton?.badgeValue = "\(count)"
            case .Failure(let error):
                print(error)
            }
        }
        
        API.callArray(Endpoint.Timer.GetAll){ response in
            switch response {
            case .Success(let result):
                self.timers = result
                self.beforeLoadingTimers = false
                self.tableView.reloadData()
            case .Failure(let error):
                print(error)
            }
        }
        
        API.callArray(Endpoint.DoneTask.GetAllDoneTasks){ response in
            switch response {
            case .Success(let result):
                self.taskWrapper = result
                self.beforeLoadingTasks = false
                self.tableView.reloadData()
            case .Failure(let error):
                print(error)
            }
        }
        
        DefaultTagPresenter.migrateTag()

        setUpLeftBarButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpLeftBarButton() {
        let image = UIImage(named: "ic_notifications_white")
        let button = UIButton(type: .Custom)
        button.frame = CGRectMake(0.0, 0.0, 20, 20)
        
        button.setBackgroundImage(image, forState: UIControlState.Normal)
        button.addTarget(self,
                         action: #selector(DashboardViewController.toNotification),
                         forControlEvents: UIControlEvents.TouchUpInside)
        
        let newBarButton = ENMBadgedBarButtonItem(customView: button, value: "\(0)")
        self.leftBarButton = newBarButton
        navigationItem.rightBarButtonItem = self.leftBarButton
    }
    
    func toNotification(){
        self.leftBarButton?.badgeValue = "\(0)"

        let storyboard: UIStoryboard = UIStoryboard(name: "Notification", bundle: nil)
        let next = storyboard.instantiateInitialViewController()
        self.navigationController?.pushViewController(next!, animated: true)
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        
        let beforeCount = self.getChartSectionRowCount()
        self.chartSelectedType = entry.xIndex
        let afterCount = self.getChartSectionRowCount()
        
        self.reloadSection(0, beforeRowCount: beforeCount, afterRowCount: afterCount)
    }
    
    func reloadSection(section: Int, beforeRowCount: Int, afterRowCount: Int){
        let diff = beforeRowCount - afterRowCount
        if diff > 0 {
            var path: [NSIndexPath] = []
            for i in afterRowCount..<beforeRowCount {
                path.append(NSIndexPath(forRow: i, inSection: section))
            }
            self.tableView.deleteRowsAtIndexPaths(path, withRowAnimation: .Automatic)
        }else if diff < 0 {
            var path: [NSIndexPath] = []
            for i in beforeRowCount..<afterRowCount {
                path.append(NSIndexPath(forRow: i, inSection: section))
            }
            self.tableView.insertRowsAtIndexPaths(path, withRowAnimation: .Automatic)
        }
        
        var reloadPath: [NSIndexPath] = []
        for i in 1..<afterRowCount {
            reloadPath.append(NSIndexPath(forRow: i, inSection: section))
        }
        self.tableView.reloadRowsAtIndexPaths(reloadPath, withRowAnimation: .Automatic)
        self.tableView.scrollToRowAtIndexPath(reloadPath.first!, atScrollPosition: .Top, animated: true)
    }
    
    @IBAction func toAllTimers(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "TimerList", bundle: nil)
        let next: TimerListViewController = storyboard.instantiateInitialViewController() as! TimerListViewController
        next.timers = self.timers
        self.navigationController?.pushViewController(next, animated: true)
    }
    
}

extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            if self.beforeLoadingChart {
                return 1
            }else{
                return self.getChartSectionRowCount()
            }
        }else if section == 1 {
            if self.beforeLoadingTimers {
                return 1
            }else{
                if self.timers.count == 0 {
                    return 1
                }else if self.timers.count > self.maxTimer {
                    return self.maxTimer
                }else{
                    return self.timers.count
                }
            }
        }else if section == 2{
            if self.beforeLoadingTasks {
                return 1
            }else{
                return self.getDoneTaskSectionRowCount()
            }
        
        }else{
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell
        if indexPath.section == 0 {
        
            if self.beforeLoadingChart {
                cell = self.tableView.dequeueReusableCellWithIdentifier("loading")! as UITableViewCell
                return cell
            }else if indexPath.row == 0 {
                cell = self.tableView.dequeueReusableCellWithIdentifier("graph")! as UITableViewCell

                if self.pieChartCell == nil {
                    let graph: PieChartView = cell.viewWithTag(self.pieChartTag) as! PieChartView
                    
                    let target = self.percentages
                    var entries: [ChartDataEntry] = []
                    var strings: [String] = []
                    var colors: [UIColor] = []
                    for i in 0..<target.count {
                        let type = self.percentages[i]
                        let percent = type.percentage!
                        
                        if let typeCase = type.typeCase {
                            entries.append(ChartDataEntry(value: percent, xIndex: i))
                            
                            let typeStr = typeCase.getStr()
                            
                            strings.append(typeStr)
                            colors.append(typeCase.getColor())
                        }
                    }
                    
                    if entries.isEmpty {
                        graph.noDataText = NSLocalizedString("Prompt.Dashboard.PieChart.Empty", comment: "")
                        graph.clear()
                    }else{
                        let dataSet = PieChartDataSet(yVals:entries, label: "")
                        dataSet.setColors(colors, alpha: 1.0)
                        dataSet.valueTextColor = UIColor.blackColor()
                        dataSet.valueFormatter = PercentFormatter()
                        
                        graph.descriptionText = ""
                        graph.usePercentValuesEnabled = true
                        graph.delegate = self
                        graph.data = PieChartData(xVals: strings, dataSet: dataSet)
                    }
                    
                    self.pieChartCell = cell
                }
                return cell
                
            }else if let select = self.chartSelectedType where indexPath.row == 1 {
                
                cell = self.getTypeCell(self.percentages[select])
                
            }else if let select = self.chartSelectedType where indexPath.row >= 2 {

                let percentage = self.percentages[select]
                let byCategory = self.percentageByCategory[percentage.type!]
                let target = byCategory![indexPath.row - 1]
                if target.isDetail {
                    cell = self.getDetailCategoryCell(target.category)
                }else{
                    cell = self.getCategoryCell(target.category)
                }

            }else {
                cell = self.getTypeCell(self.percentages[indexPath.row - 1])
            }
            cell.selectionStyle = .None
            return cell
            
        }else if indexPath.section == 1 {
            if self.beforeLoadingTimers {
                cell = self.tableView.dequeueReusableCellWithIdentifier("loading")! as UITableViewCell
                return cell
            }else if self.timers.isEmpty {
                cell = self.tableView.dequeueReusableCellWithIdentifier("empty")! as UITableViewCell
                let label = cell.viewWithTag(self.emptyLabelTag) as! UILabel
                label.text = NSLocalizedString("Prompt.Dashboard.Timers.Empty", comment: "")
                return cell
            }else{
                cell = self.tableView.dequeueReusableCellWithIdentifier("timerCell")! as UITableViewCell
                let t = self.timers[indexPath.row]
                TimerPresenter.setTimerDescription(cell, timer: t)
                return cell
            }
        }else if indexPath.section == 2 {
            if self.beforeLoadingTasks {
                cell = self.tableView.dequeueReusableCellWithIdentifier("loading")! as UITableViewCell
                return cell
            }else if indexPath.row == 0{
                cell = self.tableView.dequeueReusableCellWithIdentifier("doneTaskCalendar")! as UITableViewCell
                
                if self.taskCalendarCell == nil {
                    let calendarView: FSCalendar = cell.viewWithTag(self.doneTaskCalendarTag) as! FSCalendar
                    
                    calendarView.dataSource = self
                    calendarView.delegate = self
                    
                    calendarView.appearance.cellShape = .Rectangle
                    calendarView.allowsSelection = true
                    calendarView.allowsMultipleSelection = false
                }
                cell.selectionStyle = .None

                return cell
                
            }else if indexPath.row == 1{
                let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("taskCount")! as UITableViewCell
                let task = self.taskByEvent[self.selectedDate]
                
                let date: UILabel = cell.viewWithTag(self.doneTaskHeaderTag) as! UILabel
                let eventCount: UILabel = cell.viewWithTag(self.doneTaskCountTag) as! UILabel
                date.text = String(format: NSLocalizedString("Prompt.DoneTask.DoneByDay", comment: ""), DateTimeFormatter.getStrWithWeekday(selectedDate))
                let count = task?.count ?? 0
                eventCount.text = "\(count)"
                cell.selectionStyle = .None
                
                return cell
            }else{
                let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("doneEvent")! as UITableViewCell
                
                let task = self.taskByEvent[self.selectedDate]![indexPath.row - 2]
                
                let timer: UILabel = cell.viewWithTag(self.doneTaskNameTag) as! UILabel
                let repeating: UILabel = cell.viewWithTag(self.doneTaskRepeatTag) as! UILabel
                let list: UILabel = cell.viewWithTag(self.doneTaskItemNameTag) as! UILabel
                let date: UILabel = cell.viewWithTag(self.doneTaskDateTag) as! UILabel
                
                timer.text = task.timer.name
                repeating.text = task.timer.getIntervalString()
                list.text = task.itemName
                
                date.text = String(format: NSLocalizedString("Prompt.DoneTask.DoneDate", comment: ""), DateTimeFormatter.getFullStr(task.actrualDate))
                return cell
            }
        }else{
            return UITableViewCell(style: .Default, reuseIdentifier: "cell")
        }

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if !self.beforeLoadingTimers && indexPath.section == 1 {
            let timer = self.timers[indexPath.row]
            if let id = timer.listId {
                let storyboard: UIStoryboard = UIStoryboard(name: "Item", bundle: nil)
                let next: ItemViewController = storyboard.instantiateInitialViewController() as! ItemViewController
                next.itemId = id
                self.navigationController?.pushViewController(next, animated: true)
            }
        }else if !self.beforeLoadingTasks && indexPath.section == 2 && indexPath.row >= 2 {
            let task = self.taskByEvent[self.selectedDate]![indexPath.row - 2]
            if let id = task.timer.listId {
                let storyboard: UIStoryboard = UIStoryboard(name: "Item", bundle: nil)
                let next: ItemViewController = storyboard.instantiateInitialViewController() as! ItemViewController
                next.itemId = id
                self.navigationController?.pushViewController(next, animated: true)
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("graphHeader")! as UITableViewCell
            return cell.contentView
        }else if section == 1 {
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("timerHeader")! as UITableViewCell
            let button = cell.viewWithTag(self.moreTimerButtonTag) as! UIButton
            if self.beforeLoadingTimers || self.timers.count <= self.maxTimer {
                button.hidden = true
            }else{
                button.hidden = false
            }
            return cell.contentView
        }else if section == 2 {
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("doneTaskHeader")! as UITableViewCell
            return cell.contentView
        }else{
            return nil
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func getChartSectionRowCount() -> Int {
        guard let selected = self.chartSelectedType else {
            return 1 + self.percentages.count
        }
        
        var result = 1
        
        let key = self.percentages[selected].type!
        result = result + self.percentageByCategory[key]!.count
        
        return result
    }
    
    func getDoneTaskSectionRowCount() -> Int {
        guard let task = self.taskByEvent[self.selectedDate] else {
            return 2
        }

        return 2 + task.count
    }
    
    func getTypeCell(percentage: ItemPercentageEntity) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("itemType")! as UITableViewCell
        
        let itemTypeIcon: UIImageView = cell.viewWithTag(self.itemTypeImageTag) as! UIImageView
        let itemType: UILabel = cell.viewWithTag(self.itemTypeTag) as! UILabel
        let itemTypeCount: UILabel = cell.viewWithTag(self.itemTypeCountTag) as! UILabel
        
        if self.chartSelectedType != nil {
            cell.backgroundColor = percentage.typeCase!.getColor()        
        }
        
        switch percentage.typeCase! {
        case .Clothing:
            itemTypeIcon.image = UIImage(named: "clothing")
        case .Food:
            itemTypeIcon.image = UIImage(named: "food")
        case .Living:
            itemTypeIcon.image = UIImage(named: "living")
        default:
            itemTypeIcon.image = UIImage(named: "item_etc")
        }
        
        itemType.text = percentage.typeCase?.getStr()
        let count = percentage.count ?? 0
        let percent = percentage.percentage ?? 0
        itemTypeCount.text = "\(count) " + NSLocalizedString("Unit.ItemCount", comment: "") + " (\(percent)%)"
        
        return cell
    }
    
    func getCategoryCell(percentage: ItemPercentageEntity) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("itemCategory")! as UITableViewCell
        
        let category: UILabel = cell.viewWithTag(self.itemCategoryTag) as! UILabel
        let categoryCount: UILabel = cell.viewWithTag(self.itemCategoryCountTag) as! UILabel
        
        category.text = percentage.tag
        let count = percentage.count ?? 0
        let percent = percentage.percentage ?? 0
        categoryCount.text = "\(count) " + NSLocalizedString("Unit.ItemCount", comment: "") + " (\(percent)%)"
        
        return cell
    }
    
    func getDetailCategoryCell(percentage: ItemPercentageEntity) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("itemDetailCategory")! as UITableViewCell
        
        let category: UILabel = cell.viewWithTag(self.itemDetailCategoryTag) as! UILabel
        let categoryCount: UILabel = cell.viewWithTag(self.itemDetailCategoryCountTag) as! UILabel
        
        category.text = "- " + percentage.tag!
        let count = percentage.count ?? 0
        let percent = percentage.percentage ?? 0
        categoryCount.text = "\(count) " + NSLocalizedString("Unit.ItemCount", comment: "") + " (\(percent)%)"
        
        return cell
    }
}

extension DashboardViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
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
        let before = self.getDoneTaskSectionRowCount()
        self.selectedDate = date
        let after = self.getDoneTaskSectionRowCount()
        self.reloadSection(2, beforeRowCount: before, afterRowCount: after)

    }
    
}
