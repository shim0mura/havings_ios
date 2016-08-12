//
//  SessionEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/05/24.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

class SessionEntity: Mappable, EntityPostable {
    
    var name: String?
    var email: String?
    var password: String?
    var token: String?
    var uid: String?
    var id: Int?
    
    init(){}
        
    required init?(_ map: Map){
        
    }
        
    func mapping(map: Map) {
        name <- map["name"]
        email <- map["email"]
        password <- map["password"]
        token <- map["token"]
        uid <- map["uid"]
        id <- map["id"]
    }
}