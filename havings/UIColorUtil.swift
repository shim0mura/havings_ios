//
//  UIColorUtil.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/16.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class UIColorUtil {
    
    static let mainTextColor: UIColor = UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.0)
    static let selectedStateInListTags: UIColor = UIColor(red: 0.27, green: 0.80, blue: 0.67, alpha: 1.0)
    
    static let mainColor: UIColor = UIColor(red: 0.64, green: 0.51, blue: 0.45, alpha: 1.0)
    static let accentColor: UIColor = UIColor(red: 0.96, green: 0.79, blue: 0.02, alpha: 1.0)
    static let darkMainColor: UIColor = UIColor(red: 0.53, green: 0.31, blue: 0.22, alpha: 1.0)
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}