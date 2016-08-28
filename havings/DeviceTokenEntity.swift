//
//  DeviceTokenEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/08/27.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

class DeviceTokenEntity: Mappable {
    
    var token: String?
    var userId: Int?
    
    init(){}
    
    required init?(_ map: Map){}
    
    func mapping(map: Map) {
        token <- map["token"]
    }
    
}