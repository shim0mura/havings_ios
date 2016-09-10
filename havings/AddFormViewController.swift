//
//  AddFormViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/18.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import QBImagePicker
import EasyTipView

class AddFormViewController: UIViewController {
    
    var item: ItemEntity = ItemEntity()
    var typeAdd: Bool = true
    
    var isTagViewHidden: Bool = false
    var activeInput: Int = 0
    var isSending: Bool = false
    
    let selectedImageTag = 50
    let selectedImageDateTag = 51
    let selectedImageMemoTag = 52
    
    let nameInputFieldTag = 60
    let tagInputFieldTag = 61
    let memoInputFieldTag = 62
    let garbageReasonInputFieldTag = 64
    
    let currentDate = NSDate()
    
    var originalMarginBetweenAutoComp: Int?
    var originalMarginBetweenTagField: Int?
    
    var listEntities: [CanBelongListEntity] = []
    var belongList: CanBelongListEntity? = nil
    
    var defaultTags: [MultiAutoCompleteToken] = []
    
    var itemTypePrompt: String = NSLocalizedString("Prompt.Item", comment: "")
    
    @IBOutlet weak var scrollContentView: MyScrollView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet weak var counterContainer: UIView!
    
    @IBOutlet weak var itemTypeIcon: UIImageView!
    @IBOutlet weak var imageCollectionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addCameraContainer: UIView!
    @IBOutlet weak var addCameraHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tagShownLeadConstraint: NSLayoutConstraint!
    @IBOutlet weak var addGalleryContainer: UIView!
    @IBOutlet weak var addGalleryHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var itemCountLabel: UILabel!
    
    @IBOutlet weak var itemCountStepper: UIStepper!
    @IBOutlet weak var counterContainerConstraint: NSLayoutConstraint!
    
    //@IBOutlet weak var counterContainerMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var counterContainerMarginConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameField: AutoCompleteTextField!
    
    @IBOutlet weak var memoField: UITextView!
    
    @IBOutlet weak var tagInputField: AutoCompleteTextField!
    @IBOutlet weak var tagShowingView: TagListView!
    
    @IBOutlet weak var tagViewHeightConstraint: NSLayoutConstraint!
    //@IBOutlet weak var marginBetweenAutoComp: NSLayoutConstraint!
    @IBOutlet weak var marginBetweenAutoComp: NSLayoutConstraint!
    
    @IBOutlet weak var privateTypeDetailLabel: UILabel!
    @IBOutlet weak var privateTypeSwitch: UISwitch!
    @IBOutlet weak var selectedBelongListLabel: UILabel!
    @IBOutlet weak var marginBetweenTagField: NSLayoutConstraint!
    
    @IBOutlet weak var garbageContainer: UIView!
    @IBOutlet weak var isGarbageSwitch: UISwitch!
    
    @IBOutlet weak var garbageReasonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var garbageReasonField: UITextView!
    
    @IBOutlet weak var garbageReasonLabel: UILabel!
    
    @IBOutlet weak var postButton: UIButton!
    
    
    @IBOutlet weak var nameContainer: UIView!
    
    @IBOutlet weak var imageContainer: UIView!
    
    @IBOutlet weak var tagContainer: UIView!

    @IBOutlet weak var memoContainer: UIView!
    
    @IBOutlet weak var belongListContainer: UIView!
    
    @IBOutlet weak var privateTypeContainer: UIView!
    
    @IBOutlet weak var imageContainerHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var countHelpImage: UIImageView!
    
    @IBOutlet weak var belongListHelpImage: UIImageView!
    
    @IBOutlet weak var tagHelpImage: UIImageView!
    
    @IBOutlet weak var garbageHelp: UIImageView!
    
    weak var finishDelegate: FinishItemUpdateDelegate?
    
    private var tooltip: EasyTipView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if item.name == nil && item.id == nil {
            item.isList = false
            item.privateType = 0
        }
        
