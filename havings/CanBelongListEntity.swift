//
//  CanBelongListArrayEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/22.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

class CanBelongListEntity: Mappable {
    
    var id: Int?
    var name: String?
    var count: Int?
    var privateType: Int?
    var nest: Int?
    
    required init?(_ map: Map){
        
    }
    
    func getNameByNest() -> String {
        let c:Int = self.nest ?? 0
        var space = String(count: c, repeatedValue: ("　" as Character))
        if c > 0 {
            space = space + "-"
        }
        let n:String = self.name ?? ""
        return space + n
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        count <- map["count"]
        privateType <- map["private_type"]
        nest <- map["nest"]
    }
    
}