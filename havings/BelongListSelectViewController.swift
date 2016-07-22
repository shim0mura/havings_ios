//
//  BelongListSelectViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/22.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class BelongListSelectViewController: UIViewController {

    @IBOutlet weak var listTable: UITableView!
    
    weak var formDelegate: BelongListSelectViewDelegate?
    var listEntities: [CanBelongListEntity]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listTable.delegate = self
        listTable.dataSource = self
        let c = listEntities?.count ?? 0
        print("select vc \(c)")
        listTable.reloadData()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backToForm(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

extension BelongListSelectViewController: UITableViewDelegate, UITableViewDataSource {

    /*
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }*/
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count \(listEntities?.count ?? 0)")
        return listEntities?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")

        if let list = listEntities?[indexPath.row] {
            cell.textLabel?.font = UIFont.systemFontOfSize(14)
            cell.textLabel?.textColor = UIColor.darkGrayColor()
            cell.textLabel?.text = list.name
            let c = list.nest ?? 0
            let colorBase = 1 - (0.03 * Double(c))
            cell.indentationLevel = c

            cell.backgroundColor = UIColor(red: CGFloat(colorBase), green: CGFloat(colorBase), blue: CGFloat(colorBase), alpha: 1.0)
        }
        cell.preservesSuperviewLayoutMargins = false
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.dismissViewControllerAnimated(true){
            if let selected = self.listEntities?[indexPath.row] {
                self.formDelegate?.changeBelongList(selected)
            }
        }
    }
    
}
