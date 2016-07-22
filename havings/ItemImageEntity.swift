//
//  ItemImageEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/04.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper
import UIKit

class ItemImageEntity: Mappable, EntityPostable {
    
    var id: Int?
    var itemId: Int?
    var itemName: String?
    var url: String?
    // 諸々の考え違いのせいでimageとurlは同じものをいれることになった
    // userEntityやitemEntityはimageに基本は画像urlをいれてるのでそっちに合わせたい
    // APIもAndroid側も変える
    var image: String?
    var imageData: String?
    var memo: String?
    var imageFavoriteCount: Int?
    var isFavorited: Bool?
    var userId: Int?
    var ownerName: String?
    var date: NSDate?
    var addedDate: NSDate?
    var imageByUIImage: UIImage?
    
    init(){}
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        itemId <- map["item_id"]
        itemName <- map["item_name"]
        url <- map["url"]
        image <- map["image"]
        memo <- map["memo"]
        imageFavoriteCount <- map["image_favorite_count"]
        isFavorited <- map["is_favorited"]
        userId <- map["user_id"]
        ownerName <- map["owner_name"]
        date <- (map["date"], APIDateTransform.manager)
        imageData <- map["image_data"]
        addedDate <- (map["added_date"], APIDateTransform.manager)
    }
    
    func setBase64Data() -> Bool {
        
        guard let image = self.imageByUIImage else {
            return false
        }
        
        //let data:NSData? = UIImagePNGRepresentation(image)
        let data:NSData? = UIImageJPEGRepresentation(image, 0.95)
        
        if let jpgData = data {
            
            //BASE64のStringに変換する
            let encodeString:String = "data:image/jpg;base64," + jpgData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            
            self.imageData = encodeString
            return true
            
        }else {
            
            return false
        
        }
        
    }
    
}