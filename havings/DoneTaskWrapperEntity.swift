//
//  DoneTaskWrapperEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/19.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

class DoneTaskWrapperEntity: Mappable {
    
    var list: ItemEntity?
    var tasks: [TaskEntity]?
    
    init(){}
    
    required init?(_ map: Map){}
    
    func mapping(map: Map) {
        list <- map["list"]
        tasks <- map["tasks"]
    }
    
    static func setEventByDate(taskWrappers: [DoneTaskWrapperEntity]) -> [NSDate: [(timer: TimerEntity, itemName: String, actrualDate: NSDate)]]{
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        var result: [NSDate: [(timer: TimerEntity, itemName: String, actrualDate: NSDate)]] = [:]
        
        taskWrappers.forEach{ taskWrapper in
            taskWrapper.tasks?.forEach{ task in
                task.events?.forEach{ event in
                    let comps: NSDateComponents = calendar.components([.Year, .Month, .Day], fromDate: event)
                    let keyDate = NSDate(year: comps.year, month: comps.month, day: comps.day, region: TimerPresenter.gregorianByRegion)
                    
                    let value: (TimerEntity, String, NSDate) = (timer: task.timer!, itemName: taskWrapper.list!.name!, actualDate: event)
                    if result[keyDate] != nil {
                        result[keyDate]!.append(value)
                    }else{
                        result[keyDate] = [value]
                    }
                }
            }
        }
        
        return result
    }
}