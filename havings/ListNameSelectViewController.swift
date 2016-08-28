//
//  ListNameSelectViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/15.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import RealmSwift

class ListNameSelectViewController: UIViewController {

    enum ListSelect: Int {
        case FromPlace = 100
        case FromCloset = 200
        case FromCategory = 300
        case SelfInput = 400
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fromPlaceView: TouchableUIView!
    @IBOutlet weak var fromClosetView: TouchableUIView!
    @IBOutlet weak var selfInputView: TouchableUIView!
    @IBOutlet weak var fromCategoryView: TouchableUIView!

    @IBOutlet weak var label1: UILabel!
    
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var containerTopConstraint: NSLayoutConstraint!
    
    let tagStateImage: Int = 10
    let tagStateText: Int = 15
    let tagBaseForCategorySetion: Int = 1200
    let tagSelfInputTextField: Int = 800
    
    var selectedState: ListSelect = ListSelect.FromPlace
    var defaultTagByPlace: Results<TagEntity>?
    var defaultTagByCloset: Results<TagEntity>?
    var defaultTagByCategory: [Dictionary<String, [Dictionary<String, String>]>]?
    var defaultTags: [MultiAutoCompleteToken] = []
    
    var categoryCollapse: [Int: Bool] = [:]
    
    var selfInputCell: UITableViewCell? = nil
    var autoCompField: AutoCompleteTextField? = nil
    weak var finishDelegate: FinishItemUpdateDelegate?
    
    deinit {
        print("deinit list")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Prompt.ListNameSelect", comment: "")
        
        tableView.delegate = self
        tableView.dataSource = self
        fromPlaceView.delegate = self
        fromClosetView.delegate = self
        fromCategoryView.delegate = self
        selfInputView.delegate = self
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        defaultTagByPlace = DefaultTagPresenter.getDefaultTagsByType(DefaultTagPresenter.TAG_TYPE_PLACE)
        defaultTagByCloset = DefaultTagPresenter.getDefaultTagsByType(DefaultTagPresenter.TAG_TYPE_CLOSET)
        defaultTagByCategory = DefaultTagPresenter.getDefaultTagNamesByCategory()
        defaultTags = DefaultTagPresenter.getDefaultTags()
        
        let categoryCount = defaultTagByCategory?.count ?? 0
        for i in 0..<categoryCount {
            categoryCollapse[i] = true
        }
        
        setContainerColor(fromPlaceView, state: selectedState)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        defaultTagByPlace = nil
        defaultTagByCloset = nil
        defaultTagByCategory = nil
        defaultTags = []
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backToHome(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(ListNameSelectViewController.keyboardWillBeShown(_:)),
                                                         name: UIKeyboardWillShowNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(ListNameSelectViewController.keyboardWillBeHidden(_:)),
                                                         name: UIKeyboardWillHideNotification,
                                                         object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: UIKeyboardWillShowNotification,
                                                            object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: UIKeyboardWillHideNotification,
                                                            object: nil)
    }
    
    func keyboardWillBeShown(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue, animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
                restoreScrollViewSize()
                
                let convertedKeyboardFrame = self.tableView.convertRect(keyboardFrame, fromView: nil)
                var shownY: CGFloat = 0
                //if self.activeInput == tagInputFieldTag {
                    let originY = self.selfInputCell!.superview?.frame.minY ?? 0
                    // 44: textFieldの高さ
                    shownY = originY + 44
                
                
                let offsetY: CGFloat = shownY - CGRectGetMinY(convertedKeyboardFrame)
                print(shownY)
                print(offsetY)
                if offsetY < 0 { return }
                updateScrollViewSize(offsetY, duration: animationDuration)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        restoreScrollViewSize()
    }
    
    func updateScrollViewSize(moveSize: CGFloat, duration: NSTimeInterval) {
        UIView.beginAnimations("ResizeForKeyboard", context: nil)
        UIView.setAnimationDuration(duration)
        
        let contentInsets = UIEdgeInsetsMake(0, 0, moveSize, 0)
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
        self.tableView.contentOffset = CGPointMake(0, moveSize)
        
        UIView.commitAnimations()
    }
    
