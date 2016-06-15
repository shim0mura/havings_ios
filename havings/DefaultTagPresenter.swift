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

    static func migrateTag(){
        
        let localMigrationVersion = getLocalMigrationVersion()
        print(Realm.Configuration.defaultConfiguration.fileURL!)

        compareMigrationVersionToLocalVersion(localMigrationVersion)
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
        
        try! realm.write(){
            tagMigration.updatedTags.forEach{
                realm.add($0, update: true)
            }
        }
        
        if let tagMigrationVersion = realm.objects(TagMigrationEntity).last {
            try! realm.write() {
                tagMigrationVersion.migrationVersion = tagMigration.migrationVersion
            }
        }else {
            let tagMigrationVersion = TagMigrationEntity()
            tagMigrationVersion.migrationVersion = tagMigration.migrationVersion
            try! realm.write() {
                realm.add(tagMigrationVersion)
            }
        }
        
    }
}