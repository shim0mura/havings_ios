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
        
        autoCompTextField.becomeFirstResponder()
        autoCompTextField.autoCompleteStrings = ["あいうえお", "あいおうえ", "ああああああああああああああ",
        "test", "testet", "aaaa", "愛お植え", "", "dd", "php", "runn", "ruby", "perl", "python"]
        //autoCompTextField.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)!
        
        autoCompTextField.onTextChange = {
            print("onchange!! \($0)")
        }
        
        DefaultTagPresenter.migrateTag()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
