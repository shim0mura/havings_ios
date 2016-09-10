//
//  TimerRepeatEditViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/05.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import FSCalendar
import SwiftDate

class TimerRepeatEditViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance  {

    @IBOutlet weak var repeatPicker: UIPickerView!
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var nextDueLabel: UILabel!
    @IBOutlet weak var nextDueRepeatLabel: UILabel!
    @IBOutlet weak var repeatTimeLabel: UILabel!
    
    var timer = TimerEntity()
    var repeatType = TimerEntity.TimerRepeatBy.ByWeek
    var tmpNextDue = NSDate()
    var tmpRepeatMonthInterval: TimerEntity.TimerRepeatByDayInterval = TimerEntity.TimerRepeatByDayInterval.EveryMonth
    var tmpRepeatDayOfMonth: Int = 1
    var tmpRepeatWeekNumber: TimerEntity.TimerRepeatByWeekInterval = TimerEntity.TimerRepeatByWeekInterval.EveryWeek
    var tmpRepeatWeekday: DayOfWeek = DayOfWeek.Sunday
    
    let repeatMonthInterval = TimerEntity.TimerRepeatByDayInterval.getAllCombination()
    var repeatWeekInterval:[TimerEntity.TimerRepeatByWeekInterval] = [.EveryWeek]
    let weekdays = DayOfWeek.getAllCombination()
    var candidateDates: [NSDate] = []
    private let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.repeatPicker.delegate = self
        self.repeatPicker.dataSource = self
        self.title = NSLocalizedString("Prompt.Timer.RepeatEditSelect", comment: "")
        
        calendarView.appearance.cellShape = .Rectangle
        //calendarView.appearance.borderDefaultColor = UIColor.redColor()
        calendarView.allowsSelection = false
        calendarView.allowsMultipleSelection = true
        calendarView.dataSource = self
        calendarView.delegate = self
        
        self.tmpRepeatMonthInterval = TimerEntity.TimerRepeatByDayInterval(rawValue: self.timer.repeatMonthInterval!) ?? TimerEntity.TimerRepeatByDayInterval.EveryMonth
        self.tmpRepeatDayOfMonth = self.timer.nextDueAt!.day
        self.tmpRepeatWeekNumber = TimerEntity.TimerRepeatByWeekInterval(rawValue: self.timer.repeatWeek!) ?? TimerEntity.TimerRepeatByWeekInterval.EveryWeek
        self.tmpRepeatWeekday = DayOfWeek(rawValue: self.timer.nextDueAt!.weekday - 1)!
        
        let weeknum = TimerPresenter.getWeekNumber(self.timer.nextDueAt!)
        self.repeatWeekInterval.append(TimerEntity.TimerRepeatByWeekInterval(rawValue: weeknum)!)
        if self.repeatWeekInterval.indexOf(TimerEntity.TimerRepeatByWeekInterval.LastWeek) == nil && TimerPresenter.isLastWeek(self.timer.nextDueAt!) {
            self.repeatWeekInterval.append(TimerEntity.TimerRepeatByWeekInterval.LastWeek)
        }
        
        
        self.nextDueLabel.text = DateTimeFormatter.getFullStr(self.timer.nextDueAt!)
        let repeatIntervalIndex: Int
        switch repeatType {
        case .ByDay:
            repeatIntervalIndex = self.repeatMonthInterval.indexOf(self.tmpRepeatMonthInterval)!
            self.repeatPicker.selectRow(repeatIntervalIndex, inComponent: 0, animated: false)
            //self.repeatPicker.selectRow(self.tmpRepeatDayOfMonth - 1, inComponent: 1, animated: false)
            self.repeatTimeLabel.text = "\(self.tmpRepeatDayOfMonth)" + NSLocalizedString("Unit.Day", comment: "") + NSLocalizedString("Prompt.Timer.NoticeAt", comment: "")
            self.nextDueRepeatLabel.text = DateTimeFormatter.getFullStr(TimerPresenter.getNextDueAtFromMonth(self.timer.nextDueAt!, monthInterval: self.tmpRepeatMonthInterval, dayOfMonth: self.tmpRepeatDayOfMonth))
        case .ByWeek:
            repeatIntervalIndex = self.repeatWeekInterval.indexOf(TimerEntity.TimerRepeatByWeekInterval(rawValue: self.timer.repeatWeek!)!)!
            self.repeatPicker.selectRow(repeatIntervalIndex, inComponent: 0, animated: false)
            //self.repeatPicker.selectRow(self.tmpRepeatWeekday.rawValue, inComponent: 1, animated: false)
            self.repeatTimeLabel.text = self.tmpRepeatWeekday.description + NSLocalizedString("Prompt.Timer.NoticeAt", comment: "")
            self.nextDueRepeatLabel.text = DateTimeFormatter.getFullStr(TimerPresenter.getNextDueAtFromWeek(self.timer.nextDueAt!, weekInterval: self.tmpRepeatWeekNumber, weekday: self.tmpRepeatWeekday))
        }
        
