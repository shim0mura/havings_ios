//
//  SimpleTableViewCell.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/07.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import Charts

class SimpleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chartView: LineChartView!
 
    
    let months = ["1月", "2月", "3月", "4月", "5月", "", "", "", "9月", "10月", "11月", "12月"]
    let unitsSold = [50.3, 68.3, 113.3, 115.7, 160.8, 214.0, 220.4, 132.1, 176.2, 120.9, 71.3, 48.0]
    
    private var countData: [CountDataEntity]?
    private var sectionCount: Int?
    private var rowsBySection: [Int]?
    private let MAX_SHOW_ACTIVITY = 3
    private var navigationController: UINavigationController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //chartView.animate(yAxisDuration: 2.0)
        
        // TODO: 「最近のアクティビティ」の表示
        // 3行くらい表示したいけど、セクションのheightは分かってもrowのheightは不定で
        // 最近のアクティビティのheightを指定できないので、今のところはやらないでおく
        // そもそも最近のアクティビティあると詳細グラフページまでの回遊率落ちるのでは？
        /*
         activityTableView.registerNib(UINib(nibName: "ActivityTableViewCellHeader", bundle: nil), forCellReuseIdentifier: "activityHeader")
         activityTableView.registerNib(UINib(nibName: "ActivityTableViewCell", bundle: nil), forCellReuseIdentifier: "activity")
        activityTableView.scrollEnabled = false
        activityTableView.delegate = self
        activityTableView.dataSource = self
        activityTableView.estimatedRowHeight = 50
        activityTableView.rowHeight = UITableViewAutomaticDimension
        */
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setNavigationController(navCon: UINavigationController?){
        if let nc = navCon {
            self.navigationController = nc
        }
    }
    
    func setChart(countProperty: [CountDataEntity]?){
        chartView.pinchZoomEnabled = false
        //chartView.scaleXEnabled = false
        //chartView.scaleYEnabled = false
        chartView.setScaleEnabled(false)
        chartView.dragEnabled = false
        
        chartView.drawBordersEnabled = true
        let right = chartView.getAxis(ChartYAxis.AxisDependency.Right)
        right.drawLabelsEnabled = false
        let left = chartView.getAxis(ChartYAxis.AxisDependency.Left)
        left.valueFormatter = DoubleToIntFormatter()

        
        guard let data = countProperty else {
            chartView.noDataText = "アイテムの追加、手放しなどはされていません"
            return
        }
        
        chartView.descriptionText = "京都府の月毎の降水量グラフ"
        
        /*
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<months.count {
            if i == 5 || i == 4 || i == 3 {
                continue
            }
            let dataEntry = ChartDataEntry(value: unitsSold[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        */

        self.countData = GraphRenderer.appendTodaysData(data)
        //setSectionCount(data)
        let lineChartData = GraphRenderer.createChartData(self.countData!, dateShowType: GraphRenderer.DATE_SHOW_TYPE_MONTH)
        chartView.data = lineChartData.0
        
    }
    
    @IBAction func navigateToDetailGraph(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "DetailGraph", bundle: nil)
        let next: DetailGraphViewController = storyboard.instantiateInitialViewController()! as! DetailGraphViewController
        next.countData = self.countData
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    /*
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("row num")
        if let data = countData {
            let c = data[data.count - 1 - section].events?.count ?? 0
            if c >= MAX_SHOW_ACTIVITY {
                print("row count \(c)")

                return MAX_SHOW_ACTIVITY
            }else{
                print("row count \(c)")
                return c
            }
        }else{
            
            return 0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = activityTableView.dequeueReusableCellWithIdentifier("activityHeader")! as! ActivityTableViewCellHeader
        print("section header")

        guard let c = countData?.count, let cd = countData?[c - 1 - section] else {
            print("header nil!!")
            return nil
        }
        
        cell.setHeader(cd.date!, count: cd.count!)
        return cell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = activityTableView.dequeueReusableCellWithIdentifier("activity")! as! ActivityTableViewCell
        print("row")
        guard let c = countData?.count, let cd = countData?[c - 1 - indexPath.section], let e = cd.events?[indexPath.row] else {
            print("row nil!!")

            return cell
        }
        
        cell.setData(e)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        print("section mmm \(sectionCount)")
        if sectionCount != nil {
            return sectionCount!
        }else{
            return 0
        }
    }
    */
        
    func setSectionCount(data: [CountDataEntity]){
        if data.isEmpty {
            self.sectionCount = 0
            return
        }
        
        rowsBySection = data.map {
            let events = $0.events?.count ?? 0
            return events + 1
        }
        print(rowsBySection)
        
        let sections = rowsBySection!.count
        var count = 0
        while(count <= MAX_SHOW_ACTIVITY){
            let c = self.rowsBySection![sections - 1 - count]
            count += c
            if sectionCount != nil {
                sectionCount = sectionCount! + 1
            }else{
                sectionCount = 1
            }
        }
    }
    
}
