//
//  PickupEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/21.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

class PickupEntity: Mappable {
    
    var popularTag: [PopularTagEntity]?
    var popularList: [ItemEntity]?
    
    init(){}
    
    required init?(_ map: Map){}
    
    func mapping(map: Map) {
        popularTag <- map["popular_tag"]
        popularList <- map["popular_list"]
    }
    
}