//
//  SearchResultEntity.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/21.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import ObjectMapper

class SearchResultEntity: Mappable {
    
    var items: [ItemEntity]?
    var totalCount: Int?
    var currentPage: Int?
    var hasNextPage: Bool?
    
    init(){}
    
    required init?(_ map: Map){}
    
    func mapping(map: Map) {
        items <- map["items"]
        totalCount <- map["total_count"]
        currentPage <- map["current_page"]
        hasNextPage <- map["has_next_page"]
    }
    
    func getNextPage(tag: String, page: Int, callback: () -> Void){
        API.call(Endpoint.SearchResult.GetItem(str: tag, page: page)) { response in
            switch response {
            case .Success(let result):
                self.hasNextPage = result.hasNextPage
                self.currentPage = (result.currentPage ?? 0) + 1
                self.totalCount = result.totalCount
                self.items = [self.items, result.items].flatMap{$0}.flatMap{$0}
                callback()
            case .Failure(let error):
                print("failure \(error)")
            }
        }
    }
    
}