        self.automaticallyAdjustsScrollViewInsets = false

        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
                
        nameField.delegate = self
        tagInputField.delegate = self
        memoField.delegate = self
        garbageReasonField.delegate = self
        self.imageCollectionView.emptyDataSetSource = self
        self.imageCollectionView.emptyDataSetDelegate = self
        tagShowingView.delegate = self
        
        countHelpImage.userInteractionEnabled = true
        belongListHelpImage.userInteractionEnabled = true
        tagHelpImage.userInteractionEnabled = true
        garbageHelp.userInteractionEnabled = true

        API.callArray(Endpoint.CanBelongList.Get){ response in
            switch response {
            case .Success(let result):
                self.listEntities = result
                if let list = result.first {
                    if let listId = self.item.listId, let index = result.indexOf({$0.id == listId}) {
                        self.belongList = result[index]
                        self.selectedBelongListLabel.text = result[index].name

                    }else{
                        self.belongList = list
                    }
                    if self.belongList?.privateType > 0 {
                        self.privateTypeSwitch.on = false
                        self.privateTypeSwitch.enabled = false
                        self.privateTypeDetailLabel.text = NSLocalizedString("Prompt.ItemForm.IsPublic.ForceDetail", comment: "")
                    }
                }
            case .Failure(let error):
                print("failure \(error)")
            }
        }
        
        if let defaultItemName = self.item.name {
            nameField.text = defaultItemName + " "
        }
        
        if self.typeAdd {
        
        }else{
            imageContainer.hidden = true
            marginBetweenAutoComp.constant = 0
            /*
            imageCollectionHeightConstraint.constant = 0
            addCameraContainer.hidden = true
            addCameraHeightConstraint.constant = 0
            addGalleryContainer.hidden = true
            addGalleryHeightConstraint.constant = 0
            */
            imageContainerHeightConstraint.constant = 0
            postButton.setTitle(NSLocalizedString("Prompt.ItemForm.EditItem", comment: ""), forState: .Normal)
            postButton.setTitle(NSLocalizedString("Prompt.ItemForm.EditItem", comment: ""), forState: .Selected)
            
            garbageContainer.hidden = true
            garbageReasonField.hidden = true
            garbageReasonLabel.hidden = true
            garbageReasonHeightConstraint.constant = 0
            
            if item.isGarbage == true {
                counterContainer.hidden = true
                counterContainerConstraint.constant = 0
                counterContainerMarginConstraint.constant = 0
            }

        }
        
        let isList: Bool = self.item.isList ?? false
        
        if isList {
            self.itemTypePrompt = NSLocalizedString("Prompt.List", comment: "")
            
            counterContainer.hidden = true
            counterContainerConstraint.constant = 0
            counterContainerMarginConstraint.constant = 0
            
            // スイッチ行のマージンくらいは一番下に開けておいても良さそうだし
            // その辺の管理がダルかったので特にそこは詰めない
            garbageContainer.hidden = true
            garbageReasonField.hidden = true
            garbageReasonLabel.hidden = true
            garbageReasonHeightConstraint.constant = 0

        }else{
            self.itemTypeIcon.image = UIImage(named: "icon_type_item")
            self.nameField.placeholder = NSLocalizedString("Prompt.ItemForm.ItemPlaceHolder", comment: "")
            
            itemCountStepper.value = Double(self.item.count ?? 1)
            setItemCounter()
            
            garbageReasonHeightConstraint.constant = 0
            garbageReasonLabel.hidden = true
        }
        
        if typeAdd && isList {
            self.title = NSLocalizedString("Prompt.Action.AddList", comment: "")
        }else if typeAdd && !isList{
            self.title = NSLocalizedString("Prompt.Action.AddItem", comment: "")
        }else if !typeAdd && isList{
            self.title = NSLocalizedString("Prompt.Action.EditList", comment: "")
        }else{
            self.title = NSLocalizedString("Prompt.Action.EditItem", comment: "")

        }
        
