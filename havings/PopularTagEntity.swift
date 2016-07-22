//
//  PopularTagEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/21.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

class PopularTagEntity: Mappable {
    
    var tagId: Int?
    var tagName: String?
    var tagCount: Int?
    var items: [ItemEntity]?
    
    init(){}
    
    required init?(_ map: Map){}
    
    func mapping(map: Map) {
        tagId <- map["tag_id"]
        tagName <- map["tag_name"]
        tagCount <- map["tag_count"]
        items <- map["items"]
    }

}