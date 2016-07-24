//
//  TimerEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/01.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftDate
import UIKit

enum DayOfWeek: Int {
    case Sunday = 0
    case Monday = 1
    case Tuesday = 2
    case Wednesday = 3
    case Thursday = 4
    case Friday = 5
    case Saturday = 6
    
    static func getAllCombination() -> [DayOfWeek] {
        return [
            .Sunday, .Monday, .Tuesday, .Wednesday, .Thursday, .Friday, .Saturday
        ]
    }
    
    var description: String {
        switch self {
        case .Sunday:
            return NSLocalizedString("Prompt.Timer.RepeatBy.WeekDay.Sunday", comment: "")
        case .Monday:
            return NSLocalizedString("Prompt.Timer.RepeatBy.WeekDay.Monday", comment: "")
        case .Tuesday:
            return NSLocalizedString("Prompt.Timer.RepeatBy.WeekDay.Tuesday", comment: "")
        case .Wednesday:
            return NSLocalizedString("Prompt.Timer.RepeatBy.WeekDay.Wednesday", comment: "")
        case .Thursday:
            return NSLocalizedString("Prompt.Timer.RepeatBy.WeekDay.Thursday", comment: "")
        case .Friday:
            return NSLocalizedString("Prompt.Timer.RepeatBy.WeekDay.Friday", comment: "")
        case .Saturday:
            return NSLocalizedString("Prompt.Timer.RepeatBy.WeekDay.Saturday", comment: "")
        }
    }
    
    var shortDesc: String {
        switch self {
        case .Sunday:
            return NSLocalizedString("Prompt.Timer.RepeatBy.WeekDay.Sunday.Short", comment: "")
        case .Monday:
            return NSLocalizedString("Prompt.Timer.RepeatBy.WeekDay.Monday.Short", comment: "")
        case .Tuesday:
            return NSLocalizedString("Prompt.Timer.RepeatBy.WeekDay.Tuesday.Short", comment: "")
        case .Wednesday:
            return NSLocalizedString("Prompt.Timer.RepeatBy.WeekDay.Wednesday.Short", comment: "")
        case .Thursday:
            return NSLocalizedString("Prompt.Timer.RepeatBy.WeekDay.Thursday.Short", comment: "")
        case .Friday:
            return NSLocalizedString("Prompt.Timer.RepeatBy.WeekDay.Friday.Short", comment: "")
        case .Saturday:
            return NSLocalizedString("Prompt.Timer.RepeatBy.WeekDay.Saturday.Short", comment: "")
        }
    }
}

class TimerEntity: Mappable {
    
    enum TimerRepeatBy: Int {
        case ByDay = 0
        case ByWeek = 1
        
        var description: String {
            switch self {
            case .ByDay:
                return NSLocalizedString("Prompt.Timer.RepeatBy.Day", comment: "")
            case .ByWeek:
                return NSLocalizedString("Prompt.Timer.RepeatBy.Week", comment: "")
            }
        }
    }
    
    enum TimerRepeatByDayInterval: Int {
        case EveryMonth = 0
        case EveryTwoMonth = 1
        case EveryThreeMonth = 2
        case EveryFourMonth = 3
        case EverySixMonth = 5
        
        static func getAllCombination() -> [TimerRepeatByDayInterval] {
            return [
                .EveryMonth, .EveryTwoMonth, .EveryThreeMonth, .EveryFourMonth, .EverySixMonth
            ]
        }
        
        var description: String {
            switch self {
            case .EveryMonth:
                return NSLocalizedString("Prompt.Timer.RepeatBy.Day.EveryMonth", comment: "")
            case .EveryTwoMonth:
                return NSLocalizedString("Prompt.Timer.RepeatBy.Day.EveryTwoMonth", comment: "")
            case .EveryThreeMonth:
                return NSLocalizedString("Prompt.Timer.RepeatBy.Day.EveryThreeMonth", comment: "")
            case .EveryFourMonth:
                return NSLocalizedString("Prompt.Timer.RepeatBy.Day.EveryFourMonth", comment: "")
            case .EverySixMonth:
                return NSLocalizedString("Prompt.Timer.RepeatBy.Day.EverySixMonth", comment: "")
            }
        }
    }
    
