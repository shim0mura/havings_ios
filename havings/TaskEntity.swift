//
//  TaskEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/19.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

class TaskEntity: Mappable {
    
    var timer: TimerEntity?
    var events: [NSDate]?
    
    required init?(_ map: Map){
    }
    
    func mapping(map: Map) {
        timer <- map["timer"]
        events <- (map["events"], APIDateTransform.manager)
    }
}
