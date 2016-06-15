//
//  TagEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/14.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class TagEntity: Object, EntityPostable {
    
    dynamic var id = 0
    dynamic var name: String?
    dynamic var yomiJp: String?
    dynamic var yomiRoma: String?
    
    dynamic var parentId = 0
    dynamic var priority = 500
    dynamic var nest = 0
    dynamic var tagType = 0
    dynamic var isDeleted = false
    
    required convenience init?(_ map: Map) {
        self.init()
        mapping(map)
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }

}

extension TagEntity: Mappable {
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        yomiJp <- map["yomi_jp"]
        yomiRoma <- map["yomi_roma"]
        parentId <- map["parent_id"]
        priority <- map["priority"]
        nest <- map["nest"]
        tagType <- map["tag_type"]
        isDeleted <- map["is_deleted"]
    }
}