        defaultTags = DefaultTagPresenter.getDefaultTags()
        
        nameField.autoCompleteTokens = defaultTags.map({$0 as MultiAutoCompleteToken})
        tagInputField.autoCompleteTokens = defaultTags.map({$0 as MultiAutoCompleteToken})
        
        nameField.onTextChange = {[weak self] str in
            let height = self!.nameField.autoCompleteTableView?.frame.height ?? 0
            self!.marginBetweenAutoComp.constant = height + 8
        }
        nameField.onSelect = {[weak self] str, indexPath in
            if let tagField = self?.tagInputField {
                if !tagField.inputTextTokens.contains(str) {
                    self?.tagShowingView.addTag(str)
                    self?.tagInputField.addInputToken(str)
                }
            }
        }
        
        tagShowingView.textFont = UIFont.systemFontOfSize(15)
        if let tags = self.item.tags {
            tagInputField.defaultText = tags.joinWithSeparator(", ") + ", "
        }
        tagInputField.inputTextTokens.forEach{
            if !$0.isEmpty {
                tagShowingView.addTag($0)
            }
        }
        
        if let t = tagInputField.autoCompleteTableView {
            let screenSize = UIScreen.mainScreen().bounds.size

            var frame = t.frame
            frame.origin.x = 85
            frame.size.width = screenSize.width - (frame.origin.x + 10)
            t.frame = frame
        }

        tagInputField.onTextChange = {[weak self] str in
            self?.memoContainer.removeBorder()
            self?.memoContainer.addTopBorderWithColor(UIColorUtil.borderColor, width: 1)
        }
        //tagInputField.text? = self.tags?.joinWithSeparator(" ") ?? ""
        
        if self.item.privateType == nil || self.item.privateType == 0 {
            privateTypeSwitch.on = true
            self.privateTypeDetailLabel.text = String(format: NSLocalizedString("Prompt.ItemForm.IsPublic.Detail", comment: ""), self.itemTypePrompt)
        }else{
            privateTypeSwitch.on = false
            self.privateTypeDetailLabel.text = String(format: NSLocalizedString("Prompt.ItemForm.IsPublic.NegativeDetail", comment: ""), self.itemTypePrompt)
        }
        
        self.memoField.text = self.item.description
        
        self.nameContainer.addBottomBorderWithColor(UIColorUtil.borderColor, width: 1)
        self.imageContainer.addBottomBorderWithColor(UIColorUtil.borderColor, width: 1)
        self.counterContainer.addBottomBorderWithColor(UIColorUtil.borderColor, width: 1)
        self.belongListContainer.addBottomBorderWithColor(UIColorUtil.borderColor, width: 1)
        self.privateTypeContainer.addBottomBorderWithColor(UIColorUtil.borderColor, width: 1)
        //self.tagContainer.addBottomBorderWithColor(UIColorUtil.borderColor, width: 1)
        self.memoContainer.addTopBorderWithColor(UIColorUtil.borderColor, width: 1)
        self.memoContainer.addBottomBorderWithColor(UIColorUtil.borderColor, width: 1)
        //self.garbageContainer.addBottomBorderWithColor(UIColorUtil.borderColor, width: 1)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // http://qiita.com/ysk_1031/items/3adb1c1bf5678e7e6f98
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(AddFormViewController.keyboardWillBeShown(_:)),
                                                         name: UIKeyboardWillShowNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(AddFormViewController.keyboardWillBeHidden(_:)),
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
                
