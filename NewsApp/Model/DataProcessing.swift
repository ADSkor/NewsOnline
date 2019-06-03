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
    @objc dynamic var countOfNews = 0
    
}

// MARK: - Class for count news

class Count: Object {
    
    @objc dynamic var count = 0
    
}


// MARK: - Class for upload to Realm

class UploadToDB {
    
    let realm = try! Realm()
    
    func uploadDataToRealm(json: JSON) {
        
        //Счетчик загрузок
        let count = Count()
        count.count += 1
        try! realm.write {
            realm.add(count)
        }
        
        deleteData()
        
        let correctCount = realm.objects(Count.self).count
        
        if json["totalResults"].stringValue != "0" {
            for i in 0...json["articles"].count - 1 {
                
                let item = NewsObject()
                item.titleOf = json["articles"][i]["title"].stringValue
                let fullDate = json["articles"][i]["publishedAt"].stringValue
                let endIndex = fullDate.index(fullDate.startIndex, offsetBy: 16)
                item.published_at = String(fullDate[..<endIndex])
                item.descriptionOf = json["articles"][i]["description"].stringValue
                item.urlOfImage = json["articles"][i]["urlToImage"].stringValue
                item.urlOfNews = json["articles"][i]["url"].stringValue
                item.viewed = false
                item.countOfNews = correctCount
                
                //Проверка на уникальность новых данных
                let items = realm.objects(NewsObject.self)
                var tempValue = false
                
                if items.count > 0 {
                    
                    for i in 0...items.count - 1 {
                        if items[i].titleOf == item.titleOf {
                            tempValue = true
                            print("Эта новость уже загружена: \(items[i].titleOf), повторной загрузки не будет.")
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
    
    //Удаление данных старше 5 загрузок
    func deleteData() {
        
        let correctCount = realm.objects(Count.self).count
        if correctCount > 4 {
            let oldNews = realm.objects(NewsObject.self).filter("countOfNews < \(correctCount - 5)")
            try! realm.write {
                realm.delete(oldNews)
            }
            print("Старые данные успешно удалены")
            
        }
    }
}

//MARK: - Class for download from Realm

class DownloadData {
    
    let realm = try! Realm()
    
    func loadData(fromSearchString: String) -> Results<NewsObject> {
        return realm.objects(NewsObject.self).filter("titleOf contains '\(fromSearchString)'")
    }
    
}
