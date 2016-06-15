//
//  CountDataEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/08.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

class CountDataEntity: Mappable, EntityPostable {
    
    var count: Int?
    var date: NSDate?
    var events: [EventEntity]?
    
    init(){}
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        count <- map["count"]
        events <- map["events"]
        date <- (map["date"], CustomDateFormatTransform(formatString: "yyyy-MM-dd"))
    }
}