    enum TimerRepeatByWeekInterval: Int {
        case EveryWeek = 0
        case FirstWeek = 1
        case SecondWeek = 2
        case ThirdWeek = 3
        case FourthWeek = 4
        case LastWeek = 5
        
        static func getAllCombination() -> [TimerRepeatByWeekInterval] {
            return [
                .EveryWeek, .FirstWeek, .SecondWeek, .ThirdWeek, .FourthWeek, .LastWeek
            ]
        }
        
        var description: String {
            switch self {
            case .EveryWeek:
                return NSLocalizedString("Prompt.Timer.RepeatBy.Week.EveryWeek", comment: "")
            case .FirstWeek:
                return NSLocalizedString("Prompt.Timer.RepeatBy.Week.FirstWeek", comment: "")
            case .SecondWeek:
                return NSLocalizedString("Prompt.Timer.RepeatBy.Week.SecondWeek", comment: "")
            case .ThirdWeek:
                return NSLocalizedString("Prompt.Timer.RepeatBy.Week.ThirdWeek", comment: "")
            case .FourthWeek:
                return NSLocalizedString("Prompt.Timer.RepeatBy.Week.FourthWeek", comment: "")
            case .LastWeek:
                return NSLocalizedString("Prompt.Timer.RepeatBy.Week.LastWeek", comment: "")
            }
        }
    }
    
    var id: Int?
    var name: String?
    var listId: Int?
    var listName: String?
    var isActive: Bool?
    var isDeleted: Bool?
    var nextDueAt: NSDate?
    var tmpNextDueAt: NSDate?
    var overDueFrom: NSDate?
    var latestCalcAt: NSDate?
    var startAt: NSDate?
    var isRepeating: Bool?
    var repeatBy: Int? // 0: 日にちで指定, 1: 曜日で指定
    var repeatMonthInterval: Int?
    var repeatDayOfMonth: Int?
    var repeatWeek: Int?
    var repeatDayOfWeek: Int?
    var noticeHour: Int?
    var noticeMinute: Int?
    var doneAt: NSDate?
    var errors: AnyObject?
    
