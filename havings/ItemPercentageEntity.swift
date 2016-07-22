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
    var count: Int?
    var percentage: Double?
    var type: Int?
    var childs: [ItemPercentageEntity]?
    var typeCase: TypeCase?
    
    required init?(_ map: Map){
    }
    
    func mapping(map: Map) {
        tag <- map["tag"]
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
                return "その他"
            }
        }
        
        func getColor() -> UIColor {
            switch self {
            case .UnCategorized:
                return UIColor(red:0.75, green: 0.75, blue: 0.75, alpha: 1.0)
            case .Clothing:
                return UIColor(red:0.3, green: 0.76, blue: 0.97, alpha: 1.0)
            case .Food:
                return UIColor(red:1.0, green: 0.71, blue: 0.3, alpha: 1.0)
            case .Living:
                return UIColor(red:0.6, green: 0.92, blue: 0.39, alpha: 1.0)
            case .Etc:
                return UIColor(red:0.75, green: 0.75, blue: 0.75, alpha: 1.0)
            }
        }
    }
}