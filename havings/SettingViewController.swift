//
//  SettingViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/08/08.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let switchTag: Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        self.title = NSLocalizedString("Prompt.Setting.Notification", comment: "")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapBack(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func toSetting(sender: AnyObject) {
        let url = NSURL(string:UIApplicationOpenSettingsURLString)!
        UIApplication.sharedApplication().openURL(url)
    }

}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("notification")!
        
        let application = UIApplication.sharedApplication()
        let settings = application.currentUserNotificationSettings()
        
        let state = cell.viewWithTag(self.switchTag) as! UISwitch
        if settings!.types == UIUserNotificationType.None {
            state.on = false
        }else{
            state.on = true
        }
        state.enabled = false
        
        cell.selectionStyle = .None
        return cell
    }
}