    init(){
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let comp = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
        var minutes = 0
        let preciseMinute = comp.minute
        if preciseMinute > 0 && preciseMinute < 15 {
            minutes = 15
        }else if preciseMinute < 30 {
            minutes = 30
        }else if preciseMinute < 45 {
            minutes = 45
        }
        let gregorian1 = DateRegion(calendarName: .Gregorian)
        
        let currentDate = NSDate(year: comp.year, month: comp.month, day: comp.day, hour: comp.hour + 1, minute: minutes, second: 0, nanosecond: 0, region: gregorian1)
        
        let currentComp = calendar.components([.Day, .Hour, .Minute, .Weekday], fromDate: currentDate)
        
        nextDueAt = currentDate
        latestCalcAt = currentDate
        isRepeating = false
        repeatBy = 0
        repeatMonthInterval = 0
        repeatDayOfMonth = currentComp.day
        repeatWeek = 0
        repeatDayOfWeek = currentComp.weekday - 1
        noticeHour = currentComp.hour
        noticeMinute = currentComp.minute
    }
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        listId <- map["list_id"]
        listName <- map["list_name"]
        isActive <- map["is_active"]
        isDeleted <- map["is_deleted"]
        nextDueAt <- (map["next_due_at"], APIDateTransform.manager)
        overDueFrom <- (map["over_due_from"], APIDateTransform.manager)
        latestCalcAt <- (map["latest_calc_at"], APIDateTransform.manager)
        startAt <- (map["start_at"], APIDateTransform.manager)
        isRepeating <- map["is_repeating"]
        repeatBy <- map["repeat_by"]
        repeatMonthInterval <- map["repeat_month_interval"]
        repeatDayOfMonth <- map["repeat_day_of_month"]
        repeatWeek <- map["repeat_week"]
        repeatDayOfWeek <- map["repeat_day_of_week"]
        noticeHour <- map["notice_hour"]
        noticeMinute <- map["notice_minute"]
        doneAt <- map["done_at"]
        errors <- map["errors"]
    }
    
    func getIntervalString() -> String{
        var result: String = ""
        if let repeating = self.isRepeating where repeating == true {
            guard let repeatBy = TimerRepeatBy(rawValue: self.repeatBy!) else {
                return NSLocalizedString("Prompt.Timer.NoRepeat", comment: "")
            }
            
            switch repeatBy {
            case .ByDay:
                print(self.repeatDayOfMonth)
                print(self.repeatMonthInterval)
                guard let monthInterval = TimerRepeatByDayInterval(rawValue: self.repeatMonthInterval!) else {
                    return NSLocalizedString("Prompt.Timer.NoRepeat", comment: "")
                }
                result = "\(monthInterval.description) \(self.repeatDayOfMonth!)" + NSLocalizedString("Unit.Day", comment: "")
            case .ByWeek:
                guard let weekInterval = TimerRepeatByWeekInterval(rawValue: self.repeatWeek!), dayOfWeek = DayOfWeek(rawValue: self.repeatDayOfWeek!) else {
                    return NSLocalizedString("Prompt.Timer.NoRepeat", comment: "")
                }
                result = "\(weekInterval.description) \(dayOfWeek.description)"
            }
            
        }else{
            result = NSLocalizedString("Prompt.Timer.NoRepeat", comment: "")
        }
        return result
    }
    
    func getRemainingTimeString() -> String{
        let due = (self.overDueFrom != nil) ? self.overDueFrom : self.nextDueAt
        guard let seconds = due?.timeIntervalSinceNow else{
            return ""
        }
        var result = "("
        
        let absSeconds = Int(abs(seconds))
        print("seconds: \(seconds), abs: \(absSeconds)")
        
        var isOverLimit = false
        if seconds < 0 {
            isOverLimit = true
        }else{
            result = result + NSLocalizedString("Prompt.Timer.Prefix.Remaining", comment: "")
        }
        
        if absSeconds < 60 * 60 {
            result = result + String(format: "%d", absSeconds / 60)
            result = result + NSLocalizedString("Unit.Minute", comment: "")
        }else if absSeconds < 60 * 60 * 24 {
            result = result + String(format: "%d", absSeconds / (60 * 60))
            result = result + NSLocalizedString("Unit.Hour", comment: "")
        }else {
            result = result + String(format: "%d", absSeconds / (60 * 60 * 24))
            result = result + NSLocalizedString("Unit.Day", comment: "")
        }
        
        if isOverLimit {
            result = result + NSLocalizedString("Prompt.Timer.Postfix.Over", comment: "")
        }
        
        result = result + ")"
    
        return result
    }
    
    func getPercentageUntilDueDate() -> Float {
        let current = NSDate()
        if self.overDueFrom != nil {
            return 100
        }
        
        guard let nextDue = self.nextDueAt where nextDue > current else{
            return 100
        }
        
        guard let startAt = self.latestCalcAt where current > startAt else{
            return 0
        }
        
        let per:Float = Float(nextDue.timeIntervalSinceDate(current) / nextDue.timeIntervalSinceDate(startAt))
        return (1 - per)
    }
    
    func getProgressBarColor(per: Float) -> UIColor {
        let percent = Int(per * 100)
        let r = CGFloat((255 * percent) / 100) / 255.0
        let g = CGFloat((255 * (100 - percent)) / 100) / 255.0
        return UIColor(red: r, green: g, blue: CGFloat(0), alpha: CGFloat(0.8))

    }
}