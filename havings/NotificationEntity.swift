//
//  NotificationEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/17.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

class NotificationEntity: Mappable {
    
    enum EventType: String {
        case CreateList = "create_list"
        case CreateItem = "create_item"
        case AddImage = "add_image"
        case Dump = "dump"
        case Favorite = "favorite"
        case ImageFavorite = "image_favorite"
        case Follow = "follow"
        case Comment = "comment"
        case Timer = "timer"
    }
    
    var eventId: Int?
    var rawType: String?
    var unread: Bool?
    var date: NSDate?
    var acter: [AnyObject]?
    var target: [AnyObject]?
    
    var acterItems: [ItemEntity]?
    var acterUsers: [UserEntity]?
    var acterTimers: [TimerEntity]?
    var targetItems: [ItemEntity]?
    var targetUsers: [UserEntity]?
    var targetItemImages: [ItemImageEntity]?
    
    var type: EventType? = .CreateItem
    
    init(){}
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        eventId <- map["event_id"]
        rawType <- map["type"]
        type = EventType(rawValue: (rawType ?? "nothing"))
        acter <- map["acter"]
        target <- map["target"]
        
        if let type = type {
            switch type {
            case .Timer:
                acterTimers <- map["acter"]
                targetItems <- map["target"]
            case .Comment:
                acterUsers <- map["acter"]
                targetItems <- map["target"]
            case .Favorite:
                acterUsers <- map["acter"]
                targetItems <- map["target"]
            case .ImageFavorite:
                acterUsers <- map["acter"]
                targetItemImages <- map["target"]
            case .Follow:
                acterUsers <- map["acter"]
                targetUsers <- map["target"]
            case .CreateItem:
                acterUsers <- map["acter"]
                targetItems <- map["target"]
            case .CreateList:
                acterUsers <- map["acter"]
                targetItems <- map["target"]
            case .AddImage:
                acterUsers <- map["acter"]
                targetItemImages <- map["target"]
            case .Dump:
                acterUsers <- map["acter"]
                targetItems <- map["target"]
            }
        }
        
        unread <- map["unread"]
        date <- (map["date"], APIDateTransform.manager)

    }
    
}