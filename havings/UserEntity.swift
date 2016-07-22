//
//  UserEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/05/25.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

class UserEntity: Mappable {
    
    var id: Int?
    var name: String?
    var image: String?
    var count: Int?
    var description: String?
    var followingCount: Int?
    var followerCount: Int?
    var favoritesCount: Int?
    var imageFavoritesCount: Int?
    var dumpItemsCount: Int?
    var registeredItemCount: Int?
    var registeredItemImageCount: Int?
    var relation: Int?
    var isFollowingViewer: Bool?
    var backGroundImage: String?
    var homeList: ItemEntity?
    var nestedItemFromHome: ItemEntity?
    
    init(){}
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        image <- map["image"]
        count <- map["count"]
        description <- map["description"]
        followingCount <- map["following_count"]
        followerCount <- map["follower_count"]
        favoritesCount <- map["favorites_count"]
        imageFavoritesCount <- map["image_favorites_count"]
        dumpItemsCount <- map["dump_items_count"]
        registeredItemCount <- map["registered_item_count"]
        registeredItemImageCount <- map["registered_item_image_count"]
        relation <- map["relation"]
        isFollowingViewer <- map["is_following_viewer"]
        backGroundImage <- map["background_image"]
        homeList <- map["home_list"]
        nestedItemFromHome <- map["nested_item_from_home"]
    }
}