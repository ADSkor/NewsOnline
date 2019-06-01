//
//  Data.swift
//  NewsApp
//
//  Created by Aleksandr Skorotkin on 31/05/2019.
//  Copyright © 2019 Aleksandr Skorotkin. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON


// MARK: - Class for Realm objects

class NewsObject: Object {
    
    @objc dynamic var titleOf = ""
    @objc dynamic var published_at = ""
    @objc dynamic var descriptionOf = ""
    @objc dynamic var urlOfNews = ""
    @objc dynamic var urlOfImage = ""
    @objc dynamic var viewed = false
    
}


// MARK: - Class for upload

class Upload {
    let realm = try! Realm()
    
    func uploadData(json: JSON) {
        
        if json["totalResults"].stringValue != "0" {
            for i in 0...json["articles"].count - 1 {
                
                let item = NewsObject()
                item.titleOf = json["articles"][i]["title"].stringValue
                let fullDate = json["articles"][i]["publishedAt"].stringValue
                let endIndex = fullDate.index(fullDate.endIndex, offsetBy: -4)
                let truncated = String(fullDate[..<endIndex])
                item.published_at = truncated
                item.descriptionOf = json["articles"][i]["description"].stringValue
                item.urlOfImage = json["articles"][i]["urlToImage"].stringValue
                item.urlOfNews = json["articles"][i]["url"].stringValue
                item.viewed = false
                
                    //Проверка на уникальность новых данных
                let items = realm.objects(NewsObject.self)
                var tempValue = false
                
                if items.count > 0 {
                    
                    for i in 0...items.count - 1 {
                        if items[i].titleOf == item.titleOf {
                            tempValue = true
                            print("Эта новость уже загружена: \(items[i].titleOf)")
                        }
                    }
                }
                
                    //Загрузка после проверки уникальности
                if tempValue == false {
                    try! realm.write {
                        realm.add(item)
                    }
                    print("Загрузка новых данных")
                }
            }
        } else {
            print("Загрузки не будет, т.к. нет данных.")
        }
    }
}

//MARK: - Class for download

class DownloadData {
    
    let realm = try! Realm()
    
    func loadData(fromSearchString: String) -> Results<NewsObject> {
        return realm.objects(NewsObject.self).filter("descriptionOf contains '\(fromSearchString)'")
    }
    
}





