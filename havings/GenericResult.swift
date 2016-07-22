//
//  GenericResult.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/10.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

class GenericResult: Mappable {
    
    var errors: AnyObject?
    
    init(){}
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        errors <- map["errors"]
    }
}