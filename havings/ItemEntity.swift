//
//  ItemEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/05/31.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

class ItemEntity: Mappable, EntityPostable {

    var id: Int?
    var name: String?
    var description: String?
    var image: String?
    var thumbnail: String?
    var isList: Bool?
    var listId: Int?
    var isGarbage: Bool?
    var garbageReason: String?
    var count: Int?
    var privateType: Int?
    var owningItems: [ItemEntity]?
    var hasNextItem: Bool?
    var nextPageForItem: Int?
    var tags: [String]?
    var tagList: String?
    var itemImages: ItemImageListEntity?
    var countProperties: [CountDataEntity]?
    var favoriteCount: Int?
    var commentCount: Int?
    var isFavorited: Bool?
    var owner: UserEntity?
    var timers: [TimerEntity]?
    
    var errors: AnyObject?
    
    var imageDataForPost: [ItemImageEntity]?
    
    init(){}
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        description <- map["description"]
        image <- map["image"]
        thumbnail <- map["thumbnail"]
        isList <- map["is_list"]
        listId <- map["list_id"]
        isGarbage <- map["is_garbage"]
        garbageReason <- map["garbage_reason"]
        count <- map["count"]
        privateType <- map["private_type"]
        owningItems <- map["owning_items"]
        hasNextItem <- map["has_next_item"]
        nextPageForItem <- map["next_page_for_item"]
        tags <- map["tags"]
        itemImages <- map["item_images"]
        countProperties <- map["count_properties"]
        favoriteCount <- map["favorite_count"]
        commentCount <- map["comment_count"]
        isFavorited <- map["is_favorited"]
        owner <- map["owner"]
        imageDataForPost <- map["image_data_for_post"]
        tagList <- map["tag_list"]
        timers <- map["timers"]
        errors <- map["errors"]
    }
    
    func getNextOwningItem(page page: Int, callback: (ItemEntity) -> Void){
        API.call(Endpoint.Item.GetNextItem(id: self.id!, page: page)) { response in
            switch response {
            case .Success(let result):
                
                self.hasNextItem = result.hasNextItem
                self.nextPageForItem = result.nextPageForItem
                self.owningItems = [self.owningItems, result.owningItems].flatMap{$0}.flatMap{$0}
                
                callback(self)
            case .Failure(let error):
                print("failure \(error)")
            }
        }
    }
    
    func getNextFavoriteItem(userId userId: Int, page: Int, callback: (ItemEntity) -> Void){
        API.call(Endpoint.Item.GetFavoriteItem(userId: userId, page: page)) { response in
            switch response {
            case .Success(let result):
                
                self.hasNextItem = result.hasNextItem
                self.nextPageForItem = result.nextPageForItem
                self.owningItems = [self.owningItems, result.owningItems].flatMap{$0}.flatMap{$0}
                
                callback(self)
            case .Failure(let error):
                print("failure \(error)")
            }
        }
    }
}