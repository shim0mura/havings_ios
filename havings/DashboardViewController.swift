//
//  DashboardViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/20.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import Charts

class DashboardViewController: UIViewController, PostAlertUtil, ChartViewDelegate {

    private let pieChartTag: Int = 20
    private let itemTypeImageTag: Int = 10
    private let itemTypeTag: Int = 11
    private let itemTypeCountTag: Int = 12
    private let itemCategoryTag: Int = 13
    private let itemCategoryCountTag: Int = 14
    private let itemDetailCategoryTag: Int = 15
    private let itemDetailCategoryCountTag: Int = 16
    
    private var leftBarButton: ENMBadgedBarButtonItem?
    @IBOutlet weak var tableView: UITableView!
    
    private var percentages: [ItemPercentageEntity] = [] {
        didSet {
            percentages.forEach{
                var categories: [(category: ItemPercentageEntity, isDetail: Bool)] = []
                categories.append((category: $0, isDetail: false))
                $0.childs?.forEach{cat in
                    print(cat.tag)
                    categories.append((category: cat, isDetail: false))
                    cat.childs?.forEach{detailCat in
                        print(detailCat.tag)

                        categories.append((category: detailCat, isDetail: true))
                    }
                }
                
                self.percentageByCategory[$0.type!] = categories
            }
        }
    }
    
    private var percentageByCategory: [Int: [(category:ItemPercentageEntity, isDetail:Bool)]] = [:]
    
    private var chartSelectedType: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        API.callArray(Endpoint.ItemPercentage.GetGraph) { response in
            switch response {
            case .Success(let result):
                self.percentages = result
                self.tableView.reloadData()
            case .Failure(let error):
                self.dismissViewControllerAnimated(true, completion: {
                    self.simpleAlertDialog(NSLocalizedString("Prompt.ProfileEdit.FailedToGetUserInfo", comment: ""), message: nil)
                })
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
        
        setUpLeftBarButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpLeftBarButton() {
        let image = UIImage(named: "icon_type_item")
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
        
        let beforeCount = self.getSection0RowCount()
        self.chartSelectedType = entry.xIndex
        let afterCount = self.getSection0RowCount()
        let diff = beforeCount - afterCount
        if diff > 0 {
            var path: [NSIndexPath] = []
            for i in afterCount..<beforeCount {
                path.append(NSIndexPath(forRow: i, inSection: 0))
            }
            self.tableView.deleteRowsAtIndexPaths(path, withRowAnimation: .Automatic)
        }else if diff < 0 {
            var path: [NSIndexPath] = []
            for i in beforeCount..<afterCount {
                path.append(NSIndexPath(forRow: i, inSection: 0))
            }
            self.tableView.insertRowsAtIndexPaths(path, withRowAnimation: .Automatic)
        }
        
        var reloadPath: [NSIndexPath] = []
        for i in 1..<afterCount {
            reloadPath.append(NSIndexPath(forRow: i, inSection: 0))
        }
        self.tableView.reloadRowsAtIndexPaths(reloadPath, withRowAnimation: .Automatic)
    }
}

extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.getSection0RowCount()
        }else{
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell
        if indexPath.section == 0 {
        
            if indexPath.row == 0 {
                cell = self.tableView.dequeueReusableCellWithIdentifier("graph")! as UITableViewCell

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

                        //let typeStr = typeCase.getStr() + " - " + "\(percent)%"
                        let typeStr = typeCase.getStr()

                        strings.append(typeStr)
                        colors.append(typeCase.getColor())
                    }
                }
                
                let dataSet = PieChartDataSet(yVals:entries, label: "アイテムの割合")
                dataSet.setColors(colors, alpha: 1.0)
                dataSet.valueTextColor = UIColor.blackColor()
                dataSet.valueFormatter = PercentFormatter()

                graph.descriptionText = ""
                graph.usePercentValuesEnabled = true
                graph.delegate = self
                graph.data = PieChartData(xVals: strings, dataSet: dataSet)
                
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
        }else{
            
            return UITableViewCell(style: .Default, reuseIdentifier: "cell")
            
        }

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("graphHeader")! as UITableViewCell
        return cell.contentView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func getSection0RowCount() -> Int {
        guard let selected = self.chartSelectedType else {
            return 1 + self.percentages.count
        }
        
        var result = 1
        
        let key = self.percentages[selected].type!
        result = result + self.percentageByCategory[key]!.count
        
        return result
    }
    
    func getTypeCell(percentage: ItemPercentageEntity) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("itemType")! as UITableViewCell
        
        let itemTypeIcon: UIImageView = cell.viewWithTag(self.itemTypeImageTag) as! UIImageView
        let itemType: UILabel = cell.viewWithTag(self.itemTypeTag) as! UILabel
        let itemTypeCount: UILabel = cell.viewWithTag(self.itemTypeCountTag) as! UILabel
        cell.backgroundColor = percentage.typeCase!.getColor()
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
