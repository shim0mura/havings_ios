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
import EasyTipView
import RealmSwift
import GoogleMobileAds


class DashboardViewController: UIViewController, PostAlertUtil, ChartViewDelegate, BannerUtil {

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
    private let countGraphViewTag: Int = 70
    private let countGraphViewMoreButtonTag: Int = 71
    
    private let maxTimer: Int = 3
    
    private var beforeLoadingChart: Bool = true
    private var beforeLoadingTimers: Bool = true
    private var beforeLoadingTasks: Bool = true
    private var beforeLoadingCounts: Bool = true
    
    private var pieChartCell: UITableViewCell?
    private var taskCalendarCell: UITableViewCell?
    
    private let currentCalendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    
    private var tooltip: EasyTipView?
    
    private var leftBarButton: ENMBadgedBarButtonItem?
    private var timers: [TimerEntity] = []
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
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
    
    private var countData: [CountDataEntity]?
    
    private var chartSelectedType: Int? = nil
    private var selectedDate: NSDate = NSDate()
    
    private var refreshControl: UIRefreshControl!
    private var refreshCount: Int = 5
    
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
        
        getDashboardInfo()
        
        //DefaultTagPresenter.migrateTag()

        setUpLeftBarButton()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        showTooltip()
        DefaultTagPresenter.setDefaultTagConf()
        
