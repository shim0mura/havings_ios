//
//  EntityPostable.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/05/24.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation

protocol EntityPostable {
    func postable() -> [String : AnyObject]?
}

extension EntityPostable{
    
    func postable() -> [String : AnyObject]? {
        var result : [String : AnyObject] = [:]
        Mirror(reflecting: self).children.forEach(){
            result[$0.label!] = unwrap($0.value) as? AnyObject
        }
        return result
    }
    
    // Any型がunwrapできないので回りくどい方法でunwrapしてる
    // http://stackoverflow.com/questions/27989094/how-to-unwrap-an-optional-value-from-any-type
    func unwrap(any:Any) -> Any {
        
        let mi = Mirror(reflecting: any)
        if mi.displayStyle != .Optional {
            return any
        }
        
        if mi.children.count == 0 { return NSNull() }
        let (_, some) = mi.children.first!
        return some
        
    }
}