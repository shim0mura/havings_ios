    //
//  TimerChangeDueViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/08.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import SwiftDate
    
class TimerChangeDueViewController: UIViewController, PostAlertUtil {
    
    enum ChangeType {
        case DoLater
        case AlreadyDone
        
        var title: String {
            switch self {
            case .DoLater:
                return NSLocalizedString("Prompt.Timer.DoLater.Edit", comment: "")
            case .AlreadyDone:
                return NSLocalizedString("Prompt.Timer.AlreadyDone.Edit", comment: "")
            }
        }
    }

    @IBOutlet weak var timerDuePicker: UIDatePicker!
    @IBOutlet weak var nextDueLabel: UILabel!
    
    @IBOutlet weak var repeatNextDueContainer: UIView!
    
    @IBOutlet weak var repeatNextDueLabel: UILabel!
    
    @IBOutlet weak var pageTitle: UINavigationItem!
    
    var isSending: Bool = false
    var timer: TimerEntity = TimerEntity()
    var changeType: ChangeType = .DoLater
    weak var timerChangeDelegate: TimerViewChangeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timerDuePicker.datePickerMode = .DateAndTime
        self.pageTitle.title = self.changeType.title
        
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let comps: NSDateComponents = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
        
        let current = NSDate(year: comps.year, month: comps.month, day: comps.day, hour: comps.hour, minute: comps.minute, second: 0, nanosecond:0, region: TimerPresenter.gregorianByRegion)
        
        switch self.changeType {
        case .DoLater:
            self.timerDuePicker.date = self.timer.nextDueAt!
            self.timerDuePicker.minimumDate = current
            self.setRepeatNextDueAt(self.timer.nextDueAt!)
            self.setNextDueAt(self.timer.nextDueAt!)
        case .AlreadyDone:
            self.timerDuePicker.date = current
            self.timerDuePicker.maximumDate = current
            self.repeatNextDueContainer.hidden = true
            
            
            let repeatBy: TimerEntity.TimerRepeatBy = TimerEntity.TimerRepeatBy(rawValue: self.timer.repeatBy!)!
            
            let next: NSDate
            switch repeatBy {
            case .ByDay:
                next = TimerPresenter.getNextDueAtFromMonth(self.timer.nextDueAt!, monthInterval: TimerEntity.TimerRepeatByDayInterval(rawValue: self.timer.repeatMonthInterval!)!, dayOfMonth: self.timer.repeatDayOfMonth!)
            case .ByWeek:
                next = TimerPresenter.getNextDueAtFromWeek(self.timer.nextDueAt!, weekInterval: TimerEntity.TimerRepeatByWeekInterval(rawValue: self.timer.repeatWeek!)!, weekday: DayOfWeek(rawValue: self.timer.repeatDayOfWeek!)!)
            }
            
            self.setNextDueAt(next)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func tapToPost(sender: AnyObject) {
        print("post")
        print(self.timerDuePicker.date)
        
        let current = NSDate()
        switch self.changeType {
        case .DoLater:
            guard self.timerDuePicker.date > current else {
                self.simpleAlertDialog(NSLocalizedString("Prompt.Timer.DoLater.InvalidDate", comment: ""), message: nil)
                return
            }
            
            self.isSending = true
            let spinnerAlert = self.showConnectingSpinner()
            
            API.call(Endpoint.Timer.DoLater(timerId: self.timer.id!, nextDue: self.timerDuePicker.date)){ response in
                switch response {
                case .Success(let result):
                    
                    self.isSending = false
                    spinnerAlert.dismissViewControllerAnimated(false, completion: {
                        if let errors = result.errors as? Dictionary<String, AnyObject> {
                            self.showFailedAlert(errors)
                            return
                        }
                        
                        self.timer.nextDueAt = self.timerDuePicker.date
                        self.timerChangeDelegate?.changeTimer()
                        self.dismissViewControllerAnimated(true, completion: nil)
                        
                        print(result)
                        print("success!!")
                    })
                    
                case .Failure(let error):
                    print(error)
                    
                    spinnerAlert.dismissViewControllerAnimated(false, completion: nil)
                    self.simpleAlertDialog(NSLocalizedString("Prompt.FailureToAceess", comment: ""), message: nil)
                    
                    self.isSending = false
                }
            }
            
        case .AlreadyDone:
            guard self.timerDuePicker.date < current else {
                self.simpleAlertDialog(NSLocalizedString("Prompt.Timer.AlreadyDone.InvalidDate", comment: ""), message: nil)
                return
            }
            
            self.isSending = true
            let spinnerAlert = self.showConnectingSpinner()
            
            API.call(Endpoint.Timer.Done(timerId: self.timer.id!, doneDate: self.timerDuePicker.date)){ response in
                switch response {
                case .Success(let result):
                    
                    self.isSending = false
                    spinnerAlert.dismissViewControllerAnimated(false, completion: {
                        if let errors = result.errors as? Dictionary<String, AnyObject> {
                            self.showFailedAlert(errors)
                            return
                        }
                        
                        self.timer.nextDueAt = TimerPresenter.getNextDueAtFromWeek(self.timer.nextDueAt!, weekInterval: TimerEntity.TimerRepeatByWeekInterval(rawValue: self.timer.repeatWeek!)!, weekday: DayOfWeek(rawValue: self.timer.repeatDayOfWeek!)!)
                        self.timerChangeDelegate?.changeTimer()
                        self.dismissViewControllerAnimated(true, completion: nil)
                        
                        print(result)
                        print("success!!")
                    })
                    
                case .Failure(let error):
                    print(error)
                    
                    spinnerAlert.dismissViewControllerAnimated(false, completion: nil)
                    self.simpleAlertDialog(NSLocalizedString("Prompt.FailureToAceess", comment: ""), message: nil)
                    
                    self.isSending = false
                }
            }
        }
        
    }

    @IBAction func dateChanged(sender: UIDatePicker) {
        switch self.changeType {
        case .DoLater:
            self.setNextDueAt(sender.date)
            self.setRepeatNextDueAt(sender.date)
        case .AlreadyDone:
            break
        }
    }
    
    func setNextDueAt(date: NSDate){
        self.nextDueLabel.text = DateTimeFormatter.getFullStr(date)
    }
    
    func setRepeatNextDueAt(date: NSDate){
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let comps: NSDateComponents = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: date)
        let originalComps: NSDateComponents = calendar.components([.Hour, .Minute], fromDate: self.timer.nextDueAt!)

        let nextOfNext = NSDate(year: comps.year, month: comps.month, day: comps.day, hour: originalComps.hour, minute: originalComps.minute, second: 0, nanosecond:0, region: TimerPresenter.gregorianByRegion)
        
        let next = TimerPresenter.getNextDueAtFromWeek(nextOfNext, weekInterval: TimerEntity.TimerRepeatByWeekInterval(rawValue: self.timer.repeatWeek!)!, weekday: DayOfWeek(rawValue: self.timer.repeatDayOfWeek!)!)
        self.repeatNextDueLabel.text = DateTimeFormatter.getFullStr(next)
    }
}
