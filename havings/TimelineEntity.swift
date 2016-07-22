//
//  TimelineEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/20.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

class TimelineEntity: Mappable {
    
    var hasNextEvent: Bool?
    var timeline: [NotificationEntity]?
    var nextId: Int = 0
    var lastGetAt: NSDate = NSDate()
    
    init(){}
    
    required init?(_ map: Map){}
    
    func mapping(map: Map) {
        hasNextEvent <- map["has_next_event"]
        timeline <- map["timeline"]
    }
    
    func getNextTimeline(from: Int, callback: (TimelineEntity) -> Void){
        API.call(Endpoint.Timeline.Get(fromId: from)) { response in
            switch response {
            case .Success(let result):
                self.hasNextEvent = result.hasNextEvent
                self.nextId = result.timeline?.last?.eventId ?? 0
                self.lastGetAt = NSDate()
                self.timeline = [self.timeline, result.timeline].flatMap{$0}.flatMap{$0}
                callback(result)
            case .Failure(let error):
                print("failure \(error)")
            }
        }
    }
}