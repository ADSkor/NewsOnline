//
//  Network.swift
//  NewsApp
//
//  Created by Aleksandr Skorotkin on 31/05/2019.
//  Copyright © 2019 Aleksandr Skorotkin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import RealmSwift

class Network: UIViewController {
    
    //Allias
    let realm = try! Realm()
    let upload = UploadToDB()
    
    func getDataFromNewsPortal(stringFromSearchButton: String) {
        
        Alamofire.request(stringFromSearchButton, method: .get).responseJSON { response in
            if response.result.isSuccess {
                
                let dataJSON : JSON = JSON(response.result.value!)
                
                //загрузка новых данных в базу данных
                
                self.upload.uploadDataToRealm(json: dataJSON)
            } else {
                print("Error: \(String(describing: response.result.error))")
                let alert = UIAlertController(title: "Network Issue", message: "Возникли проблемы: Нет связи с сервером", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default) { (alertAction) in })
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
}