    func restoreScrollViewSize() {
        self.tableView.contentInset = UIEdgeInsetsZero
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero
    }

}

extension ListNameSelectViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        print("start")
        self.label1.hidden = true
        self.label2.hidden = true
        self.containerTopConstraint.constant = -115
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("resign")
        self.label1.hidden = false
        self.label2.hidden = false
        self.containerTopConstraint.constant = 8
        return true
    }
}

extension ListNameSelectViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        switch selectedState {
        case .FromPlace, .FromCloset, .SelfInput:
            return 1
        case .FromCategory:
            return defaultTagByCategory?.count ?? 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedState {
        case .FromPlace:
            return defaultTagByPlace?.count ?? 0
        case .FromCloset:
            return defaultTagByCloset?.count ?? 0
        case .FromCategory:
            guard let tagNames = defaultTagByCategory, let isCollapse = categoryCollapse[section] else {
                return 0
            }
            
            if isCollapse {
                return 0
            }
            
            let values = tagNames[section].first?.1
            return values?.count ?? 0
        case .SelfInput:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch selectedState {
        case .FromPlace:
            let cell = createTableViewCell(UITableViewCellStyle.Default)
            cell.textLabel?.text = defaultTagByPlace?[indexPath.row].name ?? nil
            cell.accessoryType = .DisclosureIndicator
            return cell
        case .FromCloset:
            let cell = createTableViewCell(UITableViewCellStyle.Default)
            cell.textLabel?.text = defaultTagByCloset?[indexPath.row].name ?? nil
            cell.accessoryType = .DisclosureIndicator
            return cell
        case .FromCategory:
            let cell = createTableViewCell(UITableViewCellStyle.Subtitle)
            let key = defaultTagByCategory?[indexPath.section].first
            let value = key?.1[indexPath.row]
            cell.textLabel?.text = value?["name"]
            cell.detailTextLabel?.text = value?["subtext"]
            cell.accessoryType = .DisclosureIndicator
            return cell
        case .SelfInput:
            //if selfInputCell == nil {
                
                selfInputCell = self.tableView.dequeueReusableCellWithIdentifier("selfInputCell")! as UITableViewCell
                
                let textField = selfInputCell!.contentView.viewWithTag(tagSelfInputTextField) as! AutoCompleteTextField
                textField.autoCompleteTokens = defaultTags.map({$0 as MultiAutoCompleteToken})
                textField.addBottomBorderWithColor(UIColorUtil.borderColor, width: 1)
                textField.delegate = self
                selfInputCell!.selectionStyle = UITableViewCellSelectionStyle.None
            //}
            
            return selfInputCell!
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch selectedState {
        case .FromPlace, .FromCloset, .FromCategory:
            return UITableViewAutomaticDimension
        case .SelfInput:
            return self.tableView.frame.height
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch selectedState {
        case .FromCategory:
            // よく分からんけど、reloadSectionしたときに
            // タップしたsectionHeaderが消えるので、その対策にadd subviewしてる
            // http://stackoverflow.com/questions/18490621/no-index-path-for-table-cell-being-reused
            let cell = createTableViewCell(UITableViewCellStyle.Subtitle)
            let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: cell.frame.height)
            let containerView = UIView(frame: frame)
            
            let key = defaultTagByCategory?[section].first
            let value = key?.1.first
            cell.textLabel?.text = value!["name"]
            cell.detailTextLabel?.text = value!["subtext"]
            cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
            cell.frame = frame
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(ListNameSelectViewController.sectionTapped(_:)))
            cell.addGestureRecognizer(gesture)
            cell.tag = section + tagBaseForCategorySetion
            
            containerView.addSubview(cell)
            return containerView
        default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch selectedState {
        case .FromCategory:
            return 44
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(selectedState)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let next: ListImagePickupViewController? = self.storyboard?.instantiateViewControllerWithIdentifier("select_list_image") as? ListImagePickupViewController
        
        switch selectedState {
        case .FromPlace:
            let listName: String = (self.defaultTagByPlace?[indexPath.row].name)!

            if let listImageSelectVC = next {
                listImageSelectVC.listName = listName
                listImageSelectVC.listTags = [listName]
                listImageSelectVC.finishDelegate = self.finishDelegate
                self.navigationController?.pushViewController(listImageSelectVC, animated: true)
            }
        case .FromCloset:
            let listName: String = (self.defaultTagByCloset?[indexPath.row].name)!
            
            if let listImageSelectVC = next {
                listImageSelectVC.listName = listName
                listImageSelectVC.listTags = [listName]
                listImageSelectVC.finishDelegate = self.finishDelegate
                self.navigationController?.pushViewController(listImageSelectVC, animated: true)
            }
        case .FromCategory:
            
            let key = defaultTagByCategory?[indexPath.section].first
            let value = key?.1[indexPath.row]
            
            let listName: String = value!["name"]!
            
            if let listImageSelectVC = next {
                listImageSelectVC.listName = listName
                listImageSelectVC.listTags = [listName]
                listImageSelectVC.finishDelegate = self.finishDelegate
                self.navigationController?.pushViewController(listImageSelectVC, animated: true)
            }
        default:
            break
        }
        
    }
    
    func sectionTapped(sender: UIGestureRecognizer){
        guard let tag = sender.view?.tag else {
            return
        }
        let sectionIndex = tag - tagBaseForCategorySetion
        categoryCollapse[sectionIndex] = !categoryCollapse[sectionIndex]!
        
        tableView.reloadSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    
    private func createTableViewCell(cellStyle: UITableViewCellStyle) -> UITableViewCell {
        let cell = UITableViewCell(style: cellStyle, reuseIdentifier: "cell")
        cell.textLabel?.font = UIFont.systemFontOfSize(15)
        cell.textLabel?.textColor = UIColor.darkGrayColor()
        if cellStyle == UITableViewCellStyle.Subtitle {
        
        }
        return cell
    }
    
    @IBAction func tapInputComplete(sender: AnyObject) {
        let textField = selfInputCell!.contentView.viewWithTag(tagSelfInputTextField) as! AutoCompleteTextField
        let next: ListImagePickupViewController? = self.storyboard?.instantiateViewControllerWithIdentifier("select_list_image") as? ListImagePickupViewController
        
        if let listImageSelectVC = next, let listName = textField.text where !listName.isEmpty {
            listImageSelectVC.listName = listName
            listImageSelectVC.listTags = textField.inputTextTokens
            listImageSelectVC.finishDelegate = self.finishDelegate
            self.navigationController?.pushViewController(listImageSelectVC, animated: true)
        }

    }
    
    
}

extension ListNameSelectViewController: TouchableUIViewDelegate {
    func viewDidTapped(view: TouchableUIView) {
        print("tapped!!")
        let tag = view.tag
        if tag == selectedState.rawValue {
            return
        }

        self.selectedState = ListSelect(rawValue: tag)!
        
        resetContainerColor()
        setContainerColor(view, state: selectedState)

        self.tableView.reloadData()
    }
    
    private func setContainerColor(view: TouchableUIView, state: ListSelect){
        let imageView: UIImageView  = view.viewWithTag(tagStateImage) as! UIImageView
        let label: UILabel = view.viewWithTag(tagStateText) as! UILabel
        label.textColor = UIColorUtil.accentColor
        
        switch state {
        case .FromPlace:
            imageView.image = UIImage(named: "RoomFilled-100")
        case .FromCloset:
            imageView.image = UIImage(named: "ClosetFilled-100")
        case .FromCategory:
            imageView.image = UIImage(named: "SofaFilled-100")
        case .SelfInput:
            imageView.image = UIImage(named: "EditFilled-100")
        }
    }

    private func resetContainerColor(){
        [ListSelect.FromPlace, ListSelect.FromCloset, ListSelect.FromCategory, ListSelect.SelfInput].forEach{
            let container: TouchableUIView = self.view.viewWithTag($0.rawValue) as! TouchableUIView
            let imageView: UIImageView = container.viewWithTag(tagStateImage) as! UIImageView
            let label: UILabel = container.viewWithTag(tagStateText) as! UILabel
            label.textColor = UIColorUtil.mainTextColor
            
            switch $0 {
            case .FromPlace:
                imageView.image = UIImage(named: "Room-100")
            case .FromCloset:
                imageView.image = UIImage(named: "Closet-100")
            case .FromCategory:
                imageView.image = UIImage(named: "Sofa-100")
            case .SelfInput:
                imageView.image = UIImage(named: "Edit-100")
            }
        }
    }
    
}
