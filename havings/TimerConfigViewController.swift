//
//  TimerConfigViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/08.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class TimerConfigViewController: UIViewController, PostAlertUtil {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var configTitleLabel: UILabel!
    @IBOutlet weak var pageTitle: UINavigationItem!
    var timer: TimerEntity = TimerEntity()
    var isSending: Bool = false
    weak var timerDelegate: TimerConfigViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.pageTitle.title = NSLocalizedString("Prompt.Timer.Config", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

extension TimerConfigViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("edit_timer")! as UITableViewCell
            
            return cell
        }else if indexPath.row == 1 {
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("end_timer")! as UITableViewCell
            
            return cell
        }else{
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("delete_timer")! as UITableViewCell
            
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == 0 {
            let storyboard: UIStoryboard = UIStoryboard(name: "TimerForm", bundle: nil)
            let next: UINavigationController = storyboard.instantiateInitialViewController()! as! UINavigationController
            let vc = next.visibleViewController as! TimerFormViewController
            vc.modalTransitionStyle = .FlipHorizontal
            vc.timer = self.timer
            vc.formType = TimerFormViewController.FormType.Edit
            
            self.presentViewController(next, animated: true, completion: nil)

        }else if indexPath.row == 1 {
            let alert: UIAlertController = UIAlertController(title: NSLocalizedString("Prompt.Timer.End", comment: ""), message: NSLocalizedString("Prompt.Timer.End.Detail", comment: ""), preferredStyle:  UIAlertControllerStyle.Alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Ok", comment: ""), style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
                print("OK")
                
                self.isSending = true
                let spinnerAlert = self.showConnectingSpinner()
                
                API.call(Endpoint.Timer.End(timerId: self.timer.id!)){ response in
                    switch response {
                    case .Success(let result):
                        
                        self.isSending = false
                        spinnerAlert.dismissViewControllerAnimated(false, completion: {
                            if let errors = result.errors as? Dictionary<String, AnyObject> {
                                self.showFailedAlert(errors)
                                return
                            }
                            
                            self.timerDelegate?.endTimer(self.timer)
                            self.dismissViewControllerAnimated(true){
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
                
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler:{
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })
            
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            
            presentViewController(alert, animated: true, completion: nil)
        }else{
            let alert: UIAlertController = UIAlertController(title: NSLocalizedString("Prompt.Timer.Delete", comment: ""), message: NSLocalizedString("Prompt.Timer.Delete.Detail", comment: ""), preferredStyle:  UIAlertControllerStyle.Alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Ok", comment: ""), style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
                print("OK")
                
                self.isSending = true
                let spinnerAlert = self.showConnectingSpinner()
                
                API.call(Endpoint.Timer.Delete(timerId: self.timer.id!)){ response in
                    switch response {
                    case .Success(let result):
                        
                        self.isSending = false
                        spinnerAlert.dismissViewControllerAnimated(false, completion: {
                            if let errors = result.errors as? Dictionary<String, AnyObject> {
                                self.showFailedAlert(errors)
                                return
                            }
                            
                            self.timerDelegate?.endTimer(self.timer)
                            self.dismissViewControllerAnimated(true){
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
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler:{
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })
            
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(format: NSLocalizedString("Prompt.Timer.ConfigTimer", comment: ""), self.timer.name!)
    }
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return " "
    }
}