//
//  MainTableViewController.swift
//  NewsApp
//
//  Created by Aleksandr Skorotkin on 31/05/2019.
//  Copyright © 2019 Aleksandr Skorotkin. All rights reserved.
//

import UIKit
import RealmSwift
import Realm
import SVProgressHUD
import Alamofire

class MainTableViewController: UITableViewController {
    
    //Allias
    let serchAdress: String = "https://newsapi.org/v2/everything?q="
    var searchName: String = "Hot News"
    let api: String = "&sortBy=publishedAt&language=en&apiKey=b59bc1f13f884301a259ebc4a7c68af2"
    let realm = try! Realm()
    let network = Network()
    let download = DownloadData()
    let arrays = ArraysForMainTable()
    var resultsOfFound : Results<NewsObject>? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        navigationItem.title = searchName
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tableView.reloadData()
        
    }
    
    // MARK: - Buttons action
    //Search Button
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: title, message: "Введите слово или букву для поиска", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Ожидание ввода данных"
            textField.textColor = .blue
        }
        
        alert.addAction (UIAlertAction(title: "Искать", style: .default) { (alertAction) in
            SVProgressHUD.show()
            let textField = alert.textFields![0]
            self.searchName = textField.text!
            
            if textField.text == "" {
                let fullAddress = self.serchAdress + "q" + self.api
                self.navigationItem.title = "All last News"
                self.network.getDataFromNewsPortal(stringFromSearchButton: fullAddress)
                self.resultsOfFound = self.download.loadData(fromSearchString: " ")
                self.updateArrays(resultsFromData: self.resultsOfFound!)
            } else {
                let fullAddress = self.serchAdress + self.searchName + self.api
                self.navigationItem.title = "News with: \(textField.text!)"
                self.network.getDataFromNewsPortal(stringFromSearchButton: fullAddress)
                self.resultsOfFound = self.download.loadData(fromSearchString: self.searchName)
                self.updateArrays(resultsFromData: self.resultsOfFound!)
            }
            
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { (alertAction) in })
        
        self.present(alert, animated:true, completion: nil)
        
    }
    
    

    // MARK: - Table view data source

    func updateArrays(resultsFromData: Results<NewsObject>) {
        clearArrays()
        if resultsFromData.count > 0 {
            for i in 0...resultsFromData.count - 1 {
                arrays.arrayOfDescription.append(resultsFromData[i].descriptionOf)
                arrays.arrayOfTitles.append(resultsFromData[i].titleOf)
                arrays.arrayOfPublished.append(resultsFromData[i].published_at)
                arrays.arrayOfUrlNews.append(resultsFromData[i].urlOfNews)
                arrays.arrayOfImgUrls.append(resultsFromData[i].urlOfImage)
                arrays.arrayOfViewed.append(resultsFromData[i].viewed)
            }
        }
        print("---\n\(resultsFromData)\n---")
        print(arrays.arrayOfViewed)
        print("arrays Updated")
        tableView.reloadData()
        SVProgressHUD.dismiss()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrays.arrayOfTitles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellsFromMainTable", for: indexPath)
        //Load Image from Url
        if self.arrays.arrayOfImgUrls[indexPath.row] != String([]) {
            if let pictureURL = URL(string: self.arrays.arrayOfImgUrls[indexPath.row]) {
                if let pictureData = NSData(contentsOf: pictureURL as URL) {
                    let NewsPicture = UIImage(data: pictureData as Data)
                    var imageV = UIImageView()
                    imageV = cell.viewWithTag(1) as! UIImageView
                    imageV.image = NewsPicture
                } else {
                    var imageV = UIImageView()
                    imageV = cell.viewWithTag(1) as! UIImageView
                    imageV.image = UIImage(named: "NewsImg")
                }
            }
        } else {
            var imageV = UIImageView()
            imageV = cell.viewWithTag(1) as! UIImageView
            imageV.image = UIImage(named: "NewsImg")
        }
        //Load Titles from Array
        let titleLabel = cell.viewWithTag(3) as! UILabel
        titleLabel.text = self.arrays.arrayOfTitles[indexPath.row]
        
        //Load Viewed Bool
        if arrays.arrayOfViewed[indexPath.row] == true {
            var imageV = UIImageView()
            imageV = cell.viewWithTag(2) as! UIImageView
            
//            imageV.isHidden = false
        }
        
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToMoreInfo" {
            
            let destinationVC = segue.destination as! MoreInfoViewController
            
            var indexPath = self.tableView.indexPathForSelectedRow
            
            let items = realm.objects(NewsObject.self)
            
            destinationVC.published = arrays.arrayOfPublished[((indexPath?.row)!)]
            destinationVC.titleOf = arrays.arrayOfTitles[((indexPath?.row)!)]
            destinationVC.urlOf = arrays.arrayOfUrlNews[((indexPath?.row)!)]
            
            //Ищем в данных новость соответсвующую той на которую переходим, чтобы не дублировать если она уже была загружена
            if items.count > 0 {
                for i in 0...items.count - 1 {
                    if items[i].titleOf == destinationVC.titleOf {
                        //тут изменяем Bool на true и записываем это в память(Заменят существующее значение)
                        do {
                            try realm.write {
                                items[i].viewed = true
                            }
                        }
                        catch {
                            print("\n Проблема с записью данных в Realm: \(error) ---(после перехода на MoreInfo)--- \n")
                        }
                    }
                }
            }
            
//            arrays.arrayOfViewed[((indexPath?.row)!)] = true
            
            if self.arrays.arrayOfDescription[indexPath!.row] != String([]) {
                destinationVC.descriptionOf = arrays.arrayOfDescription[((indexPath?.row)!)]
            } else {
                destinationVC.descriptionOf = "(Empty)"
            }
        
            if self.arrays.arrayOfImgUrls[indexPath!.row] != String([]) {
                let pictureURL = URL(string: self.arrays.arrayOfImgUrls[indexPath!.row])!
                if NSData(contentsOf: pictureURL as URL) != nil {
                    destinationVC.imageUrl = arrays.arrayOfImgUrls[((indexPath?.row)!)]
                }
            } else {
                destinationVC.imageUrl = "NewsImg"
            }
            
            
        }
        
    }
    
    
    // MARK: - Others
    //Clear Arrays
    func clearArrays() {
        arrays.arrayOfDescription.removeAll()
        arrays.arrayOfTitles.removeAll()
        arrays.arrayOfPublished.removeAll()
        arrays.arrayOfUrlNews.removeAll()
        arrays.arrayOfImgUrls.removeAll()
        arrays.arrayOfViewed.removeAll()
    }
    

}
