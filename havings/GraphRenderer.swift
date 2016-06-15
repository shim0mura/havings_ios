//
//  GraphRenderer.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/09.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import Charts

class GraphRenderer {
    
    static let DATE_SHOW_TYPE_MONTH: Int = 1
    static let DATE_SHOW_TYPE_DAYMONTH: Int = 2
    
    static func createChartData(data: [CountDataEntity], dateShowType: Int? = nil) -> (LineChartData, [Int]){
        var count = 0
        
        var xindex: [Int] = []
        var dates: [String] = []
        var dataEntries: [ChartDataEntry] = []
        var nextData = data.first!
        var dataIndex = 0
        
        let oneDay = NSDateComponents()
        oneDay.day = 1;
        let startDate = data.first!.date!
        let endDate = NSDate()
        
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        var currentDate : NSDate = startDate
        
        let componentsByDay = calendar.components([.Day], fromDate: startDate, toDate: endDate, options: NSCalendarOptions())
        let dayDiff = componentsByDay.day
        var dateType: Int
        if let dst = dateShowType {
            dateType = dst
        }else{
            if dayDiff < 100 {
                dateType = 1
            }else{
                dateType = 2
            }
        }

        while (currentDate.compare(endDate) != .OrderedDescending) {
            
            let components = calendar.components([.Month, .Day], fromDate: currentDate)
            dates.append(getDateString(components, type: dateType))
            
            if calendar.isDate(currentDate, inSameDayAsDate: nextData.date!) {
                dataEntries.append(ChartDataEntry(value: Double(nextData.count!), xIndex: count))
                
                dataIndex += 1
                if dataIndex >= data.count {
                    let lastCount = nextData.count
                    nextData = CountDataEntity()
                    nextData.date = endDate
                    nextData.count = lastCount
                }else{
                    nextData = data[dataIndex]
                }
                
                xindex.append(count)
                
            }
            
            count += 1
            currentDate = calendar.dateByAddingComponents(oneDay, toDate: currentDate, options: [])!
        }
        
        let chartDataSet = LineChartDataSet(yVals: dataEntries, label: "アイテム数")
        let chartData = LineChartData(xVals: dates, dataSet: chartDataSet)
        chartDataSet.valueFormatter = DoubleToIntFormatter()
        return (chartData: chartData, xIndex: xindex)
    }
    
    static func appendTodaysData(data: [CountDataEntity]) -> [CountDataEntity]{
        var result = data
        let today = NSDate()
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!

        if let lastData = result.last, let lastDate = lastData.date {
            if !calendar.isDate(today, inSameDayAsDate: lastDate) {
                let todayData = CountDataEntity()
                todayData.date = today
                todayData.count = lastData.count
                result.append(todayData)
            }
        }
        
        return result
    }
    
    static func getDateString(components: NSDateComponents, type: Int) -> String {
        switch type {
        case DATE_SHOW_TYPE_MONTH:
            return "\(components.month)月"
        case DATE_SHOW_TYPE_DAYMONTH:
            return "\(components.month)/\(components.day)"
        default:
            return "\(components.month)/\(components.day)"
        }
    }
    
}

class DoubleToIntFormatter : NSNumberFormatter {
    override func stringFromNumber(number: NSNumber) -> String? {
        let num: Int = number as Int
        return "\(num)"
    }
}