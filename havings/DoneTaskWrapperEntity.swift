//
//  DoneTaskWrapperEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/19.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

class DoneTaskWrapperEntity: Mappable {
    
    var list: ItemEntity?
    var tasks: [TaskEntity]?
    
    init(){}
    
    required init?(_ map: Map){}
    
    func mapping(map: Map) {
        list <- map["list"]
        tasks <- map["tasks"]
    }
    
}