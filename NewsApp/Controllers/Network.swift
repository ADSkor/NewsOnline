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
    let upload = Upload()
    
    func getDataFromNewsPortal(stringFromSearchButton: String) {
        
        Alamofire.request(stringFromSearchButton, method: .get).responseJSON { response in
            if response.result.isSuccess {
                
                let dataJSON : JSON = JSON(response.result.value!)
//                print(dataJSON)
                self.upload.uploadData(json: dataJSON)
            } else {
                print("Error: \(String(describing: response.result.error))")
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "Network Issue", message: "Возникли проблемы: Нет связи с сервером", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default) { (alertAction) in })
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
}