//
//  AutoCompleteTextField.swift
//  AutocompleteTextfieldSwift
//  https://github.com/mnbayan/AutocompleteTextfieldSwift
//  Created by Mylene Bayan on 6/13/15.
//  Copyright (c) 2015 mnbayan. All rights reserved.
//

import Foundation
import UIKit

public class AutoCompleteTextField:UITextField {
    /// Manages the instance of tableview
    public var autoCompleteTableView:UITableView?
    /// Holds the collection of attributed strings
    //private lazy var attributedAutoCompleteStrings = [NSAttributedString]()
    /// Handles user selection action on autocomplete table view
    public var onSelect:(String, NSIndexPath) -> Void = {_,_ in}
    /// Handles textfield's textchanged
    public var onTextChange:(String) -> Void = {_ in}
    /// Font for the text suggestions
    public var autoCompleteTextFont = UIFont.systemFontOfSize(12)
    /// Color of the text suggestions
    public var autoCompleteTextColor = UIColor.blackColor()
    /// Used to set the height of cell for each suggestions
    public var autoCompleteCellHeight:CGFloat = 33.0
    /// The maximum visible suggestion
    public var maximumAutoCompleteCount = 3
    /// Used to set your own preferred separator inset
    public var autoCompleteSeparatorInset = UIEdgeInsetsZero
    /// Shows autocomplete text with formatting
    //public var enableAttributedText = false
    
    private var targetToken:String = ""
    public var inputTextTokens:[String] = []
    private var wordTokenizeChars = NSCharacterSet(charactersInString: " ,")
    private var autoCompleteEntries:[MultiAutoCompleteTokenComparable]? = []
    public var autoCompleteTokens:[MultiAutoCompleteTokenComparable] = []
    public var autoCompleteWordTokenizers:[String] = [] {
        didSet{
            wordTokenizeChars = NSCharacterSet(charactersInString: autoCompleteWordTokenizers.joinWithSeparator("")
)
        }
    }
    
    public var defaultText:String? {
        didSet{
            inputTextTokens = defaultText?.componentsSeparatedByCharactersInSet(wordTokenizeChars) ?? []
            self.text = defaultText
        }
    }
    
    /// User Defined Attributes
    //public var autoCompleteAttributes:[String:AnyObject]?
    /// Hides autocomplete tableview after selecting a suggestion
    public var hidesWhenSelected = true
    /// Hides autocomplete tableview when the textfield is empty
    public var hidesWhenEmpty:Bool?{
        didSet{
            assert(hidesWhenEmpty != nil, "hideWhenEmpty cannot be set to nil")
            autoCompleteTableView?.hidden = hidesWhenEmpty!
        }
    }
    /// The strings to be shown on as suggestions, setting the value of this automatically reload the tableview
    public var autoCompleteStrings:[String]?{
        didSet{
            autoCompleteStrings?.forEach{
                autoCompleteTokens.append(MultiAutoCompleteToken($0))
            }
        }
    }
    
    public func addInputToken(token: String){
        if let text = self.text where !text.isEmpty {
            self.text = text + "," + token + ","
        }else{
            self.text = token + ","
        }
        self.inputTextTokens.append(token)
    }
    
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupAutocompleteTable(superview!)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
        setupAutocompleteTable(superview!)
    }
    
    public override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        commonInit()
        if let superView = newSuperview {
            setupAutocompleteTable(superView)
        }
    }
    
    private func commonInit(){
        hidesWhenEmpty = true
        //autoCompleteAttributes = [NSForegroundColorAttributeName:UIColor.blackColor()]
        //autoCompleteAttributes![NSFontAttributeName] = UIFont.boldSystemFontOfSize(12)
        self.clearButtonMode = .Always
        self.addTarget(self, action: #selector(AutoCompleteTextField.textFieldDidChange), forControlEvents: .EditingChanged)
        self.addTarget(self, action: #selector(AutoCompleteTextField.textFieldDidEndEditing), forControlEvents: .EditingDidEnd)
        
    }
    
    private func setupAutocompleteTable(view:UIView){
        let screenSize = UIScreen.mainScreen().bounds.size
        let tableView = UITableView(frame: CGRectMake(self.frame.origin.x, self.frame.origin.y + CGRectGetHeight(self.frame), screenSize.width - (self.frame.origin.x * 2), 30.0))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = autoCompleteCellHeight
        tableView.hidden = hidesWhenEmpty ?? true
        view.addSubview(tableView)
        autoCompleteTableView = tableView
    }
    
    private func redrawTable(){
        if let autoCompleteTableView = autoCompleteTableView {
            var newFrame = autoCompleteTableView.frame
            newFrame.size.height = autoCompleteTableView.contentSize.height
            autoCompleteTableView.frame = newFrame
        }
    }
    
    //MARK: - Private Methods
    private func reload(){
        //print(autoCompleteTableView)
        //if enableAttributedText{
            //let attrs = [NSForegroundColorAttributeName:autoCompleteTextColor, NSFontAttributeName:UIFont.systemFontOfSize(12.0)]
            /*
            if attributedAutoCompleteStrings.count > 0 {
                attributedAutoCompleteStrings.removeAll(keepCapacity: false)
            }
            */
        autoCompleteEntries = []
        inputTextTokens = text!.componentsSeparatedByCharactersInSet(wordTokenizeChars)
        
        /*
        guard let lastToken = inputTextTokens.last where !lastToken.isEmpty else{
            return
        }*/
        
        //targetToken = lastToken
        
        //if let autoCompleteStrings = autoCompleteStrings, let lastToken = inputTextTokens.last where !lastToken.isEmpty {
        if let lastToken = inputTextTokens.last where !lastToken.isEmpty {

            targetToken = lastToken
            
            for i in 0..<autoCompleteTokens.count{
                let token = autoCompleteTokens[i]
                //let range = str.rangeOfString(targetToken, options: .CaseInsensitiveSearch)
                
                //let attString = NSMutableAttributedString(string: autoCompleteStrings[i], attributes: attrs)
                //attString.addAttributes(autoCompleteAttributes, range: range)
                //attributedAutoCompleteStrings.append(attString)
                if token.matchToken(targetToken) && !inputTextTokens.contains(token.topText) {
                    autoCompleteEntries!.append(token)
                }
            }
        }
        //}
        autoCompleteTableView?.reloadData()
        redrawTable()
        
    }
    
    func textFieldDidChange(){
        guard let _ = text else {
            return
        }
        
        reload()
        onTextChange(text!)
        //if text!.isEmpty{ autoCompleteStrings = nil }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.autoCompleteTableView?.hidden =  self.hidesWhenEmpty! ? self.text!.isEmpty : false
        })
    }
    
    func textFieldDidEndEditing() {
        autoCompleteTableView?.hidden = true
    }
}