        showAd(bannerView)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("Prompt.PullToRefresh", comment: ""))
        self.refreshControl.addTarget(self, action: #selector(DashboardViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    private func showTooltip(){
        
        //let tokenManager = TokenManager.sharedManager
        //tokenManager.resetDeviceToken()
        
        self.tooltip = TooltipManager.getToolTip()
        
        let target = self.tabBarController?.tabBar.items![2].valueForKey("view") as? UIView
        self.tooltip?.show(forView: target!)
    }
    
    func refresh(){
        getDashboardInfo()
    }
    
    func getDashboardInfo(){
        self.refreshCount = 5
        API.callArray(Endpoint.ItemPercentage.GetGraph) { response in
            switch response {
            case .Success(let result):
                self.pieChartCell = nil
                self.chartSelectedType = nil
                self.percentages = result
                self.beforeLoadingChart = false
                self.tableView.reloadData()
            case .Failure(let error):
                self.simpleAlertDialog(NSLocalizedString("Prompt.ProfileEdit.FailedToGetUserInfo", comment: ""), message: nil)
                print("failure \(error)")
            }
            self.refreshCount = self.refreshCount - 1
            if self.refreshCount <= 0 {
                self.refreshControl?.endRefreshing()
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
            self.refreshCount = self.refreshCount - 1
            if self.refreshCount <= 0 {
                self.refreshControl?.endRefreshing()
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
            self.refreshCount = self.refreshCount - 1
            if self.refreshCount <= 0 {
                self.refreshControl?.endRefreshing()
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
            self.refreshCount = self.refreshCount - 1
            if self.refreshCount <= 0 {
                self.refreshControl?.endRefreshing()
            }
        }
        
        API.callArray(Endpoint.CountProperties.Get){ response in
            switch response {
            case .Success(let result):
                self.countData = result
                self.beforeLoadingCounts = false
                self.tableView.reloadData()
            case .Failure(let error):
                print(error)
            }
            self.refreshCount = self.refreshCount - 1
            if self.refreshCount <= 0 {
                self.refreshControl?.endRefreshing()
            }
        }

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
        
        self.reloadSection(3, beforeRowCount: beforeCount, afterRowCount: afterCount)
    }
    
    func chartValueNothingSelected(chartView: ChartViewBase) {
        let count = self.getChartSectionRowCount()
        print(chartView)
        self.reloadSection(3, beforeRowCount: count, afterRowCount: count)
    }
    
    @IBAction func toDetailGraph(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "DetailGraph", bundle: nil)
        let next: DetailGraphViewController = storyboard.instantiateInitialViewController()! as! DetailGraphViewController
        next.countData = self.countData
        next.itemName = NSLocalizedString("Prompt.You", comment: "")
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    func reloadSection(section: Int, beforeRowCount: Int, afterRowCount: Int){
        let diff = beforeRowCount - afterRowCount
        
        self.tableView.beginUpdates()
        
        if diff > 0 {
            var path: [NSIndexPath] = []
            for i in afterRowCount..<beforeRowCount {
                path.append(NSIndexPath(forRow: i, inSection: section))
            }
            self.tableView.deleteRowsAtIndexPaths(path, withRowAnimation: .None)
        }else if diff < 0 {
            var path: [NSIndexPath] = []
            for i in beforeRowCount..<afterRowCount {
                path.append(NSIndexPath(forRow: i, inSection: section))
            }
            self.tableView.insertRowsAtIndexPaths(path, withRowAnimation: .None)
        }
        self.tableView.endUpdates()

        
        var reloadPath: [NSIndexPath] = []
        for i in 1..<afterRowCount {
            reloadPath.append(NSIndexPath(forRow: i, inSection: section))
        }
 
        self.tableView.reloadRowsAtIndexPaths(reloadPath, withRowAnimation: .None)
        
        if section == 3 {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: section), atScrollPosition: .Top, animated: true)
        }

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
            return 1
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
        }else if section == 3 {
            if self.beforeLoadingChart {
                return 1
            }else{
                return self.getChartSectionRowCount()
            }
        
        }else{
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell
        if indexPath.section == 0 {
            if self.beforeLoadingTasks {
                cell = self.tableView.dequeueReusableCellWithIdentifier("loading")! as UITableViewCell
                return cell
            }else {
                cell = self.tableView.dequeueReusableCellWithIdentifier("countGraph")! as UITableViewCell
                cell.selectionStyle = .None
                
                let chartView = cell.viewWithTag(self.countGraphViewTag) as! LineChartView
                
                chartView.pinchZoomEnabled = false
                chartView.setScaleEnabled(false)
                chartView.dragEnabled = false
                
                chartView.drawBordersEnabled = true
                let right = chartView.getAxis(ChartYAxis.AxisDependency.Right)
                right.drawLabelsEnabled = false
                let left = chartView.getAxis(ChartYAxis.AxisDependency.Left)
                left.valueFormatter = DoubleToIntFormatter()
                
                if let data = countData where !data.isEmpty {
                    let start = data.first!.date
                    let end = data.last!.date
                    chartView.descriptionText = String(format: NSLocalizedString("Prompt.Item.Graph.Period", comment: ""), DateTimeFormatter.getStrFromDate(start!, format: DateTimeFormatter.formatYMD), DateTimeFormatter.getStrFromDate(end!, format: DateTimeFormatter.formatYMD))
                    
                    let lineChartData = GraphRenderer.createChartData(GraphRenderer.appendTodaysData(data), dateShowType: GraphRenderer.DATE_SHOW_TYPE_MONTH)
                    chartView.data = lineChartData.0
                }else{
                    chartView.noDataText = NSLocalizedString("Prompt.Dashboard.CountGraph.Empty", comment: "")
                    cell.viewWithTag(self.countGraphViewMoreButtonTag)?.hidden = true
                }
                
                return cell
            }
            
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
        }else if indexPath.section == 3 {
            
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
                    var total: Int = 0
                    for i in 0..<target.count {
                        let type = self.percentages[i]
                        let percent = type.percentage!
                        total = total + type.count!
                        
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
                        
                        let emptyCell = self.tableView.dequeueReusableCellWithIdentifier("empty")! as UITableViewCell
                        let label = emptyCell.viewWithTag(self.emptyLabelTag) as! UILabel
                        label.text = NSLocalizedString("Prompt.Dashboard.PieChart.Empty", comment: "")
                        return emptyCell
                    }else{
                        let dataSet = PieChartDataSet(yVals:entries, label: "")
                        dataSet.setColors(colors, alpha: 1.0)
                        dataSet.valueTextColor = UIColor.blackColor()
                        dataSet.valueFormatter = PercentFormatter()
                        
                        graph.descriptionText = ""
                        graph.usePercentValuesEnabled = true
                        //graph.delegate = self
                        graph.data = PieChartData(xVals: strings, dataSet: dataSet)
                        graph.centerText = String(format: NSLocalizedString("Prompt.Dashboard.PieChart.Total", comment: ""), "\(total)")
                        graph.userInteractionEnabled = false
                        
                    }

                    self.pieChartCell = cell
                }
                
                return cell
                
            }else if let select = self.chartSelectedType where indexPath.row == 1 {
                
                cell = self.getTypeCell(self.percentages[select], chartSelectType: self.chartSelectedType ?? 0)
                
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
                let percentage = self.percentages[indexPath.row - 1]
                cell = self.getTypeCell(percentage, chartSelectType: percentage.type!)
            }
            //cell.selectionStyle = .None
            return cell
            
        }else{
            return UITableViewCell(style: .Default, reuseIdentifier: "cell")
        }

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("table tap")
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
        }else if !self.beforeLoadingTasks && indexPath.section == 3 && indexPath.row == 0 {

            let beforeCount = self.getChartSectionRowCount()
            self.chartSelectedType = nil
            let afterCount = self.getChartSectionRowCount()
            
            self.reloadSection(3, beforeRowCount: beforeCount, afterRowCount: afterCount)
            
        }else if !self.beforeLoadingTasks && indexPath.section == 3 && indexPath.row >= 1 {
            
            
            if let select = self.chartSelectedType {
                
                if indexPath.row == 1 {
                    let beforeCount = self.getChartSectionRowCount()
                    self.chartSelectedType = nil
                    let afterCount = self.getChartSectionRowCount()
                    
                    self.reloadSection(3, beforeRowCount: beforeCount, afterRowCount: afterCount)
                }else{
                    let percentage = self.percentages[select]
                    let byCategory = self.percentageByCategory[percentage.type!]
                    let target = byCategory![indexPath.row - 1]
                    print("\(target.category.tag) \(target.category.tagId)")
                    
                    if let tagId = target.category.tagId, let tagName = target.category.tag {
                        let storyboard: UIStoryboard = UIStoryboard(name: "ClassedItemList", bundle: nil)
                        let next: ClassedItemListViewController = storyboard.instantiateInitialViewController() as! ClassedItemListViewController
                        next.tagId = tagId
                        next.tagName = tagName
                        self.navigationController?.pushViewController(next, animated: true)
                    }
                    
                }
                
            }else{
                let beforeCount = self.getChartSectionRowCount()
                self.chartSelectedType = indexPath.row - 1
                let afterCount = self.getChartSectionRowCount()
                
                self.reloadSection(3, beforeRowCount: beforeCount, afterRowCount: afterCount)
            }
            

            
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("countGraphHeader")! as UITableViewCell
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
        }else if section == 3 {
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("graphHeader")! as UITableViewCell
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
    
    func getTypeCell(percentage: ItemPercentageEntity, chartSelectType: Int) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("itemType")! as UITableViewCell
        
        let itemTypeIcon: UIImageView = cell.viewWithTag(self.itemTypeImageTag) as! UIImageView
        let itemType: UILabel = cell.viewWithTag(self.itemTypeTag) as! UILabel
        let itemTypeCount: UILabel = cell.viewWithTag(self.itemTypeCountTag) as! UILabel
        
        if self.chartSelectedType != nil {
            cell.backgroundColor = percentage.typeCase!.getColor()        
        }else{
            let type = ItemPercentageEntity.TypeCase(rawValue: chartSelectType)
            cell.backgroundColor = type?.getColor()
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
        cell.accessoryType = .DisclosureIndicator
        
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
        cell.accessoryType = .DisclosureIndicator
        
        return cell
    }
}

extension DashboardViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func calendar(calendar: FSCalendar, appearance: FSCalendarAppearance, fillColorForDate date: NSDate) -> UIColor? {
        
        let comps: NSDateComponents = self.currentCalendar.components([.Year, .Month, .Day], fromDate: date)
        let keyDate = NSDate(year: comps.year, month: comps.month, day: comps.day, region: TimerPresenter.gregorianByRegion)
        
        if let content = self.taskByEvent[keyDate] {
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
        
        let comps: NSDateComponents = self.currentCalendar.components([.Year, .Month, .Day], fromDate: date)
        let keyDate = NSDate(year: comps.year, month: comps.month, day: comps.day, region: TimerPresenter.gregorianByRegion)
        
        self.selectedDate = keyDate
        let after = self.getDoneTaskSectionRowCount()
        self.reloadSection(2, beforeRowCount: before, afterRowCount: after)

    }
    
}
