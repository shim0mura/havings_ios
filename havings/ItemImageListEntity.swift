//
//  ItemImageListEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/04.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

class ItemImageListEntity: Mappable, EntityPostable {
    
    var images: [ItemImageEntity]?
    var hasNextImage: Bool?
    var nextPageForImage: Int?
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        images <- map["images"]
        hasNextImage <- map["has_next_image"]
        nextPageForImage <- map["next_page_for_image"]
    }
    
    func getNextItemImages(itemId itemId: Int, page: Int, callback: (ItemImageListEntity) -> Void){
        API.call(Endpoint.ItemImageList.GetNextImageList(id: itemId, page: page)) { response in
            switch response {
            case .Success(let result):
                self.hasNextImage = result.hasNextImage
                self.nextPageForImage = result.nextPageForImage
                self.images = [self.images, result.images].flatMap{$0}.flatMap{$0}
                
                callback(self)
            case .Failure(let error):
                print("failure \(error)")
            }
        }
    }
}