//
//  EventEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/08.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

class EventEntity: Mappable, EntityPostable {
    
    var id: Int?
    var eventType: String?
    var date: NSDate?
    var item: ItemEntity?
    
    init(){}
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        eventType <- map["event_type"]
        date <- (map["date"], APIDateTransform.manager)
        item <- map["item"]
    }
}