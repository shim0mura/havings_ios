//
//  TimerFormViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/05.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import SwiftDate

class TimerFormViewController: UIViewController, PostAlertUtil {

    enum FormType {
        case Add
        case Edit
    }
    
    private let noticeDateTag: Int = 10
    private let noticeTimeTag: Int = 11
    private let noticeDateFieldTag: Int = 20
    private let noticeTimeFieldTag: Int = 21
    private let noticeAtPromptTag: Int = 12
    private let noticeAtTag: Int = 13
    private let noticeAtNextPromptTag: Int = 14
    private let noticeAtNextTag: Int = 15
    private let repeatAtTag: Int = 16
    private let taskNameTag: Int = 22
    
    var timer: TimerEntity = TimerEntity()
    var formType: FormType = .Add
    
    private var toolBar: UIToolbar!
    private var datePicker: UIDatePicker = UIDatePicker()
    private var altField: UITextField?
    private var dateLabel: UILabel?
    private var timeLabel: UILabel?
    private var nextDueLabel: UILabel?
    private var repeatAtLabel: UILabel?
    private var taskNameField: UITextField?
    
    private var isSending = false
    private var tmpNextDueAt = NSDate()
    private var origNextDueAt = NSDate()
    private var tmpIsRepeating: Bool = false
    private var tmpRepeatBy: Int = 0
    private var tmpRepeatMonthInterval: Int = 0
    private var tmpRepeatDayOfMonth: Int = 1
    private var tmpRepeatWeekInterval: Int = 0
    private var tmpRepeatWeek: Int = 0
    
    @IBOutlet weak var tableView: UITableView!
    weak var timerChangeDelegate: TimerViewChangeDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tmpNextDueAt = self.timer.nextDueAt!
        self.origNextDueAt = self.timer.nextDueAt!
        self.tmpIsRepeating = self.timer.isRepeating!
        self.tmpRepeatBy = self.timer.repeatBy!
        self.tmpRepeatMonthInterval = self.timer.repeatMonthInterval!
        self.tmpRepeatDayOfMonth = self.timer.repeatDayOfMonth!
        self.tmpRepeatWeekInterval = self.timer.repeatWeek!
        self.tmpRepeatWeek = self.timer.repeatDayOfWeek!
        
