//
//  TouchableUIView.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/15.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import UIKit

class TouchableUIView: UIView {
    
    weak var delegate: TouchableUIViewDelegate! = nil
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.first != nil {
            touchStart(self)
        }
    }
    
    /*
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            // do something with your currentPoint
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            // do something with your currentPoint
        }
    }
    */
    
    func touchStart(view: TouchableUIView){
        delegate?.viewDidTapped(view)
    }

}

protocol TouchableUIViewDelegate: class {
    func viewDidTapped(view: TouchableUIView)
}