//
//  DateTimeFormatter.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/08.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation

class DateTimeFormatter {

    static let manager = DateTimeFormatter()
    private let formatter: NSDateFormatter
    static let formatYMD: String = "yyyy/MM/dd"
    
    private init() {
        self.formatter = NSDateFormatter()
        self.formatter.calendar =  NSCalendar(identifier: NSCalendarIdentifierGregorian)!
    }
    
    static func getStrFromDate(date: NSDate, format: String) -> String {
        manager.formatter.dateFormat = format
        return manager.formatter.stringFromDate(date)
    }
    
    static func getStrWithWeekday(date: NSDate) -> String{
        let weekday = getWeekday(date)
        let formatStr = String(format: NSLocalizedString("Format.Timer.YMD.WithWeekday", comment: ""), weekday)
        return getStrFromDate(date, format: formatStr)
    }
    
    static func getFullStr(date: NSDate) -> String{
        let weekday = getWeekday(date)
        let formatStr = String(format: NSLocalizedString("Format.Timer.Full", comment: ""), weekday)
        return getStrFromDate(date, format: formatStr)
    }
    
    static func getWeekday(date: NSDate) -> String{
        let index = manager.formatter.calendar.components([NSCalendarUnit.Weekday], fromDate: date).weekday
        let weekday:DayOfWeek = DayOfWeek(rawValue: index - 1)!
        return weekday.shortDesc
    }
    
}