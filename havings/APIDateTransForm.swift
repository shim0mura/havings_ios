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
    
    public init() {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        super.init(dateFormatter: formatter)
    }
    
}