        self.datePicker.minimumDate = self.tmpNextDueAt
        self.datePicker.addTarget(self, action: #selector(TimerFormViewController.changedDateEvent), forControlEvents: UIControlEvents.ValueChanged)
        self.datePicker.datePickerMode = UIDatePickerMode.Date
        
        toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = .BlackTranslucent
        toolBar.tintColor = UIColor.whiteColor()
        toolBar.backgroundColor = UIColor.blackColor()
        
        let toolBarBtn = UIBarButtonItem(title: "完了", style: .Plain, target: self, action: #selector(TimerFormViewController.tappedToolBarBtn))
        
        toolBarBtn.tag = 1
        toolBar.items = [toolBarBtn]
        
        self.title = NSLocalizedString("Prompt.Timer.Edit", comment: "")
        
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            // iOS8以上
            let type : UIUserNotificationType = [.Alert, .Badge, .Sound]
            let setting = UIUserNotificationSettings(forTypes: type, categories: nil)
            //通知のタイプを設定
            UIApplication.sharedApplication().registerUserNotificationSettings(setting)
            //DevoceTokenを要求
            UIApplication.sharedApplication().registerForRemoteNotifications()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let next = segue.destinationViewController as! TimerRepeatTypeViewController
        self.timer.nextDueAt = self.tmpNextDueAt
        next.timer = self.timer
    }
    
    @IBAction func setRepeatType(segue: UIStoryboardSegue){
        print(segue.sourceViewController)
        if segue.sourceViewController is TimerRepeatTypeViewController {
            //self.timer.isRepeating = false
            self.tmpIsRepeating = false

        }else if let repeatResult = segue.sourceViewController as? TimerRepeatEditViewController {
            print(repeatResult)
            //self.timer.isRepeating = true
            self.tmpIsRepeating = true

            //self.timer.nextDueAt = self.origNextDueAt
            /*
            self.timer.repeatBy = repeatResult.repeatType.rawValue
            self.timer.repeatMonthInterval = repeatResult.tmpRepeatMonthInterval.rawValue
            self.timer.repeatDayOfMonth = repeatResult.tmpRepeatDayOfMonth
            self.timer.repeatWeek = repeatResult.tmpRepeatWeekNumber.rawValue
            self.timer.repeatDayOfWeek = repeatResult.tmpRepeatWeekday.rawValue
            */
            print(repeatResult.repeatType)
            self.tmpRepeatBy = repeatResult.repeatType.rawValue
            self.tmpRepeatMonthInterval = repeatResult.tmpRepeatMonthInterval.rawValue
            self.tmpRepeatDayOfMonth = repeatResult.tmpRepeatDayOfMonth
            self.tmpRepeatWeekInterval = repeatResult.tmpRepeatWeekNumber.rawValue
            self.tmpRepeatWeek = repeatResult.tmpRepeatWeekday.rawValue
            
        }
        self.setRepeatLabel()
        print("end")
    }
    
    @IBAction func cancelToEdit(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func postTimer(sender: AnyObject) {
        guard let nameField = self.taskNameField, name = nameField.text where !name.isEmpty else {
            self.simpleAlertDialog(NSLocalizedString("Prompt.Timer.TaskName.Empty", comment: ""), message: nil)
            return
        }
        guard self.timer.listId != nil else {
            print("no list_id")
            return
        }
        
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let comps: NSDateComponents = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: self.tmpNextDueAt)
        
        self.timer.nextDueAt = NSDate(year: comps.year, month: comps.month, day: comps.day, hour: comps.hour, minute: comps.minute, second: 0, nanosecond:0, region: TimerPresenter.gregorianByRegion)
        
        self.isSending = true
        self.timer.name = name
        self.timer.isRepeating = self.tmpIsRepeating
        self.timer.repeatBy = self.tmpRepeatBy
        self.timer.repeatMonthInterval = self.tmpRepeatMonthInterval
        self.timer.repeatDayOfMonth = self.tmpRepeatDayOfMonth
        self.timer.repeatWeek = self.tmpRepeatWeekInterval
        self.timer.repeatDayOfWeek = self.tmpRepeatWeek
        let spinnerAlert = self.showConnectingSpinner()
        
        switch self.formType {
        case .Add:
            API.call(Endpoint.Timer.Post(timer: self.timer)){ response in
                switch response {
                case .Success(let result):
                    
                    self.isSending = false
                    spinnerAlert.dismissViewControllerAnimated(false, completion: {
                        if let errors = result.errors as? Dictionary<String, AnyObject> {
                            self.showFailedAlert(errors)
                            return
                        }
                        
                        self.timerChangeDelegate?.addTimer(self.timer)
                        self.navigationController?.dismissViewControllerAnimated(true){
                            print("dismiss controller")
                        }
                        
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
            
        case .Edit:
            API.call(Endpoint.Timer.Edit(timerId: self.timer.id!, timer: self.timer)){ response in
                switch response {
                case .Success(let result):
                    
                    self.isSending = false
                    spinnerAlert.dismissViewControllerAnimated(false, completion: {
                        if let errors = result.errors as? Dictionary<String, AnyObject> {
                            self.showFailedAlert(errors)
                            return
                        }
                        
                        self.navigationController?.dismissViewControllerAnimated(true){
                            print("dismiss controller")
                        }
                        
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
    
    func changedDateEvent(sender:AnyObject?){
        print("chaned date")
        //inputedLabel?.text = "\(datePicker.date)"
        //self.timer.nextDueAt = (datePicker.date)
        self.tmpNextDueAt = datePicker.date
        setDateTimeLabelByPicker()
    }
    
    func changedTimeEvent(sender:AnyObject?){
        //self.timer.nextDueAt = (datePicker.date)
        self.tmpNextDueAt = datePicker.date
        setDateTimeLabelByPicker()
        //var dateSelecter: UIDatePicker = sender as! UIDatePicker
    }
    
    func tappedToolBarBtn(sender: UIBarButtonItem) {
        self.altField?.resignFirstResponder()
        print("tapp toolbar")
        //self.timer.nextDueAt = (datePicker.date)
        self.tmpNextDueAt = datePicker.date
        setDateTimeLabelByPicker()
    }
    
    func setDateTimeLabelByPicker(){
        self.dateLabel?.text = DateTimeFormatter.getStrWithWeekday(self.tmpNextDueAt)
        self.timeLabel?.text = DateTimeFormatter.getStrFromDate(self.tmpNextDueAt, format: NSLocalizedString("Format.Timer.HM", comment: ""))
        self.nextDueLabel?.text = DateTimeFormatter.getFullStr(self.tmpNextDueAt)
    }
    
    func setRepeatLabel(){
        var str: String = ""
        if self.tmpIsRepeating == true {

        //if self.timer.isRepeating == true {
            //let repeatBy: TimerEntity.TimerRepeatBy = TimerEntity.TimerRepeatBy(rawValue: self.timer.repeatBy!)!
            let repeatBy: TimerEntity.TimerRepeatBy = TimerEntity.TimerRepeatBy(rawValue: self.tmpRepeatBy)!

            switch repeatBy {
            case .ByDay:
                //let monthInterval = TimerEntity.TimerRepeatByDayInterval(rawValue: self.timer.repeatMonthInterval!)!
                let monthInterval = TimerEntity.TimerRepeatByDayInterval(rawValue: self.tmpRepeatMonthInterval)!

                str = monthInterval.description + " \(self.tmpRepeatDayOfMonth)" + NSLocalizedString("Unit.Day", comment: "") + NSLocalizedString("Prompt.Timer.NoticeAt", comment: "")
            case .ByWeek:
                //let weekNumber = TimerEntity.TimerRepeatByWeekInterval(rawValue: self.timer.repeatWeek!)!
                //let weekday = DayOfWeek(rawValue: self.timer.repeatDayOfWeek!)!
                let weekNumber = TimerEntity.TimerRepeatByWeekInterval(rawValue: self.tmpRepeatWeekInterval)!
                let weekday = DayOfWeek(rawValue: self.tmpRepeatWeek)!
                
                str = weekNumber.description + " " + weekday.description + NSLocalizedString("Prompt.Timer.NoticeAt", comment: "")
            }
        }else{
            str = NSLocalizedString("Prompt.Timer.NoRepeat", comment: "")
        }
        self.repeatAtLabel?.text = str
    }
    
}


extension TimerFormViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if indexPath.row == 0 {
            cell = self.tableView.dequeueReusableCellWithIdentifier("taskName")! as UITableViewCell
            self.taskNameField = cell.viewWithTag(taskNameTag) as? UITextField
            self.taskNameField?.delegate = self
            self.taskNameField?.text = self.timer.name
        }else if indexPath.row == 1 {
            cell = self.tableView.dequeueReusableCellWithIdentifier("noticeDate")! as UITableViewCell
            let dateField: UITextField = cell.viewWithTag(noticeDateFieldTag) as! UITextField
            dateField.inputView = self.datePicker
            dateField.inputAccessoryView = self.toolBar
            self.dateLabel = cell.viewWithTag(noticeDateTag) as? UILabel
            self.setDateTimeLabelByPicker()
        }else if indexPath.row == 2 {
            cell = self.tableView.dequeueReusableCellWithIdentifier("noticeTime")! as UITableViewCell
            let timeField: UITextField = cell.viewWithTag(noticeTimeFieldTag) as! UITextField
            timeField.inputView = self.datePicker
            timeField.inputAccessoryView = self.toolBar
            self.timeLabel = cell.viewWithTag(noticeTimeTag) as? UILabel
            self.setDateTimeLabelByPicker()
        }else if indexPath.row == 3 {
            cell = self.tableView.dequeueReusableCellWithIdentifier("noticeAt")! as UITableViewCell
            self.nextDueLabel = cell.viewWithTag(noticeAtTag) as? UILabel
            self.nextDueLabel?.text = DateTimeFormatter.getFullStr(self.tmpNextDueAt)
        }else if indexPath.row == 4 {
            cell = self.tableView.dequeueReusableCellWithIdentifier("repeatingCondition")! as UITableViewCell
            self.repeatAtLabel = cell.viewWithTag(repeatAtTag) as? UILabel
            if self.timer.isRepeating == true {
                self.setRepeatLabel()
            }
        }else{
            cell = self.tableView.dequeueReusableCellWithIdentifier("noticeAt")! as UITableViewCell
            cell.hidden = true
        }
        //let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("repeatingCondition")! as UITableViewCell

        //let cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
        //cell.textLabel?.text = "てすと \(indexPath.row)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    /*
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //dismissViewControllerAnimated(true, completion: {print("table end")})
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if indexPath.row == 1 {
            self.altField = cell!.viewWithTag(noticeDateFieldTag) as? UITextField
            self.altField?.becomeFirstResponder()
            self.datePicker.datePickerMode = UIDatePickerMode.Date

        }else if indexPath.row == 2 {
            self.altField = cell!.viewWithTag(noticeTimeFieldTag) as? UITextField
            self.altField?.becomeFirstResponder()
            self.datePicker.datePickerMode = UIDatePickerMode.Time
            self.datePicker.minuteInterval = 15

        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let timerName = self.timer.name {
            return String(format: NSLocalizedString("Prompt.Timer.EditTimerOf", comment: ""), timerName)
        }else{
            return NSLocalizedString("Prompt.Timer.Edit", comment: "")
        }
        
        //return "セクション \(section)"
    }
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return " "
    }
    
    
}

extension TimerFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        self.taskNameField?.resignFirstResponder()
        print("return")
        return true
    }
}