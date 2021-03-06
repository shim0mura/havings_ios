//
//  InputViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/08/01.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import EasyTipView
import GoogleMobileAds
import TTGSnackbar
import Social

class InputViewController: UIViewController, BannerUtil {

    enum ActionType: Int {
        case CreateList = 0
        case CreateItem = 1
        case AddImage = 2
        case EditItem = 3
        case DumpItem = 4
        case DeleteItem = 5
        
        static func getCount() -> Int {
            return 6
        }
        
        func getImage() -> UIImage {
            switch self {
            case .CreateList:
                //return UIImage(named: "ic_add_list_36dp")!
                return UIImage(named: "icon_type_list")!

            case .CreateItem:
                //return UIImage(named: "ic_add_item_36dp")!
                return UIImage(named: "icon_type_item")!

            case .AddImage:
                return UIImage(named: "ic_photo_36dp")!
            case .EditItem:
                return UIImage(named: "EditFilled-100")!
            case .DumpItem:
                return UIImage(named: "ic_dump_36dp")!
            case .DeleteItem:
                return UIImage(named: "ic_cancel_24dp")!
            }
        }
        
        func getDescription() -> String {
            switch self {
            case .CreateList:
                return NSLocalizedString("Prompt.Action.AddList", comment: "")
            case .CreateItem:
                return NSLocalizedString("Prompt.Action.AddItem", comment: "")
            case .AddImage:
                return NSLocalizedString("Prompt.Action.AddImage", comment: "")
            case .EditItem:
                return NSLocalizedString("Prompt.Action.Edit", comment: "")
            case .DumpItem:
                return NSLocalizedString("Prompt.Action.Dump", comment: "")
            case .DeleteItem:
                return NSLocalizedString("Prompt.Action.Delete", comment: "")
            }
        }
        
    }
    
    private let iconImageTag: Int = 10
    private let nameTag: Int = 11
    
    private var userId: Int = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bannerView: GADBannerView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let tokenManager = TokenManager.sharedManager
        if let ui = tokenManager.getUserId() {
            self.userId = ui
        }
        
        self.tableView.tableFooterView = UIView()
        DefaultTagPresenter.setDefaultTagConf()
        showAd(bannerView)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        let tooltip = TooltipManager.getToolTip()
        let target = self.tabBarController?.tabBar.items![2].valueForKey("view") as? UIView
        tooltip?.show(forView: target!)
    }

}

extension InputViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return ActionType.getCount()
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("inputItem")!
        let type = ActionType(rawValue: indexPath.row)
        let image: UIImageView = cell.viewWithTag(self.iconImageTag) as! UIImageView
        let name: UILabel = cell.viewWithTag(self.nameTag) as! UILabel
        image.image = type?.getImage()
        name.text = type?.getDescription()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        guard let type = ActionType(rawValue: indexPath.row) else {
            return
        }
        
        switch type {
        case .CreateList:
            let storyboard: UIStoryboard = UIStoryboard(name: "Form", bundle: nil)
            let next: UINavigationController = storyboard.instantiateViewControllerWithIdentifier("add_list") as! UINavigationController
            
            guard let targetFormVC: ListNameSelectViewController = next.viewControllers.first as? ListNameSelectViewController else {
                return
            }
            
            targetFormVC.finishDelegate = self
            
            presentViewController(next, animated: true, completion: nil)
            
        case .CreateItem:
            let storyboard: UIStoryboard = UIStoryboard(name: "Form", bundle: nil)
            let next: UINavigationController = storyboard.instantiateViewControllerWithIdentifier("edit_form_navigation") as! UINavigationController
            
            guard let targetFormVC: AddFormViewController = next.viewControllers.first as? AddFormViewController else {
                return
            }
            
            targetFormVC.finishDelegate = self
            
            presentViewController(next, animated: true, completion: nil)

        case .AddImage:
            let storyboard: UIStoryboard = UIStoryboard(name: "Form", bundle: nil)
            let nav: UINavigationController? = storyboard.instantiateViewControllerWithIdentifier("select_item_or_list") as? UINavigationController
            
            guard let navigationVC = nav, let targetSelectVC: TargetItemSelectViewController = navigationVC.viewControllers.first as? TargetItemSelectViewController else {
                return
            }
            
            targetSelectVC.userId = self.userId
            targetSelectVC.selectType = TargetItemSelectType.AddImage
            targetSelectVC.finishDelegate = self

            presentViewController(navigationVC, animated: true, completion: nil)
            
        case .EditItem:
            let storyboard: UIStoryboard = UIStoryboard(name: "Form", bundle: nil)
            let nav: UINavigationController? = storyboard.instantiateViewControllerWithIdentifier("select_item_or_list") as? UINavigationController
            
            guard let navigationVC = nav, let targetSelectVC: TargetItemSelectViewController = navigationVC.viewControllers.first as? TargetItemSelectViewController else {
                return
            }
            
            targetSelectVC.userId = self.userId
            targetSelectVC.selectType = TargetItemSelectType.EditItem
            targetSelectVC.finishDelegate = self

            presentViewController(navigationVC, animated: true, completion: nil)
            
        case .DumpItem:
            let storyboard: UIStoryboard = UIStoryboard(name: "Form", bundle: nil)
            let nav: UINavigationController? = storyboard.instantiateViewControllerWithIdentifier("select_item_or_list") as? UINavigationController
            
            guard let navigationVC = nav, let targetSelectVC: TargetItemSelectViewController = navigationVC.viewControllers.first as? TargetItemSelectViewController else {
                return
            }
            
            targetSelectVC.userId = self.userId
            targetSelectVC.selectType = TargetItemSelectType.DumpItem
            targetSelectVC.finishDelegate = self
            
            presentViewController(navigationVC, animated: true, completion: nil)
        case .DeleteItem:
            let storyboard: UIStoryboard = UIStoryboard(name: "Form", bundle: nil)
            let nav: UINavigationController? = storyboard.instantiateViewControllerWithIdentifier("select_item_or_list") as? UINavigationController
            
            guard let navigationVC = nav, let targetSelectVC: TargetItemSelectViewController = navigationVC.viewControllers.first as? TargetItemSelectViewController else {
                return
            }
            
            targetSelectVC.userId = self.userId
            targetSelectVC.selectType = TargetItemSelectType.DeleteItem
            targetSelectVC.finishDelegate = self
            presentViewController(navigationVC, animated: true, completion: nil)
        }
        
    }
    
}

extension InputViewController: FinishItemUpdateDelegate {
    func finish(prompt: String, itemPath: String, isPublic: Bool) {
        //self.view.makeToast(prompt)
        let tooltip = TooltipManager.getToolTip()
        let target = self.tabBarController?.tabBar.items![2].valueForKey("view") as? UIView
        tooltip?.show(forView: target!)
        
        let snackbar: TTGSnackbar
        if isPublic {
            snackbar = TTGSnackbar.init(message: prompt, duration: .Long, actionText: NSLocalizedString("Prompt.ItemForm.Action.Tweet", comment: ""))
            { (snackbar) -> Void in
                var composeView : SLComposeViewController!
                composeView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                composeView.setInitialText(prompt + " " + ApiManager.getBaseUrl() + " #Havings")
                self.presentViewController(composeView, animated: true, completion: nil)
                
            }
        
        }else{
            snackbar = TTGSnackbar.init(message: prompt, duration: .Long)
        }
        
        snackbar.bottomMargin = 100
        snackbar.show()
    }
}

protocol FinishItemUpdateDelegate: class {
    func finish(prompt: String, itemPath: String, isPublic: Bool)
}