//MARK: - UITableViewDataSource - UITableViewDelegate
extension AutoCompleteTextField: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = autoCompleteEntries != nil ? (autoCompleteEntries!.count > maximumAutoCompleteCount ? maximumAutoCompleteCount : autoCompleteEntries!.count) : 0
        print(count)
        return count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "autocompleteCellIdentifier"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil{
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }
        
        /*
        if enableAttributedText{
            cell?.textLabel?.attributedText = attributedAutoCompleteStrings[indexPath.row]
        }
        else{
            cell?.textLabel?.font = autoCompleteTextFont
            cell?.textLabel?.textColor = autoCompleteTextColor
            cell?.textLabel?.text = autoCompleteStrings![indexPath.row]
        }
        */
        cell?.textLabel?.font = autoCompleteTextFont
        cell?.textLabel?.textColor = autoCompleteTextColor
        cell?.textLabel?.text = autoCompleteEntries![indexPath.row].topText
        
        /*
        if indexPath.row == 0 {
            cell?.backgroundColor = UIColor.redColor()
        }else if indexPath.row == 1 {
            cell?.backgroundColor = UIColor.greenColor()

        }else {
            cell?.backgroundColor = UIColor.blueColor()
        }
        */
        
        cell?.contentView.gestureRecognizers = nil
        return cell!
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if let selectedText = cell?.textLabel?.text {

            print("selected!!! \(targetToken), \(inputTextTokens)")
            
            if targetToken.isEmpty {
                self.text = selectedText
            }else{
                
                let regex: NSRegularExpression
                do {
                    let pattern = "\(targetToken)$"
                    regex = try NSRegularExpression(pattern: pattern, options: [])
                    
                    self.text = regex.stringByReplacingMatchesInString(self.text!, options: [], range: NSMakeRange(0, self.text!.characters.count), withTemplate: selectedText + " ")

                } catch let error as NSError {
                    assertionFailure(error.localizedDescription)
                }
                
            }
            targetToken = ""
            inputTextTokens.popLast()
            inputTextTokens.append(selectedText)
            
            onSelect(selectedText, indexPath)
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            tableView.hidden = self.hidesWhenSelected
        })
    }
    
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.respondsToSelector(Selector("setSeparatorInset:")){
            cell.separatorInset = autoCompleteSeparatorInset
        }
        if cell.respondsToSelector(Selector("setPreservesSuperviewLayoutMargins:")){
            cell.preservesSuperviewLayoutMargins = false
        }
        if cell.respondsToSelector(Selector("setLayoutMargins:")){
            cell.layoutMargins = autoCompleteSeparatorInset
        }
        
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return autoCompleteCellHeight
    }
}

public protocol MultiAutoCompleteTokenComparable {
    var topText: String { get }
    func matchToken(searchString: String) -> Bool
}

public class MultiAutoCompleteToken: MultiAutoCompleteTokenComparable {
    
    public var topText: String
    var searchOptions: NSStringCompareOptions = .CaseInsensitiveSearch
    private var texts: [String] = []
    
    init(top: String, subTexts: String...){
        self.topText = top
        self.texts.append(top)
        texts += subTexts
    }
    
    init(_ top: String){
        self.topText = top
        self.texts.append(top)
    }
    
    public func matchToken(searchString: String) -> Bool {
        let result = self.texts.contains{
            let range = $0.rangeOfString(searchString, options: searchOptions, range: nil, locale: nil)
            return range != nil
        }
        
        return result
    }

}
