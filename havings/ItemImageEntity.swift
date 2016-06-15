//
//  ItemImageEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/04.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

class ItemImageEntity: Mappable, EntityPostable {
    
    var id: Int?
    var itemId: Int?
    var itemName: String?
    var url: String?
    var imageData: String?
    var memo: String?
    var imageFavoriteCount: Int?
    var isFavorited: Bool?
    var ownerName: String?
    var date: NSDate?
    var addedDate: NSDate?
    
    init(){}
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        itemId <- map["item_id"]
        itemName <- map["item_name"]
        url <- map["url"]
        memo <- map["memo"]
        imageFavoriteCount <- map["image_favorite_count"]
        isFavorited <- map["is_favorited"]
        ownerName <- map["owner_name"]
        date <- (map["date"], APIDateTransform())
        addedDate <- (map["added_date"], APIDateTransform())
    }
    
}