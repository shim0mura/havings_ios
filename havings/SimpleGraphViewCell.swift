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
 
    var itemName: String?
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
            chartView.noDataText = NSLocalizedString("Prompt.Item.Graph.Empty", comment: "")
            return
        }
        
        if let start = countProperty?.first?.date, let end = countProperty?.last?.date {
            chartView.descriptionText = String(format: NSLocalizedString("Prompt.Item.Graph.Period", comment: ""), DateTimeFormatter.getStrFromDate(start, format: DateTimeFormatter.formatYMD), DateTimeFormatter.getStrFromDate(end, format: DateTimeFormatter.formatYMD))
        }
        
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
        chartView.leftAxis.showOnlyMinMaxEnabled = true
        
    }
    
    @IBAction func navigateToDetailGraph(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "DetailGraph", bundle: nil)
        let next: DetailGraphViewController = storyboard.instantiateInitialViewController()! as! DetailGraphViewController
        next.countData = self.countData
        next.itemName = self.itemName
        self.navigationController?.pushViewController(next, animated: true)
    }
        
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
