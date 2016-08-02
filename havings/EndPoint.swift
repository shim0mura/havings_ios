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
        
        case Get(userId: Int)
        case GetSelf
        case GetItemFavoritedUser(itemId: Int)
        case GetImageFavoritedUser(imageId: Int)
        case GetFollowingUser(userId: Int)
        case GetFollowedUser(userId: Int)
        
        case ChangeProfile(userEntity: UserEntity)
        
        var method: Alamofire.Method {
            switch self {
            case .Get, .GetSelf, .GetItemFavoritedUser, .GetImageFavoritedUser, .GetFollowingUser, .GetFollowedUser:
                return .GET
            case .ChangeProfile:
                return .PUT
            }
        }
        
        var path: String {
            switch self {
            case .Get(let userId):
                return "/user/\(userId)"
            case .GetSelf:
                return "/user/self"
            case .GetItemFavoritedUser(let itemId):
                return "/items/\(itemId)/favorited_users"
            case .GetImageFavoritedUser(let imageId):
                return "/items/image/\(imageId)/favorited_users"
            case .GetFollowingUser(let userId):
                return "/user/\(userId)/following"
            case .GetFollowedUser(let userId):
                return "/user/\(userId)/followers"
            case .ChangeProfile:
                return "/users"
            }
        }
        
        var parameters: [String : AnyObject]? {
            switch self {
            case .Get, .GetSelf, .GetItemFavoritedUser, .GetImageFavoritedUser, .GetFollowingUser, .GetFollowedUser:
                return nil
            case .ChangeProfile(let userEntity):
                return ["user" : userEntity.toJSON()]
            }
        }
    }
    
    enum Item: RequestProtocol {
        typealias ResponseType = ItemEntity
        
        case Get(id: Int)
        case GetNextItem(id: Int, page: Int)
        case Post(item: ItemEntity)
        case Put(itemId: Int, item: ItemEntity)
        case Dump(itemId: Int, item: ItemEntity, fellowIds: [Int])
        case Delete(itemId: Int, item: ItemEntity, fellowIds: [Int])
        case AddImage(itemId: Int, item: ItemEntity)
        
        case GetUserItemTree(userId: Int, includeDump: Int)
        
        case GetFavoriteItem(userId: Int, page: Int)
        case GetFavoriteImage(userId: Int, page: Int)
        
        case GetDumpItem(userId: Int, page: Int)

        var method: Alamofire.Method {
            switch self {
            case .Get, .GetNextItem, .GetUserItemTree, .GetFavoriteItem, .GetFavoriteImage, .GetDumpItem:
                return .GET
            case .Post, .AddImage:
                return .POST
            case .Put, .Dump:
                return .PUT
            case .Delete:
                return .DELETE
            }
        }
        
        var path: String {
            switch self {
            case .Get(let id):
                return "/items/\(id)"
            case .GetNextItem(let id, let page):
                return "/items/\(id)/next_items?page=\(page)"
            case .Post:
                return "/items/"
            case .Put(let itemInfo):
                let id: Int = itemInfo.itemId
                return "/items/\(id)"
            case .Dump(let itemInfo):
                let id: Int = itemInfo.itemId
                return "/items/\(id)/dump"
            case .Delete(let itemInfo):
                let id: Int = itemInfo.itemId
                return "/items/\(id)"
            case .AddImage(let itemId, _):
                return "/items/\(itemId)/image"
            case .GetUserItemTree(let userId, let includeDump):
                return "/user/\(userId)/item_tree?include_dump=\(includeDump)"
            case .GetFavoriteItem(let userId, let page):
                return "/user/\(userId)/favorite_items?page=\(page)"
            case .GetFavoriteImage(let userId, let page):
                return "/user/\(userId)/favorite_images?page=\(page)"
            case .GetDumpItem(let userId, let page):
                return "/user/\(userId)/dump_items?page=\(page)"
            }
        }
        
        var parameters: [String : AnyObject]? {
            switch self {
            case .Get, .GetNextItem, .GetUserItemTree, .GetFavoriteItem, .GetFavoriteImage, .GetDumpItem:
                return nil
            case .Post(let itemEntity):
                /*
                if let item = itemEntity.postable() {
                    return ["item" : item]
                }else{
                    return nil
                }
                */
                return ["item" : itemEntity.toJSON()]
            case .Put(let itemInfo):
                let item: ItemEntity = itemInfo.item
                return ["item" : item.toJSON()]
            case .Dump(let itemInfo):
                let item: ItemEntity = itemInfo.item
                var json = item.toJSON()
                json["fellow_ids"] = itemInfo.fellowIds
                return ["item" : json]
            case .Delete(let itemInfo):
                let item: ItemEntity = itemInfo.item
                var json = item.toJSON()
                json["fellow_ids"] = itemInfo.fellowIds
                return ["item" : json]
            case .AddImage(_, let item):
                return ["item" : item.toJSON()]
            }
            
        }
    }
    
    enum ItemImageList: RequestProtocol {
        typealias ResponseType = ItemImageListEntity
    
        case GetNextImageList(id: Int, page: Int)
        case GetNextImageListOfUser(userId: Int, page: Int)
        case GetNextFavoriteImage(userId: Int, page: Int)
        
        var method: Alamofire.Method {
            switch self {
            case .GetNextImageList, .GetNextImageListOfUser, .GetNextFavoriteImage:
                return .GET
            }
        }
        
        var path: String {
            switch self {
            case .GetNextImageList(let id, let page):
                return "/items/\(id)/next_images?page=\(page)"
            case .GetNextImageListOfUser(let userId, let page):
                return "/user/\(userId)/item_images?page=\(page)"
            case .GetNextFavoriteImage(let userId, let page):
                return "/user/\(userId)/favorite_images?page=\(page)"
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
    
    enum CanBelongList: RequestProtocol {
        typealias ResponseType = CanBelongListEntity
        
        case Get
        
        var method: Alamofire.Method {
            return .GET
        }
        
        var path: String {
            return "/user/list_tree"
        }

    }
    
    enum Timer: RequestProtocol {
        typealias ResponseType = TimerEntity
        
        case GetAll
        case Post(timer: TimerEntity)
        case Done(timerId: Int, doneDate: NSDate?)
        case DoLater(timerId: Int, nextDue: NSDate)
        case End(timerId: Int)
        case Edit(timerId: Int, timer: TimerEntity)
        case Delete(timerId: Int)
        
        var method: Alamofire.Method {
            switch self {
            case .GetAll:
                return .GET
            case .Post, .End, .Done, .DoLater:
                return .POST
            case .Edit:
                return .PUT
            case .Delete:
                return .DELETE
            }
        }
        
        var path: String {
            switch self {
            case .GetAll:
                return "/timers"
            case .Post:
                return "/timers/"
            case .Done(let timerId, _):
                return "/timers/\(timerId)/done"
            case .DoLater(let timerId, _):
                return "/timers/\(timerId)/do_later"
            case .End(let timerId):
                return "/timers/\(timerId)/end"
            case .Edit(let timerId, _):
                return "/timers/\(timerId)"
            case .Delete(let timerId):
                return "/timers/\(timerId)"
            }
        }
        
        var parameters: [String : AnyObject]? {
            switch self {
            case .Post(let timerEntity):
                var json = timerEntity.toJSON()
                json["next_due_at"] = timerEntity.nextDueAt!.timeIntervalSince1970
                json["latest_calc_at"] = timerEntity.latestCalcAt!.timeIntervalSince1970
                return ["timer" : json]
            case .Done(_, let doneDate):
                var param: [String : Int] = [:]
                if let date = doneDate {
                    param["done_at"] = Int(date.timeIntervalSince1970)
                }
                return ["timer": param]
            case .DoLater(_, let nextDue):
                var param: [String : Int] = [:]
                param["next_due_at"] = Int(nextDue.timeIntervalSince1970)
                return ["timer": param]
            case .Edit(_, let timerEntity):
                var json = timerEntity.toJSON()
                json["next_due_at"] = timerEntity.nextDueAt!.timeIntervalSince1970
                json["latest_calc_at"] = timerEntity.latestCalcAt!.timeIntervalSince1970
                return ["timer" : json]
            case .End, .Delete, .GetAll:
                return nil
            }
        }
    }
    
    enum Favorite: RequestProtocol {
    
        typealias ResponseType = GenericResult
        
        case FavoriteItem(itemId: Int)
        case UnFavoriteItem(itemId: Int)
        case FavoriteItemImage(itemImageId: Int)
        case UnFavoriteItemImage(itemImageId: Int)
        
        var method: Alamofire.Method {
            switch self {
            case .FavoriteItem, .FavoriteItemImage:
                return .POST
            case .UnFavoriteItem, .UnFavoriteItemImage:
                return .DELETE
            }
        }
        
        var path: String {
            switch self {
            case .FavoriteItem(let itemId):
                return "/items/\(itemId)/favorite"
            case .UnFavoriteItem(let itemId):
                return "/items/\(itemId)/favorite"
            case .FavoriteItemImage(let itemImageId):
                return "/items/image/\(itemImageId)/favorite"
            case .UnFavoriteItemImage(let itemImageId):
                return "/items/image/\(itemImageId)/favorite"
            }
        }
    }
    
    enum Follow: RequestProtocol {
        typealias ResponseType = GenericResult

        case Follow(userId: Int)
        case UnFollow(userId: Int)
        
        var method: Alamofire.Method {
            switch self {
            case .Follow:
                return .POST
            case .UnFollow:
                return .DELETE
            }
        }
        
        var path: String {
            switch self {
            case .Follow(let userId):
                return "/user/\(userId)/follow"
            case .UnFollow(let userId):
                return "/user/\(userId)/follow"
            }
        }
    }
    
    enum ItemImage: RequestProtocol {
        typealias ResponseType = ItemImageEntity
        
        case Get(itemId: Int, itemImageId: Int)
        case UpdateMetaData(itemId: Int, itemImageEntity: ItemImageEntity)
        case Delete(itemId: Int, itemImageId: Int)
        
        var method: Alamofire.Method {
            switch self {
            case .Get:
                return .GET
            case .UpdateMetaData:
                return .PUT
            case .Delete:
                return .DELETE
            }
        }
        
        var path: String {
            switch self {
            case .Get(let itemId, let itemImageId):
                return "/items/\(itemId)/image/\(itemImageId)"
            case .UpdateMetaData(let itemId, let itemImageEntity):
                return "/items/\(itemId)/image/\(itemImageEntity.id!)"
            case .Delete(let itemId, let itemImageId):
                return "/items/\(itemId)/image/\(itemImageId)"
            }
        }
        
        var parameters: [String : AnyObject]? {
            switch self {
            case .Get:
                return nil
            case .UpdateMetaData(let itemId, let itemImageEntity):
                let item: ItemEntity = ItemEntity()
                item.id = itemId
                item.imageDataForPost = [itemImageEntity]
                var json = item.toJSON()
                if var jsonImage = json["image_data_for_post"] as? [String : AnyObject] {
                    jsonImage["added_date"] = itemImageEntity.addedDate?.timeIntervalSince1970
                }
                return ["item": json]
            case .Delete:
                return nil
            }
        }
    }
    
    enum Comment: RequestProtocol {
        typealias ResponseType = CommentEntity
        
        case Get(itemId: Int)
        case Post(itemId: Int, comment: String)
        case Delete(itemId: Int, commentId: Int)

        var method: Alamofire.Method {
            switch self {
            case .Get:
                return .GET
            case .Post:
                return .POST
            case .Delete:
                return .DELETE
            }
        }
        
        var path: String {
            switch self {
            case .Get(let itemId):
                return "/items/\(itemId)/comment"
            case .Post(let itemId, _):
                return "/items/\(itemId)/comment"
            case .Delete(let itemId, let commentId):
                return "/items/\(itemId)/comment/\(commentId)"
            }
        }
        
        var parameters: [String : AnyObject]? {
            switch self {
            case .Get:
                return nil
            case .Post(_, let comment):
                return ["comment": ["content": comment]]
            case .Delete:
                return nil
            }
        }
    }
    
    enum Notification: RequestProtocol {
        typealias ResponseType = NotificationEntity
        
        case GetNotification
        case GetUnreadCount
        case ReadNotification
        
        var method: Alamofire.Method {
            switch self {
            case .GetNotification, .GetUnreadCount:
                return .GET
            case .ReadNotification:
                return .PUT
            }
        }
        
        var path: String {
            switch self {
            case .GetNotification:
                return "/notification"
            case .GetUnreadCount:
                return "/notification/unread_count"
            case .ReadNotification:
                return "/notification/read"
            }
        }
    }
    
    enum DoneTask: RequestProtocol {
        typealias ResponseType = DoneTaskWrapperEntity
        
        case GetAllDoneTasks
        case GetDoneTaskByItem(itemId: Int)
        
        var method: Alamofire.Method {
            switch self {
            case .GetAllDoneTasks, .GetDoneTaskByItem:
                return .GET
            }
        }
        
        var path: String {
            switch self {
            case .GetAllDoneTasks:
                return "/home/all_done_task/"
            case .GetDoneTaskByItem(let itemId):
                return "/items/\(itemId)/done_task"
            }
        }
    }
    
    enum ItemPercentage: RequestProtocol {
        typealias ResponseType = ItemPercentageEntity
        
        case GetGraph
        
        var method: Alamofire.Method {
            switch self {
            case .GetGraph:
                return .GET
            }
        }
        
        var path: String {
            switch self {
            case .GetGraph:
                return "/home/graph"
            }
        }
    }
    
    enum Timeline: RequestProtocol {
        typealias ResponseType = TimelineEntity
        
        case Get(fromId: Int)
        
        var method: Alamofire.Method {
            switch self {
            case .Get:
                return .GET
            }
        }
        
        var path: String {
            switch self {
            case .Get(let from):
                return "/home/timeline?from=\(from)"
            }
        }
    }
    
    enum Pickup: RequestProtocol {
        typealias ResponseType = PickupEntity
        
        case Get
        
        var method: Alamofire.Method {
            switch self {
            case .Get:
                return .GET
            }
        }
        
        var path: String {
            switch self {
            case .Get:
                return "/pickup"
            }
        }
    }
    
    enum SearchResult: RequestProtocol {
        typealias ResponseType = SearchResultEntity
        
        case GetItem(str: String, page: Int)
        
        var method: Alamofire.Method {
            switch self {
            case .GetItem:
                return .GET
            }
        }
        
        var path: String {
            switch self {
            case .GetItem(let str, let page):
                return "/search/tag?tag=\(str)&page=\(page)"
            }
        }
    }
    
}