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
            let label = camelIntoSnake($0.label!)
            print(label)
            let value = unwrap($0.value) as? AnyObject
            if value is NSArray {

                let array = (value as! NSArray) as Array
                var values: [AnyObject] = []
                array.forEach{
                    if let v = $0 as? EntityPostable {
                        print("entity postable")
                        values.append(v.postable()!)
                    }
                }
            
                if values.isEmpty {
                    print("empty array")
                    result[label] = array

                }else{
                    print("not empty array")
                    result[label] = values

                }

            }else{
                print("success")
                result[label] = value
            
            }
            
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
    
    func camelIntoSnake (camel:String) -> String {
        // ensure the first letter is capital
        let head = camel.substringToIndex(camel.startIndex.advancedBy(1))
        var upperCased = camel
        upperCased.replaceRange(camel.startIndex...camel.startIndex, with: head.uppercaseString)
        
        let input = upperCased as NSString
        
        // split input string into words
        let pattern = "[A-Z][a-z,\\d]+"
        
        //let regex = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions(), error: nil)
        
        var words:[String] = []
        
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matchesInString(input as String, options: [], range: NSRange(location: 0, length: input.length))
            for match in matches {
                for i in 0..<match.numberOfRanges{
                    // make every word in lower case
                    words.append(input.substringWithRange(match.rangeAtIndex(i)).lowercaseString)
                }
            }
            
        } catch let error as NSError {
            assertionFailure(error.localizedDescription)
        }
        return words.joinWithSeparator("_")
        
    }
}