        showCandidate(self.calendarView.currentPage)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calendarCurrentPageDidChange(calendar: FSCalendar) {
        self.showCandidate(calendar.currentPage)
    }
    
    func calendar(calendar: FSCalendar, appearance: FSCalendarAppearance, fillColorForDate date: NSDate) -> UIColor? {
        print("select date")
        print(date)
        
        let comps: NSDateComponents = self.calendar.components([.Year, .Month, .Day], fromDate: date)
        let keyDate = NSDate(year: comps.year, month: comps.month, day: comps.day, region: TimerPresenter.gregorianByRegion)
        
        if self.candidateDates.contains(keyDate) {
            return UIColor.greenColor()
        }else{
            return nil
        }
    }

    func showCandidate(current: NSDate){
        print("!!!!!")
        
        let currentPage = current
        /*
        self.calendarView.selectedDates.forEach{
            print("deselect")
            print($0 as! NSDate)
            self.calendarView.deselectDate($0 as! NSDate)
        }*/
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let comps: NSDateComponents = calendar.components([.Year, .Month, .Day], fromDate: self.timer.nextDueAt!)
        let next = NSDate(year: comps.year, month: comps.month, day: comps.day, region: TimerPresenter.gregorianByRegion)
        self.candidateDates = [next]

        switch self.repeatType {
        case .ByDay:
            let day = self.tmpRepeatDayOfMonth
            let monthInterval = self.repeatMonthInterval[repeatPicker.selectedRowInComponent(0)]
            
            let candidateDay = TimerPresenter.getCandidateDayFromMonth(currentPage, start: self.timer.nextDueAt!, candidateDay: day, monthInterval: monthInterval)
            
            if let candidateDay = candidateDay {
                //self.calendarView.selectDate(candidateDay)
                let comps: NSDateComponents = self.calendar.components([.Year, .Month, .Day], fromDate: candidateDay)
                let keyDate = NSDate(year: comps.year, month: comps.month, day: comps.day, region: TimerPresenter.gregorianByRegion)
                self.candidateDates.append(keyDate)
            }

            self.calendarView.reloadData()

        case .ByWeek:
            let weekday = self.tmpRepeatWeekday
            let weekInterval = self.repeatWeekInterval[self.repeatPicker.selectedRowInComponent(0)]
            
            let candidateDates = TimerPresenter.getCandidateDaysFromWeek(currentPage, startAt: self.timer.nextDueAt!, weekNumber: weekInterval, weekday: weekday)

            candidateDates.forEach{
                self.candidateDates.append($0)
            }

            self.calendarView.reloadData()
        }
    }
}

extension TimerRepeatEditViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch self.repeatType {
        case .ByDay:
            if component == 0 {
                return self.repeatMonthInterval.count
            }else{
                return 31
            }
        case .ByWeek:
            if component == 0 {
                return self.repeatWeekInterval.count
            }else{
                return self.weekdays.count
            }
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch self.repeatType {
        case .ByDay:
            if component == 0 {
                return self.repeatMonthInterval[row].description
            }else{
                return "\(row + 1)" + NSLocalizedString("Unit.Day", comment: "")
            }
        case .ByWeek:
            if component == 0 {
                return self.repeatWeekInterval[row].description
            }else{
                return self.weekdays[row].description
            }
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let next: NSDate
        switch self.repeatType {
        case .ByDay:
            let interval = pickerView.selectedRowInComponent(0)
            //let day = pickerView.selectedRowInComponent(1)
            
            tmpRepeatMonthInterval = self.repeatMonthInterval[interval]
            //tmpRepeatDayOfMonth = day + 1
            next = TimerPresenter.getNextDueAtFromMonth(self.timer.nextDueAt!, monthInterval: self.repeatMonthInterval[interval], dayOfMonth: self.tmpRepeatDayOfMonth)
        case .ByWeek:
            let interval = pickerView.selectedRowInComponent(0)
            //let weekday = pickerView.selectedRowInComponent(1)
            
            tmpRepeatWeekNumber = self.repeatWeekInterval[interval]
            //tmpRepeatWeekday = self.weekdays[weekday]
            next = TimerPresenter.getNextDueAtFromWeek(self.timer.nextDueAt!, weekInterval: self.repeatWeekInterval[interval], weekday: self.tmpRepeatWeekday)
        }
        self.nextDueRepeatLabel.text = DateTimeFormatter.getFullStr(next)
        self.tmpNextDue = next
        self.showCandidate(self.calendarView.currentPage)
    }

}
