//
//  DefaultTagPresenter.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/14.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import RealmSwift

class DefaultTagPresenter {
    
    static let TAG_TYPE_PLACE: Int = 0
    static let TAG_TYPE_CATEGORY: Int = 3
    static let TAG_TYPE_ITEM: Int = 2
    static let TAG_TYPE_CLOSET: Int = 1
    
    static let MAX_SUBTEXT_TAG_COUNT = 3
    
    static func exportRealmFromCSV(){
        
        // csvからrealmファイル出力
        print("!!!!!!!!!!!!!")
        print(NSBundle.mainBundle().pathForResource("tag", ofType: "csv"))
        if let csvPath = NSBundle.mainBundle().pathForResource("tag", ofType: "csv") {
            print("!!!!!!!!")
            var csvString=""
            do{
                csvString = try NSString(contentsOfFile: csvPath, encoding: NSUTF8StringEncoding) as String
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            let realm = try! Realm()
            
            try! realm.write {
                realm.deleteAll()
            }
            
            csvString.enumerateLines { (line, stop) -> () in
                // 保存先のパスを出力しておく
                print(Realm.Configuration.defaultConfiguration)
                
                let tag = TagEntity()
                tag.id = Int(line.componentsSeparatedByString(",")[0])!
                tag.name = line.componentsSeparatedByString(",")[1]
                tag.yomiJp = line.componentsSeparatedByString(",")[2]
                tag.yomiRoma = line.componentsSeparatedByString(",")[3]
                tag.parentId = Int(line.componentsSeparatedByString(",")[4])!
                tag.priority = Int(line.componentsSeparatedByString(",")[5])!
                tag.nest = Int(line.componentsSeparatedByString(",")[6])!
                tag.tagType = Int(line.componentsSeparatedByString(",")[7])!
                
                try! realm.write {
                    realm.add(tag)
                }
            }
        }
        
    }
    
    static func setDefaultTagConf(){
        let seedFileURL = NSBundle.mainBundle().URLForResource("tag", withExtension: "realm")
        let config = Realm.Configuration(fileURL: seedFileURL, readOnly: true)
        Realm.Configuration.defaultConfiguration = config
    }

    static func migrateTag(){
        
        let localMigrationVersion = getLocalMigrationVersion()
        print(Realm.Configuration.defaultConfiguration.fileURL!)

        compareMigrationVersionToLocalVersion(localMigrationVersion)
    }
    
    static func getDefaultTagsByType(type: Int) -> Results<TagEntity>{
        let realm = try! Realm()
        
        let tags = realm.objects(TagEntity)
            .filter("tagType == %@", type)
            .filter("isDeleted == %@", false)
        return tags
    }
    
    static func getDefaultTagNamesByCategory() -> [Dictionary<String, [Dictionary<String, String>]>]{
        var result: [Dictionary<String, [Dictionary<String, String>]>] = []
        
        let realm = try! Realm()
        
        let parentTags = realm.objects(TagEntity)
            .filter("tagType == %@", TAG_TYPE_CATEGORY)
            .filter("parentId == %@", 0)
            .filter("isDeleted == %@", false)
        
        parentTags.forEach{
            let childs = getChildTags($0, nest: 0)
            result.append([$0.name!: childs])
        }
        
        return result
    }
    
    static func getDefaultTagStrings() -> [String]{
        let realm = try! Realm()
        
        return realm.objects(TagEntity).filter("isDeleted == %@", false).map{
            $0.name!
        }

    }
    
    static func getDefaultTags() -> [MultiAutoCompleteToken] {
        let realm = try! Realm()
        
        return realm.objects(TagEntity).filter("isDeleted == %@", false).map{
            
            MultiAutoCompleteToken(top: $0.name!, subTexts: ($0.yomiJp ?? ""), ($0.yomiRoma ?? ""))
        }
    }
    
    private static func getChildTags(parentTag: TagEntity, nest: Int) -> [Dictionary<String, String>]{
        let realm = try! Realm()
        
        var result: [Dictionary<String, String>] = []
        let childTags = realm.objects(TagEntity)
            .filter("parentId == %@", parentTag.id)
            .filter("isDeleted == %@", false)
        let tagCount = (childTags.count > MAX_SUBTEXT_TAG_COUNT ? MAX_SUBTEXT_TAG_COUNT : childTags.count)
        
        var str: String = ""
        
        for i in 0..<tagCount {
            str += childTags[i].name!
            
            if i != (tagCount - 1) {
                str += ", "
            }else{
                str += "など"
            }
        }
        
        let dict = ["name": parentTag.name!, "subtext": str]
        result.append(dict)
        
        childTags.forEach{
            if $0.tagType == TAG_TYPE_CATEGORY && nest < 1 {
                result += getChildTags($0, nest: nest + 1)
            }
        }
        
        return result
    }
    
    private static func getLocalMigrationVersion() -> Int {
        let realm = try! Realm()
        let localVersionResults = realm.objects(TagMigrationEntity)
        if let localVersion = localVersionResults.last {
            return localVersion.migrationVersion
        }else{
            return 0
        }
    }
    
    private static func compareMigrationVersionToLocalVersion(localVersion: Int) {
        API.call(Endpoint.TagMigration.GetLatestVersion) { response in
            switch response {
            case .Success(let result):
                print(result.migrationVersion)
                if result.migrationVersion > localVersion {
                    getTagMigrationFrom(localVersion)
                }else{
                    print("same migration")
                }
                
            case .Failure(let error):
                print("failure \(error)")
            }
        }
    }
    
    private static func getTagMigrationFrom(id: Int){
        API.callArray(Endpoint.TagMigration.GetTagMigrationFrom(fromId: id)) { response in
            switch response {
            case .Success(let result):
                print("tag entity count \(result.count)")
                result.forEach{
                    updateDefaultTag($0)
                }
            case .Failure(let error):
                print("failure \(error)")
            }
        }
    }
    
    private static func updateDefaultTag(tagMigration: TagMigrationEntity){

        let realm = try! Realm()
        
        try! realm.write {
            tagMigration.updatedTags.forEach{
                realm.add($0, update: true)
            }
        }
        
        if let tagMigrationVersion = realm.objects(TagMigrationEntity).last {
            try! realm.write {
                tagMigrationVersion.migrationVersion = tagMigration.migrationVersion
            }
        }else {
            let tagMigrationVersion = TagMigrationEntity()
            tagMigrationVersion.migrationVersion = tagMigration.migrationVersion
            try! realm.write {
                realm.add(tagMigrationVersion)
            }
        }
        
    }
}