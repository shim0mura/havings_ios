//
//  TargetItemSelectViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/28.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

enum TargetItemSelectType {
    case EditItem
    case AddImage
    case DumpItem
    case DeleteItem
    
    func includeDump() -> Int {
        switch  self {
        case .EditItem, .AddImage, .DeleteItem:
            return 1
        case .DumpItem:
            return 0
        }
    }
}

class TargetItemSelectViewController: UIViewController {

    let itemNameLabelTag: Int = 10
    let itemTypeImageTag: Int = 11
    let itemCountLabelTag: Int = 12
    let privateTypeImageTag: Int = 13
    
    var userId: Int = 0
    var loadingEnd: Bool = false
    var itemList: [(item: ItemEntity, nest: Int)] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var finishDelegate: FinishItemUpdateDelegate?
    
    var selectType:TargetItemSelectType = .EditItem
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Prompt.SelectItem", comment: "")
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self

        self.automaticallyAdjustsScrollViewInsets = false
        
        API.call(Endpoint.Item.GetUserItemTree(userId: self.userId, includeDump: self.selectType.includeDump())) { response in
            switch response {
            case .Success(let result):
                self.loadingEnd = true
                self.addItemRecursive(result as ItemEntity, depth: 0)
                self.tableView.reloadData()
            case .Failure(let error):
                print("failure \(error)")
                self.loadingEnd = true

            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addItemRecursive(item: ItemEntity, depth: Int){
        itemList.append((item, depth))
        
        if let childs = item.owningItems {
            childs.forEach{
                self.addItemRecursive($0, depth: depth + 1)
            }
        }
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        //self.navigationController?.popViewControllerAnimated(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // http://qiita.com/AcaiBowl/items/8f71ca67da4c6f4b78d2
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPathForSelectedRow, animated: true)
        }
    }
    

}

extension TargetItemSelectViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.loadingEnd {
            return itemList.count
        }else{
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = self.loadingEnd ? "nestedItem" : "loading"
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(identifier)! as UITableViewCell

        if self.loadingEnd {
            
            let itemInfo = itemList[indexPath.row]
            //cell.textLabel?.text = itemInfo.item.name
            
            let itemName: UILabel = cell.viewWithTag(itemNameLabelTag) as! UILabel
            let itemTypeImage: UIImageView = cell.viewWithTag(itemTypeImageTag) as! UIImageView
            let itemCount: UILabel = cell.viewWithTag(itemCountLabelTag) as! UILabel
            let privateImage: UIImageView = cell.viewWithTag(privateTypeImageTag) as! UIImageView
            
            itemName.text = itemInfo.item.name
            if itemInfo.item.isGarbage == true {
                itemTypeImage.image = UIImage(named: "ic_delete_black_24dp")
            }else if itemInfo.item.isList == true {
                itemTypeImage.image = UIImage(named: "icon_type_list_light")
            }else{
                itemTypeImage.image = UIImage(named: "icon_type_item")
            }
            itemCount.text = String(format: NSLocalizedString("Prompt.ItemCount", comment: ""), itemInfo.item.count!)
            if itemInfo.item.privateType == 0 {
                privateImage.hidden = true
            }else{
                privateImage.hidden = false
            }

            let colorBase = 1 - (0.03 * Double(itemInfo.nest))
            //cell.indentationLevel = itemInfo.nest
            cell.contentView.layoutMargins = UIEdgeInsetsMake(0, CGFloat(15 * itemInfo.nest), 0, 0)

            cell.backgroundColor = UIColor(red: CGFloat(colorBase), green: CGFloat(colorBase), blue: CGFloat(colorBase), alpha: 1.0)
                
        }
        //cell.preservesSuperviewLayoutMargins = false

        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = itemList[indexPath.row].item
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch self.selectType {
        case .EditItem:
            let next: AddFormViewController = self.storyboard?.instantiateViewControllerWithIdentifier("add_form") as! AddFormViewController
            next.typeAdd = false
            next.item = selectedItem
            next.finishDelegate = self.finishDelegate
            
            self.navigationController?.pushViewController(next, animated: true)
        case .AddImage:
            let next: AddImageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("add_image") as! AddImageViewController
            let item = ItemEntity()
            item.id = selectedItem.id
            item.isList = selectedItem.isList
            item.name = selectedItem.name
            item.path = selectedItem.path
            next.item = item
            next.finishDelegate = self.finishDelegate
            
            self.navigationController?.pushViewController(next, animated: true)
        case .DumpItem:
            let next: DumpItemViewController = self.storyboard?.instantiateViewControllerWithIdentifier("dump_item") as! DumpItemViewController
            let item = ItemEntity()
            item.id = selectedItem.id
            item.name = selectedItem.name
            item.isList = selectedItem.isList
            item.owningItems = selectedItem.owningItems
            item.path = selectedItem.path
            next.item = item
            next.finishDelegate = self.finishDelegate
            
            self.navigationController?.pushViewController(next, animated: true)
        case .DeleteItem:
            let next: DeleteItemViewController = self.storyboard?.instantiateViewControllerWithIdentifier("delete_item") as! DeleteItemViewController
            let item = ItemEntity()
            item.id = selectedItem.id
            item.name = selectedItem.name
            item.isList = selectedItem.isList
            item.owningItems = selectedItem.owningItems
            item.path = selectedItem.path
            next.item = item
            next.finishDelegate = self.finishDelegate
            
            self.navigationController?.pushViewController(next, animated: true)
        }

        
    }
    
}

extension TargetItemSelectViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let image = UIImage(named: "housekeeping")!
        
        let newHeight:CGFloat = 55
        let scale = newHeight / image.size.height
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = NSLocalizedString("Prompt.SelectItem.NoItem", comment: "")
        let font = UIFont.systemFontOfSize(16)
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName : UIColor.darkGrayColor()])
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = NSLocalizedString("Prompt.SelectItem.NoItem.Detail", comment: "")
        let font = UIFont.systemFontOfSize(12)
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName : UIColor.darkGrayColor()])
    }
    
}