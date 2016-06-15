//
//  UserEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/05/25.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

class UserEntity: Mappable, EntityPostable {
    
    var name: String?
    var id: Int?
    var image: String?
    
    init(){}
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        id <- map["id"]
        image <- map["image"]

    }
}