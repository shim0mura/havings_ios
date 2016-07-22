//
//  CommentEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/12.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

class CommentEntity: Mappable {
    
    var id: Int?
    var itemId: Int?
    var content: String?
    var canDelete: Bool?
    var commentedDate: NSDate?
    var commenter: UserEntity?
    var errors: AnyObject?
    
    init(){}
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        itemId <- map["item_id"]
        content <- map["content"]
        canDelete <- map["can_delete"]
        commentedDate <- (map["commented_date"], APIDateTransform.manager)
        commenter <- map["commenter"]
        errors <- map["errors"]
    }
    
    func getCommentedDateStr() -> String {
        let seconds: Int = Int(abs(self.commentedDate!.timeIntervalSinceNow))
        var result: String = ""
        
        if seconds < 60 * 60 {
            result = result + String(format: "%d", seconds / 60)
            result = result + NSLocalizedString("Unit.Minute", comment: "")
        }else if seconds < 60 * 60 * 24 {
            result = result + String(format: "%d", seconds / (60 * 60))
            result = result + NSLocalizedString("Unit.Hour", comment: "")
        }else {
            result = result + String(format: "%d", seconds / (60 * 60 * 24))
            result = result + NSLocalizedString("Unit.Day", comment: "")
        }
        
        result = result + NSLocalizedString("Prompt.Before", comment: "")
        
        return result
    }
}