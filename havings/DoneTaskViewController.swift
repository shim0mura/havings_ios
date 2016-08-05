//
//  DoneTaskViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/19.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class DoneTaskViewController: UIViewController, PostAlertUtil {

    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var contentView: UIView!
    
    private var calendarVC: DoneTaskByCalendarViewController!
    private var listVC: DoneTaskByListViewController!
    private var childVC: UIViewController!
    
    private var taskByTupple: [(task: TaskEntity, list: ItemEntity)] = []
    private var taskByEvent: [NSDate: [(timer: TimerEntity, itemName: String, actrualDate: NSDate)]] = [:]

    private var taskWrapper: DoneTaskWrapperEntity = DoneTaskWrapperEntity()
    var itemId: Int = 0
    var itemName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        API.call(Endpoint.DoneTask.GetDoneTaskByItem(itemId: self.itemId)) { response in
            switch response {
            case .Success(let result):
                self.taskWrapper = result
                result.tasks?.forEach{
                    self.taskByTupple.append((task: $0, list: result.list!))
                }
                self.taskByEvent = DoneTaskWrapperEntity.setEventByDate([result])
                self.calendarVC.taskByEvent = self.taskByEvent

                self.listVC.taskByTupple = self.taskByTupple

                self.viewDidLayoutSubviews()
                
            case .Failure(let error):
                self.dismissViewControllerAnimated(true, completion: {
                    self.simpleAlertDialog(NSLocalizedString("Prompt.ProfileEdit.FailedToGetUserInfo", comment: ""), message: nil)
                })
                print("failure \(error)")
            }
        }
        self.title = String(format: NSLocalizedString("Prompt.DoneTask", comment: ""), itemName)
        
        self.setVC()
    }
    
    func setVC(){
        self.calendarVC = self.storyboard?.instantiateViewControllerWithIdentifier("TaskByCalendar") as! DoneTaskByCalendarViewController
        self.calendarVC.taskByEvent = self.taskByEvent
        self.listVC = self.storyboard?.instantiateViewControllerWithIdentifier("TaskByList") as! DoneTaskByListViewController
        self.listVC.taskByTupple = self.taskByTupple
        
        self.addChildViewController(self.calendarVC)
        self.contentView.addSubview(self.calendarVC.view)
        self.calendarVC.didMoveToParentViewController(self)
        self.childVC = self.calendarVC
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.calendarVC.view.frame = self.contentView.bounds
        self.listVC.view.frame = self.contentView.bounds
    }
    
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        self.childVC.willMoveToParentViewController(nil)
        self.childVC.view.removeFromSuperview()
        self.childVC.removeFromParentViewController()
        
        if self.childVC == self.calendarVC {
            self.addChildViewController(self.listVC)
            self.contentView.addSubview(self.listVC.view)
            self.listVC.didMoveToParentViewController(self)
            self.childVC = self.listVC
        }else{
            self.addChildViewController(self.calendarVC)
            self.contentView.addSubview(self.calendarVC.view)
            self.calendarVC.didMoveToParentViewController(self)
            self.childVC = self.calendarVC
        }
        
    }

}
