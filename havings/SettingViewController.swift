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

    
    @IBAction func notificationConditionChanged(sender: UISwitch) {
        let application = UIApplication.sharedApplication()
        let settings = application.currentUserNotificationSettings()
        // http://qiita.com/yutao727/items/394c1e09af62719807be
        // http://qiita.com/malt/items/fc138ec8e5a7b2372109
        if settings!.types == UIUserNotificationType.None {
            print("許可してよ！")
        }else{
            print(settings)
            print(settings?.types)
        }
    }

}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("notification")!
        return cell
    }
}