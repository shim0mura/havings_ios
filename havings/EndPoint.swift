//
//  EndPoint.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/05/24.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class Endpoint {
    enum Test: RequestProtocol {
        typealias ResponseType = WeatherResponse
        
        case Get
        
        var method: Alamofire.Method {
            return .GET
        }
        
        var path: String {
            return "/tes"
        }
    }
    
    enum Session: RequestProtocol {
        typealias ResponseType = SessionEntity
        
        case Login(mail :String, password :String)
        case SignOut
     
        var method: Alamofire.Method {
            switch self {
            case .Login:
                return .POST
            case .SignOut:
                return .DELETE
            }
        }
        
        var path :String {
            switch self {
            case .Login:
                return "/users/sign_in"
            case .SignOut:
                return "/users/sign_out"
            }
        }
        
        var parameters: [String : AnyObject]? {
            let user = SessionEntity()
            
            switch self {
            case .Login(let mail, let password):
                user.password = password
                user.email = mail
            case .SignOut:
                break
            }
            
            if let u = user.postable() {
                return ["user" : u]
            }else{
                return nil
            }
        }
        
        func fromJson(json: AnyObject) -> Result<ResponseType, NSError> {
            switch self {
            case .Login:
                guard let value = Mapper<ResponseType>().map(json) else {
                    let errorInfo = [ NSLocalizedDescriptionKey: "Mapping object failed" , NSLocalizedRecoverySuggestionErrorKey: "Rainy days never stay." ]
                    let error = NSError(domain: "com.example.app", code: 0, userInfo: errorInfo)
                    return .Failure(error)
                }
                return .Success(value)
            case .SignOut:
                print("signout!!!")
                return .Success(SessionEntity())
            }
            
        }
        
    }
    
    enum User: RequestProtocol {
        typealias ResponseType = UserEntity
        
        case Get
        
        var method: Alamofire.Method {
            return .GET
        }
        
        var path: String {
            return "/user/self"
        }
    }
    
    enum Item: RequestProtocol {
        typealias ResponseType = ItemEntity
        
        case Get(id: Int)
        case GetNextItem(id: Int, page: Int)
        
        var method: Alamofire.Method {
            switch self {
            case .Get, .GetNextItem:
                return .GET
            }
        }
        
        var path: String {
            switch self {
            case .Get(let id):
                return "/items/\(id)"
            case .GetNextItem(let id, let page):
                return "/items/\(id)/next_items?page=\(page)"
            }
        }
    }
    
    enum ItemImageList: RequestProtocol {
        typealias ResponseType = ItemImageListEntity
    
        case GetNextImageList(id: Int, page: Int)
        
        var method: Alamofire.Method {
            switch self {
            case .GetNextImageList:
                return .GET
            }
        }
        
        var path: String {
            switch self {
            case .GetNextImageList(let id, let page):
                return "/items/\(id)/next_images?page=\(page)"
            }
        }
    }
    
    enum TagMigration: RequestProtocol {
        typealias ResponseType = TagMigrationEntity
        
        case GetLatestVersion
        case GetTagMigrationFrom(fromId: Int)
        
        var method: Alamofire.Method {
            switch self {
            case .GetLatestVersion, .GetTagMigrationFrom:
                return .GET
            }
        }
        
        var path: String {
            switch self {
            case .GetLatestVersion:
                return "/tags/current_migration_version/"
            case .GetTagMigrationFrom(let fromId):
                return "/tags/tag_migration/\(fromId)"
            }
        }
    }
    
}