                let convertedKeyboardFrame = self.scrollContentView.convertRect(keyboardFrame, fromView: nil)
                var shownY: CGFloat = 0
                if self.activeInput == tagInputFieldTag {
                    let originY = self.tagInputField.superview?.frame.minY ?? 0
                    // 44: textFieldの高さ
                    // 100: autoCompのテーブルの高さ(3行分)
                    shownY = originY + 44 + 100 + self.scrollContentView.contentOffset.y
                    
                }else if self.activeInput == memoInputFieldTag {
                    let originY = self.memoField.superview?.frame.maxY ?? 0
                    shownY = originY + 100
                }else if self.activeInput == garbageReasonInputFieldTag {
                    print("garbage")
                    let originY = self.garbageReasonField.superview?.frame.maxY ?? 0
                    shownY = originY + 230
                }
                
                let offsetY: CGFloat = shownY - CGRectGetMinY(convertedKeyboardFrame)
                print(self.scrollContentView.contentOffset.y)
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
        self.scrollContentView.contentInset = contentInsets
        self.scrollContentView.scrollIndicatorInsets = contentInsets
        self.scrollContentView.contentOffset = CGPointMake(0, moveSize)
        
        UIView.commitAnimations()
    }
    
    func restoreScrollViewSize() {
        self.scrollContentView.contentInset = UIEdgeInsetsZero
        self.scrollContentView.scrollIndicatorInsets = UIEdgeInsetsZero
    }
    
    @IBAction func backButtonPress(sender: AnyObject) {
        if let c = self.navigationController?.viewControllers {
            let root = c.first
            let iii = root == self
            if iii {
                self.navigationController?.dismissViewControllerAnimated(true){
                }
            }
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func itemCountChanged(sender: UIStepper) {
        print("velue change")
        setItemCounter()
    }
    
    @IBAction func itemCountHelp(sender: UITapGestureRecognizer) {
        tooltip = EasyTipView(text: NSLocalizedString("Prompt.Tooltip.Form.ItemCount", comment: ""))
        tooltip?.backgroundColor = UIColorUtil.accentColor
        tooltip?.show(forView: self.countHelpImage, withinSuperview: self.scrollContentView)
    }

    @IBAction func belongListHelp(sender: UITapGestureRecognizer) {
        tooltip = EasyTipView(text: NSLocalizedString("Prompt.Tooltip.Form.BelongList", comment: ""))
        tooltip?.backgroundColor = UIColor(red:0.43, green: 0.72, blue: 0.86, alpha: 1.0)
        tooltip?.show(forView: self.belongListHelpImage, withinSuperview: self.scrollContentView)
    }
    
    @IBAction func tagHelp(sender: UITapGestureRecognizer) {
        tooltip = EasyTipView(text: NSLocalizedString("Prompt.Tooltip.Form.Tag", comment: ""))
        tooltip?.backgroundColor = UIColor(red:0.81, green: 0.89, blue: 0.51, alpha: 1.0)
        tooltip?.show(forView: self.tagHelpImage, withinSuperview: self.scrollContentView)
    }
    
    @IBAction func garbageHelp(sender: UITapGestureRecognizer) {
        tooltip = EasyTipView(text: NSLocalizedString("Prompt.Tooltip.Form.Garbage", comment: ""))
        tooltip?.backgroundColor = UIColor(red:0.89, green: 0.53, blue: 0.57, alpha: 1.0)
        tooltip?.show(forView: self.garbageHelp, withinSuperview: self.scrollContentView)
    }
    
    @IBAction func isAsGarbage(sender: UISwitch) {
        if sender.on {
            garbageReasonHeightConstraint.constant = 80
            garbageReasonLabel.hidden = false
        }else{
            garbageReasonHeightConstraint.constant = 0
            garbageReasonLabel.hidden = true
        }
    }
    
    @IBAction func privateTypeSwitchChanged(sender: UISwitch) {
        print("switch value changed")
        if self.belongList?.privateType > 0 {
            self.privateTypeSwitch.on = false
            self.privateTypeDetailLabel.text = NSLocalizedString("Prompt.ItemForm.IsPublic.ForceDetail", comment: "")
        }else{
            if sender.on {
                self.privateTypeDetailLabel.text = String(format: NSLocalizedString("Prompt.ItemForm.IsPublic.Detail", comment: ""), self.itemTypePrompt)
            }else{
                self.privateTypeDetailLabel.text = String(format: NSLocalizedString("Prompt.ItemForm.IsPublic.NegativeDetail", comment: ""), self.itemTypePrompt)
            }
        }
    }
    

    @IBAction func tapTagView(sender: AnyObject) {
        print("tag tap")
        hideTagView()
    }
    
    @IBAction func selectList(sender: AnyObject) {
        print("select list")
        let next: BelongListSelectViewController? = self.storyboard?.instantiateViewControllerWithIdentifier("belong_list_select") as? BelongListSelectViewController
        if let listSelectVC = next {
            listSelectVC.listEntities = self.listEntities
            listSelectVC.formDelegate = self
            self.presentViewController(listSelectVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func postForm(sender: AnyObject) {
        print("button tapped!!")
        if isSending {
            return
        }
        
        guard let name = self.nameField.text where !name.isEmpty else {
            let title = self.item.isList! ? NSLocalizedString("Prompt.ItemForm.ListNameEmpty", comment: "") : NSLocalizedString("Prompt.ItemForm.ItemNameEmpty", comment: "")
            self.simpleAlertDialog(title, message: nil)
            
            return
        }
        
        if self.typeAdd && self.item.isList! && (self.item.imageDataForPost == nil || self.item.imageDataForPost!.isEmpty) {
            self.simpleAlertDialog(NSLocalizedString("Prompt.ItemForm.ImageEmpty", comment: ""), message: NSLocalizedString("Prompt.ItemForm.ImageEmpty.detail", comment: ""))
            
            return
        }
        
        self.isSending = true

        let spinnerAlert = UIAlertController(title: nil, message: NSLocalizedString("Prompt.WaitForPost", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        
        let spinnerIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        
        spinnerIndicator.center = CGPointMake(135.0, 65.5)
        spinnerIndicator.color = UIColor.blackColor()
        spinnerIndicator.startAnimating()
        
        spinnerAlert.view.addSubview(spinnerIndicator)
        self.presentViewController(spinnerAlert, animated: false, completion: nil)
        
        //itemEntity.isList = self.isList
        self.item.name = name
        //itemEntity.imageDataForPost = imageEntities
        self.item.privateType = (self.privateTypeSwitch.on ? 0 : 3)
        self.item.description = self.memoField.text
        self.item.listId = self.belongList?.id
        self.item.tagList = self.tagInputField.inputTextTokens.joinWithSeparator(",")
        self.item.count = Int(self.itemCountStepper.value)
        self.item.isGarbage = self.isGarbageSwitch.on
        self.item.garbageReason = self.garbageReasonField.text
        
        if typeAdd {
            API.call(Endpoint.Item.Post(item: self.item)){ response in
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
                        if status == TooltipManager.ShowStatus.List.rawValue || status == TooltipManager.ShowStatus.Item.rawValue {
                            TooltipManager.setNextStatus()
                        }else if let g = self.item.isGarbage where g == true {
                            TooltipManager.setNextStatus()
                        }
                    }
                    TooltipManager.setNextStatus()
                    
                    let isPublic: Bool
                    if let priv = result.privateType where priv > 0 {
                        isPublic = false
                    }else{
                        isPublic = true
                    }
                    self.navigationController?.dismissViewControllerAnimated(true){
                        print("dismiss controller")
                        self.finishDelegate?.finish(String(format: NSLocalizedString("Prompt.ItemForm.Success", comment: ""), self.item.name!), itemPath: result.path!, isPublic: isPublic)

                    }
                case .Failure(let error):
                    print(error)
                    spinnerAlert.dismissViewControllerAnimated(false, completion: nil)
                    self.simpleAlertDialog(NSLocalizedString("Prompt.FailureToAceess", comment: ""), message: nil)
                    
                    self.isSending = false
                }
            }
        }else{
            guard let itemId = self.item.id else {
                return
            }
            API.call(Endpoint.Item.Put(itemId: itemId, item: self.item)){ response in
                switch response {
                case .Success(let result):
                    spinnerAlert.dismissViewControllerAnimated(false, completion: nil)
                    self.isSending = false
                    
                    if let errors = result.errors as? Dictionary<String, AnyObject> {
                        self.showFailedAlert(errors)
                        return
                    }
                    
                    let isPublic: Bool
                    if let priv = result.privateType where priv > 0 {
                        isPublic = false
                    }else{
                        isPublic = true
                    }
                    
                    self.navigationController?.dismissViewControllerAnimated(true){
                        print("dismiss controller")
                        self.finishDelegate?.finish(String(format: NSLocalizedString("Prompt.ItemForm.Success.Edit", comment: ""), self.item.name!), itemPath: result.path!, isPublic: isPublic)

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
    
    
    func setItemCounter(){
        itemCountLabel.text = String(Int(itemCountStepper.value))
    }
    
    func hideTagView(){
        let hideState = !self.isTagViewHidden
        tagShowingView.hidden = hideState
        tagInputField.hidden = !hideState
        
        if hideState {
            print("show input!")
            tagInputField.becomeFirstResponder()
            self.marginBetweenTagField.constant = 100 + 8
            self.tagHelpImage.hidden = true
            self.tagShownLeadConstraint.constant = -32
        }else {
            print("show tag!")
            print(self.tagInputField.text)
            print(tagInputField.inputTextTokens)
            tagShowingView.removeAllTags()
            tagInputField.inputTextTokens.forEach{
                if !$0.isEmpty {
                    tagShowingView.addTag($0)
                }
            }
            self.marginBetweenTagField.constant = 8
            self.tagHelpImage.hidden = false
            self.tagShownLeadConstraint.constant = 8
        }
        
        self.isTagViewHidden = hideState
    }
    
    func addImageEntity(image: UIImage){
        let itemImage = ItemImageEntity()
        itemImage.imageByUIImage = image
        itemImage.addedDate = currentDate
        itemImage.setBase64Data()
        if self.item.imageDataForPost == nil {
            self.item.imageDataForPost = [itemImage]
        }else{
            self.item.imageDataForPost!.append(itemImage)
        }
    }
    
    func simpleAlertDialog(title: String, message: String?){
        let alert :UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(defaultAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showFailedAlert(errors: Dictionary<String, AnyObject>){
        let keys = errors.keys.sort()
        var alertTitle = NSLocalizedString("Prompt.FailureToAceess", comment: "")
        if !keys.isEmpty {
            let key: String = keys.first!
            let errorMessages = errors[key] as! [String]
            if let message = errorMessages.first {
                alertTitle = "\(key)\(message)"
            }
        }
        self.simpleAlertDialog(alertTitle, message: nil)
    }
}

extension AddFormViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("listImageCell", forIndexPath: indexPath)
        
        let imageEntity = self.item.imageDataForPost![indexPath.row]
        let imageView: UIImageView = cell.viewWithTag(selectedImageTag) as! UIImageView
        imageView.image = imageEntity.imageByUIImage
        let dateLabel: UILabel = cell.viewWithTag(selectedImageDateTag) as! UILabel
        dateLabel.text = DateTimeFormatter.getStrFromDate(imageEntity.addedDate!, format: DateTimeFormatter.formatYMD)
        let memoLabel: UILabel = cell.viewWithTag(selectedImageMemoTag) as! UILabel
        if let memo = imageEntity.memo {
            memoLabel.text = memo
        }else{
            memoLabel.text = "写真のメモ..."
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(100, 100)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("select!! \(indexPath.row)")
        let actionSheet:UIAlertController = UIAlertController(title:"写真情報の編集",
                                                              message: nil,
                                                              preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancelAction:UIAlertAction = UIAlertAction(title: "キャンセル",
                                                       style: UIAlertActionStyle.Cancel,
                                                       handler:{
                                                        (action:UIAlertAction!) -> Void in
                                                        print("Cancel")
        })
        
        let defaultAction:UIAlertAction = UIAlertAction(title: "この写真のメモ・追加日を編集する",
                                                        style: UIAlertActionStyle.Default,
                                                        handler:{
                                                            (action:UIAlertAction!) -> Void in
                                                            let next: ImageDataEditViewController? = self.storyboard?.instantiateViewControllerWithIdentifier("image_data_edit") as? ImageDataEditViewController
                                                            if let imageDataEditVC = next {
                                                                imageDataEditVC.imageEntity = self.item.imageDataForPost![indexPath.row]
                                                                imageDataEditVC.editDelegate = self
                                                                self.presentViewController(imageDataEditVC, animated: true, completion: nil)
                                                            }
        })
        
        
        let destructiveAction:UIAlertAction = UIAlertAction(title: "この写真の追加を取り消す",
                                                            style: UIAlertActionStyle.Destructive,
                                                            handler:{
                                                                (action:UIAlertAction!) -> Void in
                                                                print("Destructive")
                                                                
                                                        self.item.imageDataForPost!.removeAtIndex(indexPath.row)
                                                        self.imageCollectionView.reloadData()
        })
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(defaultAction)
        actionSheet.addAction(destructiveAction)
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.item.imageDataForPost?.count ?? 0
    }

}

extension AddFormViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let image = UIImage(named: "icon_type_item")!
        
        let newHeight:CGFloat = 50
        let scale = newHeight / image.size.height
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "写真がありません"
        let font = UIFont.systemFontOfSize(16)
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName : UIColor.darkGrayColor()])
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "最大100件まで表示できます"
        let font = UIFont.systemFontOfSize(12)
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName : UIColor.darkGrayColor()])
    }
    
}

extension AddFormViewController: QBImagePickerControllerDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {

    @IBAction func addCameraImage(sender: AnyObject) {
        print("start camera")
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.cameraCaptureMode = .Photo
            self.presentViewController(picker, animated: true, completion: nil)
        }else{
            let alert :UIAlertController = UIAlertController(title: "カメラ機能を起動できません", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            
            presentViewController(alert, animated: true, completion: nil)
            return
        }
    }

    @IBAction func addGalleryImage(sender: AnyObject) {
        print("start gallery")
        let picker = QBImagePickerController()
        picker.delegate = self
        picker.mediaType = QBImagePickerMediaType.Image
        picker.allowsMultipleSelection = true
        picker.showsNumberOfSelectedAssets = true
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("camera finished!!")
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(AddFormViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        print("saved")
        

        //dismissViewControllerAnimated(true, completion: nil)
        
        let scale = 800 / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(800, newHeight))
        image.drawInRect(CGRectMake(0, 0, 800, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        print(newImage)
        self.addImageEntity(newImage)
        self.imageCollectionView.reloadData()

        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        if error != nil {
            print(error.code)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("camera cancel!!")
        dismissViewControllerAnimated(true, completion: nil)

    }
    
    func qb_imagePickerController(imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        print("finish gallery!!")
        
        let manager: PHImageManager = PHImageManager()
        let option = PHImageRequestOptions()
        option.synchronous = true
        option.resizeMode = .Fast
        for asset in assets {
            print(asset)
            if let aset = asset as? PHAsset {
                manager.requestImageForAsset(aset,
                                             targetSize: CGSize(width: 800, height: 800),
                                             contentMode: .AspectFit, options: option) {
                                                image, info in
                                                print("UIImage get!")
                                                print(image)
                                                if let i = image {
                                                    self.addImageEntity(i)
                                                }
                                                print("add image!!")
                }
            }
        }
        self.imageCollectionView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)

    }
    
    func qb_imagePickerControllerDidCancel(imagePickerController: QBImagePickerController!) {
        print("gallery cancel!!")
        dismissViewControllerAnimated(true, completion: nil)

    }
    
}

extension AddFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.marginBetweenAutoComp.constant = 8
        self.marginBetweenTagField.constant = 8
        print("return field")
        textField.resignFirstResponder()
        self.scrollContentView.marginTable = nil
        
        if self.activeInput == tagInputFieldTag {
            hideTagView()
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField.tag == self.nameInputFieldTag {
            self.scrollContentView.marginTable = self.nameField.autoCompleteTableView
        }else if textField.tag == self.tagInputFieldTag {
            self.scrollContentView.marginTable = self.tagInputField.autoCompleteTableView
        }
        
        self.activeInput = textField.tag
        return true
    }
}

extension AddFormViewController: UITextViewDelegate {
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        self.scrollContentView.memoTextView = nil
        print("text view end")
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        print("end")
        textView.superview?.addBottomBorderWithColor(UIColorUtil.borderColor, width: 1)

    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        print("text view start \(self.activeInput)")
        //textView.superview?.addBottomBorderWithColor(UIColor.clearColor(), width: 0)
        textView.superview?.removeBorder()
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        self.activeInput = textView.tag
        self.scrollContentView.memoTextView = textView
        print("text view start \(self.activeInput)")
        return true
    }
}

extension AddFormViewController: TagListViewDelegate {
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        print("tagtap")
        hideTagView()
    }
}

extension AddFormViewController: ImageDataEditViewDelegate {
    func editImageData(imageEntity: ItemImageEntity){
        self.imageCollectionView.reloadData()
    }
}

extension AddFormViewController: BelongListSelectViewDelegate {
    func changeBelongList(list: CanBelongListEntity){
        if self.listEntities.contains({$0 === list}) {
            print("list contained")
            self.belongList = list
            self.selectedBelongListLabel.text = list.name
            if list.privateType > 0 {
                self.privateTypeSwitch.on = false
                self.privateTypeSwitch.enabled = false
                self.privateTypeDetailLabel.text = NSLocalizedString("Prompt.ItemForm.IsPublic.ForceDetail", comment: "")
            }else{
                self.privateTypeSwitch.enabled = true
                if self.privateTypeSwitch.on {
                    self.privateTypeDetailLabel.text = String(format: NSLocalizedString("Prompt.ItemForm.IsPublic.Detail", comment: ""), self.itemTypePrompt)
                }else{
                    self.privateTypeDetailLabel.text = String(format: NSLocalizedString("Prompt.ItemForm.IsPublic.NegativeDetail", comment: ""), self.itemTypePrompt)
                }
            }
        }
    }
}

class MyScrollView: UIScrollView {
    
    var marginTable: UITableView? = nil
    var memoTextView: UITextView? = nil
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touch!!!!")
        if let table = self.marginTable {
            table.touchesBegan(touches, withEvent: event)
        }else{
            print("super began")
            super.touchesBegan(touches, withEvent: event)
        }
        
        //self.marginTable?.touchesBegan(touches, withEvent: event)
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touchend!!!!")
        if let table = self.marginTable {
            table.touchesEnded(touches, withEvent: event)
        }else if let memoText = memoTextView {
            memoText.resignFirstResponder()
            self.memoTextView = nil
        }else{
            print("super end")
            super.touchesEnded(touches, withEvent: event)
        }
        
        //self.marginTable?.touchesEnded(touches, withEvent: event)
    }
    
}

protocol ImageDataEditViewDelegate: class {
    func editImageData(imageEntity: ItemImageEntity)
}

protocol BelongListSelectViewDelegate: class {
    func changeBelongList(list: CanBelongListEntity)
}