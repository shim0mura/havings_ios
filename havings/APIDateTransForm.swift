//
//  APIDateTransForm.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/04.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

public class APIDateTransform: DateFormatterTransform {
    
    static let manager = APIDateTransform()
    private let formatter: NSDateFormatter
    static let formatYMD: String = "yyyy/MM/dd"
    
    private init() {
        self.formatter = NSDateFormatter()
        self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.formatter.calendar =  NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        
        super.init(dateFormatter: formatter)
    }
    
    /*
    public init() {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        
        super.init(dateFormatter: formatter)
    }*/
    
}