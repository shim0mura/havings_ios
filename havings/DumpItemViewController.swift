//
//  DumpItemViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/30.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class DumpItemViewController: UIViewController, PostAlertUtil {

    var item: ItemEntity = ItemEntity()
    var isSending: Bool = false
    var canDumpFellow: Bool = false
    
    let itemNameLabelTag: Int = 10
    let itemTypeImageTag: Int = 11
    let itemCountLabelTag: Int = 12
    let privateTypeImageTag: Int = 13
    
    var itemList: [(item: ItemEntity, isFellow: Bool)] = []
    
    @IBOutlet weak var garbageReasonTextView: UITextView!
    
    @IBOutlet weak var fellowContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    weak var finishDelegate: FinishItemUpdateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.garbageReasonTextView.delegate = self

        let childItems = item.owningItems ?? []
        let isList = item.isList ?? false
        
        if isList && !childItems.isEmpty {
            childItems.forEach{
                itemList.append((item: $0, isFellow: false))
            }
            self.canDumpFellow = true
            self.tableView.reloadData()
        }else{
            self.fellowContainer.hidden = true
            self.tableView.hidden = true
        }
        
        self.title = isList ? NSLocalizedString("Prompt.Action.DumpList", comment: "") : NSLocalizedString("Prompt.Action.DumpItem", comment: "")
        self.garbageReasonTextView.superview?.addBottomBorderWithColor(UIColorUtil.borderColor, width: 1)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touch")
        garbageReasonTextView.resignFirstResponder()
    }

    @IBAction func tapSelectAll(sender: AnyObject) {
        print("selectAll")
        for i in 0..<itemList.count {
            self.itemList[i].isFellow = true
        }
        self.tableView.reloadData()
    }

    @IBAction func tapDeselectAll(sender: AnyObject) {
        print("DeselectAll")
        for i in 0..<itemList.count {
            self.itemList[i].isFellow = false
        }
        self.tableView.reloadData()
    }
    
    @IBAction func tapDump(sender: AnyObject) {
        print("dump!")
        if isSending {
            return
        }
        
        guard let itemId = self.item.id else {
            return
        }
        
        self.isSending = true
        self.item.isGarbage = true
        self.item.garbageReason = self.garbageReasonTextView.text
        var fellowIds: [Int] = []
        if self.canDumpFellow {
            itemList.forEach{
                if $0.isFellow {
                    fellowIds.append($0.item.id!)
                }
            }
        }
        
        let spinnerAlert = self.showConnectingSpinner()
        
        API.call(Endpoint.Item.Dump(itemId: itemId, item: self.item, fellowIds: fellowIds)){ response in
            switch response {
            case .Success(let result):
                spinnerAlert.dismissViewControllerAnimated(false, completion: nil)
                self.isSending = false
                
                if let errors = result.errors as? Dictionary<String, AnyObject> {
                    self.showFailedAlert(errors)
                    return
                }
                let s = TooltipManager.getStatus()
                if let status = s {
                    if status == TooltipManager.ShowStatus.Dump.rawValue {
                        TooltipManager.setNextStatus()
                    }
                }

                self.navigationController?.dismissViewControllerAnimated(true){
                    print("dismiss controller")
                    let isPublic: Bool
                    if let priv = self.item.privateType where priv > 0 {
                        isPublic = false
                    }else{
                        isPublic = true
                    }
                    self.finishDelegate?.finish(String(format: NSLocalizedString("Prompt.DumpItem.Success", comment: ""), self.item.name!), itemPath: self.item.path!, isPublic: isPublic)

                }
            case .Failure(let error):
                print(error)
                spinnerAlert.dismissViewControllerAnimated(false, completion: nil)
                self.simpleAlertDialog(NSLocalizedString("Prompt.FailureToAceess", comment: ""), message: nil)
                
                self.isSending = false
            }
        }
        
    }
    
}

extension DumpItemViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemList.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("fellowItem")! as UITableViewCell
        
        let itemInfo = self.itemList[indexPath.row]
        
        let itemName: UILabel = cell.viewWithTag(itemNameLabelTag) as! UILabel
        let itemTypeImage: UIImageView = cell.viewWithTag(itemTypeImageTag) as! UIImageView
        let itemCount: UILabel = cell.viewWithTag(itemCountLabelTag) as! UILabel
        let privateImage: UIImageView = cell.viewWithTag(privateTypeImageTag) as! UIImageView
        
        itemName.text = itemInfo.item.name
        if itemInfo.item.isList == true {
            itemTypeImage.image = UIImage(named: "icon_type_list")
        }else{
            itemTypeImage.image = UIImage(named: "icon_type_item")
        }
        itemCount.text = String(format: NSLocalizedString("Prompt.ItemCount", comment: ""), itemInfo.item.count!)
        if itemInfo.item.privateType == 0 {
            privateImage.hidden = true
        }else{
            privateImage.hidden = false
        }
        if itemInfo.isFellow {
            cell.accessoryType = .Checkmark
            itemName.textColor = UIColor.blackColor()
        }else{
            cell.accessoryType = .None
            itemName.textColor = UIColor.lightGrayColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)

        self.itemList[indexPath.row].isFellow = !self.itemList[indexPath.row].isFellow
        self.tableView.reloadData()
    }
}

extension DumpItemViewController: UITextViewDelegate {
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        print("text view end")
        textView.superview?.addBottomBorderWithColor(UIColorUtil.borderColor, width: 1)

        return true
    }

    func textViewDidBeginEditing(textView: UITextView) {
        print("text view start")
        textView.superview?.removeBorder()
    }
}
