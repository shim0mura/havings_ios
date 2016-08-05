//
//  TimerPresenter.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/01.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate

class TimerPresenter {
    static let MAX_TIMERS_PER_LIST: Int = 3
    static let gregorianByRegion = DateRegion(calendarName: .Gregorian)
    
    static let timerNameTag: Int = 30
    static let timerRepeatTag: Int = 31
    static let timerAlarmTag: Int = 32
    static let timerProgressTag: Int = 33
    static let timerItemNameTag: Int = 34

    static func setTimerDescription(cell: UITableViewCell, timer: TimerEntity){
        let timerName: UILabel = cell.viewWithTag(timerNameTag) as! UILabel
        let timerRepeat: UILabel = cell.viewWithTag(timerRepeatTag) as! UILabel
        let timerAlarm: UILabel = cell.viewWithTag(timerAlarmTag) as! UILabel
        let timerProgress: UIProgressView = cell.viewWithTag(timerProgressTag) as! UIProgressView
        let timerItem: UILabel? = cell.viewWithTag(timerItemNameTag) as? UILabel
        
        let noticePrompt = (timer.overDueFrom == nil) ? NSLocalizedString("Prompt.Timer.NoticeAt", comment: "") : NSLocalizedString("Prompt.Timer.NoticeAgainAt", comment: "")
        let percentage = timer.getPercentageUntilDueDate()
        let weekday = DateTimeFormatter.getWeekday(timer.nextDueAt!)
        let formatStr = String(format: NSLocalizedString("Format.Timer.MDHM", comment: ""), weekday)
        timerName.text = timer.name
        timerRepeat.text = timer.getIntervalString() + NSLocalizedString("Prompt.Timer.NoticeAt", comment: "") + " " + timer.getRemainingTimeString()
        //timerRemaining.text = timer.getRemainingTimeString()
        timerAlarm.text = DateTimeFormatter.getStrFromDate(timer.nextDueAt!, format: formatStr) + noticePrompt
        timerProgress.progress = percentage
        timerProgress.tintColor = timer.getProgressBarColor(percentage)
        
        if let ti = timerItem {
            ti.text = timer.listName
        }
    }
    
    static func getNextDueAtFromMonth(calcFrom: NSDate, monthInterval: TimerEntity.TimerRepeatByDayInterval, dayOfMonth: Int) -> NSDate {
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let comps: NSDateComponents = calendar.components([.Year, .Month, .Day, .Weekday, .Hour, .Minute, .Second, .Nanosecond], fromDate: calcFrom)
        
        var month = comps.month + monthInterval.rawValue
        if comps.day >= dayOfMonth {
            month = month + 1
        }else{
            month = month + 1
        }
        
        let checkDate = NSDate(year: comps.year, month: month, day: 1, region: self.gregorianByRegion)
        var day = dayOfMonth
        if dayOfMonth >= checkDate.monthDays {
            day = checkDate.monthDays
        }
        
        return NSDate(year: comps.year, month: month, day: day, hour: comps.hour, minute: comps.minute, second: 0, nanosecond: 0, region: self.gregorianByRegion)
    }
    
    static func getCandidateDayFromMonth(target: NSDate, start: NSDate, candidateDay: Int, monthInterval: TimerEntity.TimerRepeatByDayInterval) -> NSDate?{
        
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let targetComps: NSDateComponents = calendar.components([.Year, .Month, .Day, .Weekday, .Hour, .Minute, .Second, .Nanosecond], fromDate: target)
        let startComps: NSDateComponents = calendar.components([.Year, .Month, .Day, .Weekday, .Hour, .Minute, .Second, .Nanosecond], fromDate: start)
        
        let monthDiff = (targetComps.year - startComps.year) * 12 + (targetComps.month - startComps.month)
        let interval = monthInterval.rawValue + 1
        if candidateDay > startComps.day {
            //monthDiff = monthDiff + 1
        }
        
        print(targetComps.month, startComps.month)
        print(monthDiff, interval)
        if (monthDiff == 0) {
            return nil
        }else if (monthDiff == 0 && interval == 0) || ((monthDiff % interval) == 0) {
            let checkDate = NSDate().inRegion(self.gregorianByRegion)
            let day: Int
            if candidateDay > checkDate.monthDays {
                day = checkDate.monthDays
            }else{
                day = candidateDay
            }
            
            let candidateDate = NSDate(year: targetComps.year, month: targetComps.month, day: day, hour: targetComps.hour, minute: targetComps.minute, second: 0, nanosecond: 0, region: self.gregorianByRegion)
            
            if candidateDate > start {
                return candidateDate
            }else{
                return nil
            }
        }else{
            return nil
        }
    }
    
