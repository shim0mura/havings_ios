//
//  ImageDataEditViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/24.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class ImageDataEditViewController: UIViewController, PostAlertUtil {

    @IBOutlet weak var selectDateField: UITextField!
    @IBOutlet weak var selectedDate: UILabel!
    @IBOutlet weak var memoTextView: UITextView!
    var toolBar:UIToolbar!
    var addedDatePicker: UIDatePicker!
    let currentDate = NSDate()
    
    weak var editDelegate: ImageDataEditViewDelegate?
    var imageEntity: ItemImageEntity?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selectDateField.hidden = true
        
        // http://qiita.com/matsuhisa_h/items/4bb9803828efb89e0305
        // UILabelにinputViewは設定できないので
        // 裏に隠れたTextFieldを用意(selectDateFieldがそれ)
        addedDatePicker = UIDatePicker()
        addedDatePicker.maximumDate = currentDate
        addedDatePicker.addTarget(self, action: #selector(ImageDataEditViewController.changedDateEvent), forControlEvents: UIControlEvents.ValueChanged)
        addedDatePicker.datePickerMode = UIDatePickerMode.Date
        if let addedDate = imageEntity?.addedDate {
            addedDatePicker.date = addedDate
        }else{
            addedDatePicker.date = currentDate
            imageEntity?.addedDate = currentDate
        }
        changeLabelDate(addedDatePicker.date)
        
        memoTextView.text = imageEntity?.memo
        memoTextView.editable = true
        
        selectedDate.userInteractionEnabled = true
        selectDateField.inputView = addedDatePicker
        
        // UIToolBarの設定
        toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = .BlackTranslucent
        toolBar.tintColor = UIColor.whiteColor()
        toolBar.backgroundColor = UIColor.blackColor()
        
        let toolBarBtn      = UIBarButtonItem(title: "完了", style: .Plain, target: self, action: #selector(ImageDataEditViewController.tappedToolBarBtn))
        let toolBarBtnToday = UIBarButtonItem(title: "今日", style: .Plain, target: self, action: #selector(ImageDataEditViewController.tappedToolBarBtnToday))
        
        toolBarBtn.tag = 1
        toolBar.items = [toolBarBtn, toolBarBtnToday]
        
        selectDateField.inputAccessoryView = toolBar
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        selectDateField.resignFirstResponder()
        memoTextView.resignFirstResponder()
    }
    
    // 「完了」を押すと閉じる
    func tappedToolBarBtn(sender: UIBarButtonItem) {
        selectDateField.resignFirstResponder()
    }
    
    // 「今日」を押すと今日の日付をセットする
    func tappedToolBarBtnToday(sender: UIBarButtonItem) {
        addedDatePicker.date = currentDate
        changeLabelDate(currentDate)
    }
    
    //
    func changedDateEvent(sender:AnyObject?){
        //var dateSelecter: UIDatePicker = sender as! UIDatePicker
        self.changeLabelDate(addedDatePicker.date)
    }
    
    func changeLabelDate(date:NSDate) {
        selectedDate.text = DateTimeFormatter.getStrWithWeekday(date)
    }
    
    
    @IBAction func selectDate(sender: AnyObject) {
        selectDateField.becomeFirstResponder()
    }
    
    
    @IBAction func cancelInput(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func doneInput(sender: AnyObject) {
        let tx = self.memoTextView.text
        
        if tx.characters.count >= 100 {
            self.simpleAlertDialog(NSLocalizedString("Prompt.Item.Image.Memo.OverLength", comment: ""), message: nil)
            return
        }
        
        dismissViewControllerAnimated(true){
            self.imageEntity?.addedDate = self.addedDatePicker.date
            
            self.imageEntity?.memo = self.memoTextView.text

            if let im = self.imageEntity {
                self.editDelegate?.editImageData(im)
            }
        }
    }
    
    /*
    @IBAction func doneInput(sender: AnyObject) {
        dismissViewControllerAnimated(true){
            self.imageEntity?.addedDate = self.addedDatePicker.date
            let tx = self.memoTextView.text
            if !tx.isEmpty {
                self.imageEntity?.memo = self.memoTextView.text
            }
            
            if let im = self.imageEntity {
                self.editDelegate?.editImageData(im)                
            }
        }
    }
    */

}
