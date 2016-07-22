//
//  AddViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/11.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class AddViewController: UIViewController {

    @IBOutlet weak var autoCompTextField: AutoCompleteTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //autoCompTextField.becomeFirstResponder()
        autoCompTextField.autoCompleteStrings = ["あいうえお", "あいおうえ", "ああああああああああああああ",
        "test", "testet", "aaaa", "愛お植え", "", "dd", "php", "runn", "ruby", "perl", "python"]
        //autoCompTextField.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)!
        
        autoCompTextField.onTextChange = {
            print("onchange!! \($0)")
        }
        
        let ran = "abcdbc".rangeOfString("bcd")
        print(ran)
        print(ran?.count)
        
        let ra = "abcds".rangeOfString("ll")
        print(ra)
        print(ra?.count)
        
        
        DefaultTagPresenter.migrateTag()

    }

    @IBAction func transitionToForm(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Form", bundle: nil)
        let next: UIViewController = storyboard.instantiateViewControllerWithIdentifier("add_list")
        presentViewController(next, animated: true, completion: nil)
        //self.navigationController?.pushViewController(next, animated: true)

    }
    
    @IBAction func transitionToImageSelect(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Form", bundle: nil)
        let next: UIViewController = storyboard.instantiateViewControllerWithIdentifier("select_list_image")
        presentViewController(next, animated: true, completion: nil)
    }
    
    @IBAction func transitionToAddItem(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Form", bundle: nil)
        //let next: AddFormViewController? = storyboard.instantiateViewControllerWithIdentifier("add_form") as? AddFormViewController
        let nav: UINavigationController? = storyboard.instantiateViewControllerWithIdentifier("test_add_form") as? UINavigationController
        
        guard let navigationVC = nav, let addFormVC: AddFormViewController = navigationVC.viewControllers.first as? AddFormViewController else {
            print("nai")
            return
        }
        print(addFormVC)
        
        presentViewController(navigationVC, animated: true, completion: nil)
    }
    
    @IBAction func transitionToEdit(sender: AnyObject) {
        /*
        let storyboard: UIStoryboard = UIStoryboard(name: "Form", bundle: nil)
        let next: TargetItemSelectViewController = storyboard.instantiateViewControllerWithIdentifier("select_item_or_list") as! TargetItemSelectViewController
        next.selectType = TargetItemSelectType.EditItem
        
        presentViewController(next, animated: true, completion: nil)
        */
        let storyboard: UIStoryboard = UIStoryboard(name: "Form", bundle: nil)
        let nav: UINavigationController? = storyboard.instantiateViewControllerWithIdentifier("select_item_or_list") as? UINavigationController
        
        guard let navigationVC = nav, let targetSelectVC: TargetItemSelectViewController = navigationVC.viewControllers.first as? TargetItemSelectViewController else {
            print("nai")
            return
        }
        
        targetSelectVC.selectType = TargetItemSelectType.EditItem
        
        presentViewController(navigationVC, animated: true, completion: nil)
    }
    
    
    @IBAction func transitionToAddImage(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Form", bundle: nil)
        let nav: UINavigationController? = storyboard.instantiateViewControllerWithIdentifier("select_item_or_list") as? UINavigationController
        
        guard let navigationVC = nav, let targetSelectVC: TargetItemSelectViewController = navigationVC.viewControllers.first as? TargetItemSelectViewController else {
            print("nai")
            return
        }

        targetSelectVC.selectType = TargetItemSelectType.AddImage
        
        presentViewController(navigationVC, animated: true, completion: nil)
    }
    
    @IBAction func transitionToDumpItem(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Form", bundle: nil)
        let nav: UINavigationController? = storyboard.instantiateViewControllerWithIdentifier("select_item_or_list") as? UINavigationController
        
        guard let navigationVC = nav, let targetSelectVC: TargetItemSelectViewController = navigationVC.viewControllers.first as? TargetItemSelectViewController else {
            print("nai")
            return
        }
        
        targetSelectVC.selectType = TargetItemSelectType.DumpItem
        
        presentViewController(navigationVC, animated: true, completion: nil)
    }
    
    @IBAction func transitionToDelete(sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Form", bundle: nil)
        let nav: UINavigationController? = storyboard.instantiateViewControllerWithIdentifier("select_item_or_list") as? UINavigationController
        
        guard let navigationVC = nav, let targetSelectVC: TargetItemSelectViewController = navigationVC.viewControllers.first as? TargetItemSelectViewController else {
            print("nai")
            return
        }
        
        targetSelectVC.selectType = TargetItemSelectType.DeleteItem
        
        presentViewController(navigationVC, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
