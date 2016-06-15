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
    
}