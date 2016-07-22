//
//  UILocalizeExtension.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/25.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    
    @IBInspectable var localizedPlaceholder: String {
        get { return "" }
        set {
            self.placeholder = NSLocalizedString(newValue, comment: "")
        }
    }
    
    @IBInspectable var localizedText: String {
        get { return "" }
        set {
            self.text = NSLocalizedString(newValue, comment: "")
        }
    }
}

extension UITextView {
    
    @IBInspectable var localizedText: String {
        get { return "" }
        set {
            self.text = NSLocalizedString(newValue, comment: "")
        }
    }
}

extension UIBarItem {
    
    @IBInspectable var localizedTitle: String {
        get { return "" }
        set {
            self.title = NSLocalizedString(newValue, comment: "")
        }
    }
}

extension UILabel {
    
    @IBInspectable var localizedText: String {
        get { return "" }
        set {
            self.text = NSLocalizedString(newValue, comment: "")
        }
    }
}

extension UINavigationItem {
    
    @IBInspectable var localizedTitle: String {
        get { return "" }
        set {
            self.title = NSLocalizedString(newValue, comment: "")
        }
    }
}

extension UIButton {
    
    @IBInspectable var localizedTitle: String {
        get { return "" }
        set {
            self.setTitle(NSLocalizedString(newValue, comment: ""), forState: UIControlState.Normal)
        }
    }
}

extension UISearchBar {
    
    @IBInspectable var localizedPrompt: String {
        get { return "" }
        set {
            self.prompt = NSLocalizedString(newValue, comment: "")
        }
    }
    
    @IBInspectable var localizedPlaceholder: String {
        get { return "" }
        set {
            self.placeholder = NSLocalizedString(newValue, comment: "")
        }
    }
}

extension UISegmentedControl {
    
    @IBInspectable var localized: Bool {
        get { return true }
        set {
            for index in 0..<numberOfSegments {
                let title = NSLocalizedString(titleForSegmentAtIndex(index)!, comment: "")
                setTitle(title, forSegmentAtIndex: index)
            }
        }
    }
}