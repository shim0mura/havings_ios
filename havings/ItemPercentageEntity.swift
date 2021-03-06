//
//  ItemPercentageEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/20.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper
import UIKit

class ItemPercentageEntity: Mappable {
    
    var tag: String?
    var tagId: Int?
    var count: Int?
    var percentage: Double?
    var type: Int?
    var childs: [ItemPercentageEntity]?
    var typeCase: TypeCase?
    
    required init?(_ map: Map){
    }
    
    func mapping(map: Map) {
        tag <- map["tag"]
        tagId <- map["tag_id"]
        count <- map["count"]
        percentage <- map["percentage"]
        type <- map["type"]
        childs <- map["childs"]
        if let t = type {
            typeCase = TypeCase(rawValue: t)
        }
    }
    
    enum TypeCase: Int {
        case UnCategorized = 0
        case Clothing = 1
        case Food = 2
        case Living = 3
        case Etc = 4
        
        func getStr() -> String {
            switch self{
            case .UnCategorized:
                return "未分類"
            case .Clothing:
                return "衣"
            case .Food:
                return "食"
            case .Living:
                return "住"
            case .Etc:
                return "趣味"
            }
        }
        
        func getColor() -> UIColor {
            switch self {
            case .UnCategorized:
                return UIColor(red:0.75, green: 0.75, blue: 0.75, alpha: 1.0)
            case .Clothing:
                // #6EB7DB
                return UIColor(red:0.43, green: 0.72, blue: 0.86, alpha: 1.0)
            case .Food:
                // #FFF280
                return UIColor(red:0.98, green: 0.89, blue: 0.51, alpha: 1.0)
            case .Living:
                // #CFE283
                return UIColor(red:0.81, green: 0.89, blue: 0.51, alpha: 1.0)
            case .Etc:
                // #E38692
                return UIColor(red:0.89, green: 0.53, blue: 0.57, alpha: 1.0)
            }
        }
    }
}