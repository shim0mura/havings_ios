//
//  TagMigrationEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/14.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class TagMigrationEntity: Object, EntityPostable {
    
    dynamic var migrationVersion = 0
    var updatedTags = List<TagEntity>()
    
    required convenience init?(_ map: Map) {
        self.init()
        mapping(map)
    }
        
}

extension TagMigrationEntity: Mappable {
    
    func mapping(map: Map) {
        migrationVersion <- map["migration_version"]
        updatedTags <- (map["updated_tags"], RealmArrayTransform<TagEntity>())
    }
}