    static func getNextDueAtFromWeek(calcFrom: NSDate, weekInterval: TimerEntity.TimerRepeatByWeekInterval, weekday: DayOfWeek) -> NSDate {
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let comps: NSDateComponents = calendar.components([.Year, .Month, .Day, .Weekday, .Hour, .Minute, .Second, .Nanosecond], fromDate: calcFrom)
        
        var day: Int
        var month: Int
        switch weekInterval {
        case .EveryWeek:
            var val = (7 - (comps.weekday - 1) + weekday.rawValue) % 7
            if val == 0 {
                val = 7
            }
            
            if (comps.day + val) > calcFrom.monthDays {
                day = (comps.day + val) - calcFrom.monthDays
                month = comps.month + 1
            }else{
                day = comps.day + val
                month = comps.month
            }

            return NSDate(year: comps.year, month: month, day: day, hour: comps.hour, minute: comps.minute, second: comps.second, nanosecond: comps.nanosecond, region: self.gregorianByRegion)
        default:
            var date = getDateFromWeekNumber(calcFrom, weekNumber: weekInterval.rawValue, weekday: weekday)
            if calcFrom >= date {
                date = getDateFromWeekNumber(1.months.fromDate(calcFrom), weekNumber: weekInterval.rawValue, weekday: weekday)
            }
            return date
        }
    }
    
    static func getCandidateDaysFromWeek(target: NSDate, startAt: NSDate, weekNumber: TimerEntity.TimerRepeatByWeekInterval, weekday: DayOfWeek) -> [NSDate]{
        let targetAt = target.inRegion(self.gregorianByRegion)
        let checkDate = NSDate(year: targetAt.year, month: targetAt.month, day: 1, region: self.gregorianByRegion)
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let comps: NSDateComponents = calendar.components([.Year, .Month, .Day, .Weekday, .Hour, .Minute, .Second, .Nanosecond], fromDate: target)
        
        var candidateDates: [NSDate] = []
        
        let weekdayOfFirst = checkDate.weekday - 1
        var candidateDay = weekday.rawValue - weekdayOfFirst + 1
        if candidateDay <= 0 {
            candidateDay = candidateDay + 7
        }
        
        switch weekNumber {
        case .EveryWeek:
            while candidateDay <= checkDate.monthDays {
                let date = NSDate(year: comps.year, month: comps.month, day: candidateDay, region: self.gregorianByRegion)
                if date > startAt {
                    candidateDates.append(date)
                }
                candidateDay = candidateDay + 7
            }
        default:
            candidateDay = candidateDay + (7 * (weekNumber.rawValue - 1))
            if candidateDay > checkDate.monthDays {
                candidateDay = candidateDay - 7
            }
            let date = NSDate(year: comps.year, month: comps.month, day: candidateDay, region: self.gregorianByRegion)
            if date > startAt {
                candidateDates.append(date)
            }
        }
        
        return candidateDates
    }
    
    static func getWeekNumber(date: NSDate) -> Int {
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let comps: NSDateComponents = calendar.components([.Year, .Month, .Day, .Weekday], fromDate: date)
        
        let checkDate = NSDate(year: comps.year, month: comps.month, day: 1, region: self.gregorianByRegion)
        let weekdayOfFirst = checkDate.weekday - 1
        var firstCandidateDay = (comps.weekday - 1) - weekdayOfFirst + 1
        if firstCandidateDay <= 0 {
            firstCandidateDay = firstCandidateDay + 7
        }

        return ((comps.day - firstCandidateDay) / 7) + 1
    }
    
    static func isLastWeek(date: NSDate) -> Bool {        
        let weekday = DayOfWeek(rawValue: date.weekday - 1)!
        let actualDate = getDateFromWeekNumber(date, weekNumber: 5, weekday: weekday)
        if actualDate.day == date.day {
            return true
        }else{
            return false
        }
    }
    
    static func getDateFromWeekNumber(calcFrom: NSDate, weekNumber: Int, weekday: DayOfWeek) -> NSDate {
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let comps: NSDateComponents = calendar.components([.Year, .Month, .Day, .Weekday, .Hour, .Minute, .Second, .Nanosecond], fromDate: calcFrom)

        
        let checkDate = NSDate(year: comps.year, month: comps.month, day: 1, region: self.gregorianByRegion)
        let weekdayOfFirst = checkDate.weekday - 1
        var firstCandidateDay = weekday.rawValue - weekdayOfFirst + 1
        if firstCandidateDay <= 0 {
            firstCandidateDay = firstCandidateDay + 7
        }
        
        var candidateDay = firstCandidateDay + (7 * (weekNumber - 1))
        
        while candidateDay > checkDate.monthDays {
            candidateDay = candidateDay - 7
        }
        
        return NSDate(year: comps.year, month: comps.month, day: candidateDay, hour: comps.hour, minute: comps.minute, second: 0, nanosecond: 0, region: self.gregorianByRegion)
    }
}
enum TimerOwnState {
    case CanNotHaveTimer
    case CanAddMoreTimer
    case HaveTimerMax
    case NoTimer
}