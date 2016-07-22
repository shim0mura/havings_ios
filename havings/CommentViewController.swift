//
//  CommentViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/12.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView

class CommentViewController: UIViewController, PostAlertUtil {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var commentInputView: RSKPlaceholderTextView!
    
    @IBOutlet weak var sendContainer: UIView!
    
    @IBOutlet weak var commentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint!
    
    var itemId: Int = 0
    
    private let defaultCommentContainerHeight: CGFloat = 50
    
    private let userThumbnailTag: Int = 10
    private let userNameLabelTag: Int = 11
    private let commentLabelTag: Int = 12
    private let commentDateLabelTag: Int = 13
    
    private var beforeLoad: Bool = true
    private var isSending: Bool = true
    private var userId: Int = 0
    
    var commentList: [CommentEntity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60
        
        self.sendContainer.userInteractionEnabled = true
        
        let tokenManager = TokenManager.sharedManager
        if let ui = tokenManager.getUserId() {
            self.userId = ui
        }
        
        API.callArray(Endpoint.Comment.Get(itemId: self.itemId)){response in
            self.beforeLoad = false
            switch response {
            case .Success(let result):
                self.commentList = result
                self.tableView.reloadData()
                
            case .Failure(let error):
                print(error)
                
            }
        }
        
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.tableFooterView = UIView()
        
        self.commentInputView.placeholder = NSLocalizedString("Prompt.Comment.PlaceHolder", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touch")
        self.commentInputView.resignFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(CommentViewController.keyboardWillBeShown(_:)),
                                                         name: UIKeyboardWillShowNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(CommentViewController.keyboardWillBeHidden(_:)),
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
            if let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue {
                self.tableBottomConstraint.constant = keyboardFrame.height + 80
                self.commentHeightConstraint.constant = 100
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        self.tableBottomConstraint.constant = self.defaultCommentContainerHeight
        self.commentHeightConstraint.constant = self.defaultCommentContainerHeight
    }
    
    @IBAction func sendComment(sender: AnyObject) {
        guard let comment = self.commentInputView.text where !comment.isEmpty else{
            self.simpleAlertDialog(NSLocalizedString("Prompt.Comment.isEmpty", comment: ""), message: nil)
            return
        }

        let spinner = self.showConnectingSpinner()
        self.isSending = true
        API.call(Endpoint.Comment.Post(itemId: self.itemId, comment: comment)){response in
            self.isSending = false
            spinner.dismissViewControllerAnimated(true, completion: nil)
            switch response {
            case .Success(let result):
                if let errors = result.errors as? Dictionary<String, AnyObject> {
                    self.showFailedAlert(errors)
                    return
                }else{
                    self.commentInputView.text = nil
                    self.commentList.append(result)
                    self.tableView.reloadData()
                }                
            case .Failure(let error):
                print("failure \(error)")
                self.simpleAlertDialog(NSLocalizedString("Prompt.FailureToAceess", comment: ""), message: nil)
                return
            }
        }
    }
}

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.beforeLoad {
            return 1
        }else{
            return self.commentList.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /*
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
        cell.textLabel?.text = "row \(indexPath.row)"
        return cell
        */
        
        let cell: UITableViewCell
        
        if self.beforeLoad {
            cell = self.tableView.dequeueReusableCellWithIdentifier("loading")! as UITableViewCell
        }else{
            cell = self.tableView.dequeueReusableCellWithIdentifier("comment")! as UITableViewCell

            let userThumbnail: UIImageView = cell.viewWithTag(self.userThumbnailTag) as! UIImageView
            let userName: UILabel = cell.viewWithTag(self.userNameLabelTag) as! UILabel
            let commentLabel: UILabel = cell.viewWithTag(self.commentLabelTag) as! UILabel
            let commentDate: UILabel = cell.viewWithTag(self.commentDateLabelTag) as! UILabel
            
            let comment = self.commentList[indexPath.row]
            
            if let thumbnailPath = comment.commenter!.image {
                let urlString = ApiManager.getBaseUrl() + thumbnailPath
                userThumbnail.kf_setImageWithURL(NSURL(string: urlString)!, completionHandler: { (image, error, cacheType, imageURL) -> () in
                    userThumbnail.layer.cornerRadius = userThumbnail.frame.size.width/2
                    userThumbnail.clipsToBounds = true
                })
            }else{
                userThumbnail.image = UIImage(named: "user_thumb")
                userThumbnail.layer.cornerRadius = userThumbnail.frame.size.width/2
                userThumbnail.clipsToBounds = true
            }
            
            userName.text = comment.commenter?.name
            commentLabel.text = comment.content
            commentDate.text = comment.getCommentedDateStr()
        }

        cell.selectionStyle = .None
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("select!!")
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        self.commentInputView.resignFirstResponder()
    }
    
    /*
     func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
     return 0
     }
     */
    
    /*
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let comment = self.commentList[indexPath.row]
        
        print(comment.commenter!.id, self.userId)
        if comment.commenter!.id == self.userId {
            print("aaa")
            return nil
        }
        
        let delete = UITableViewRowAction(style: .Destructive, title: "Delete") {
            (action, indexPath) in
            
            
            print("delete!! \(indexPath.row)")
            self.simpleAlertDialog("aaa", message: nil)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        
        return [delete]
    }
    */
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let comment = self.commentList[indexPath.row]
        
        let spinner = self.showConnectingSpinner()
        self.isSending = true
        API.call(Endpoint.Comment.Delete(itemId: self.itemId, commentId: comment.id!)){response in
            self.isSending = false
            spinner.dismissViewControllerAnimated(true, completion: nil)
            switch response {
            case .Success(let result):
                if let errors = result.errors as? Dictionary<String, AnyObject> {
                    self.showFailedAlert(errors)
                    return
                }else{
                    let index = self.commentList.indexOf({$0.id! == comment.id!})!
                    print(index)
                    self.commentList.removeAtIndex(index)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
            case .Failure(let error):
                print("failure \(error)")
                self.simpleAlertDialog(NSLocalizedString("Prompt.FailureToAceess", comment: ""), message: nil)
                return
            }
        }
        
    }
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        let comment = self.commentList[indexPath.row]
        
        if comment.commenter!.id == self.userId {
            return .Delete
        }else{
            return .None
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
