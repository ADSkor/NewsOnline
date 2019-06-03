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
    var resultsOfFound : Results<NewsObject>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        navigationItem.title = searchName
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
    }
    
    // MARK: - Button action
    //Search Button
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: title, message: "Введите слово или букву для поиска", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Ожидание ввода данных"
            textField.textColor = .blue
        }
        
        alert.addAction (UIAlertAction(title: "Искать", style: .default) { (alertAction) in
            let textField = alert.textFields![0]
            self.searchName = textField.text!
            self.resultsOfFound = nil
            SVProgressHUD.show()
            
            if textField.text == "" {
                let fullAddress = self.serchAdress + "q" + self.api
                self.navigationItem.title = "All last News"
                self.network.getDataFromNewsPortal(stringFromSearchButton: fullAddress)
                self.resultsOfFound = self.download.loadData(fromSearchString: " ")
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    self.tableView.reloadData()
                    SVProgressHUD.dismiss()
                })
            } else {
                let fullAddress = self.serchAdress + self.searchName + self.api
                self.navigationItem.title = "News with: \(textField.text!)"
                self.network.getDataFromNewsPortal(stringFromSearchButton: fullAddress)
                self.resultsOfFound = self.download.loadData(fromSearchString: self.searchName)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    self.tableView.reloadData()
                    print(self.resultsOfFound!)
                    SVProgressHUD.dismiss()
                })
            }
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { (alertAction) in })
        
        self.present(alert, animated:true, completion: nil)
    }
    
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsOfFound?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellsFromMainTable", for: indexPath)
        
        //Load Image from Url
        
        if self.resultsOfFound?[indexPath.row].urlOfImage != String([]) {
            if let pictureURL = URL(string: (self.resultsOfFound?[indexPath.row].urlOfImage)!) {
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
        //Load Titles from titleOf
        let titleLabel = cell.viewWithTag(3) as! UILabel
        titleLabel.text = self.resultsOfFound?[indexPath.row].titleOf
        
        //Load Viewed Bool for "Seen" image
        if self.resultsOfFound?[indexPath.row].viewed == true {
            var imageV = UIImageView()
            imageV = cell.viewWithTag(2) as! UIImageView
            imageV.isHidden = false
        } else {
            var imageV = UIImageView()
            imageV = cell.viewWithTag(2) as! UIImageView
            imageV.isHidden = true
        }
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToMoreInfo" {
            
            let destinationVC = segue.destination as! MoreInfoViewController
            
            var indexPath = self.tableView.indexPathForSelectedRow
            
            let item = resultsOfFound![(indexPath?.row)!]
            
            //Обновление статуса прочтения, запись и отображение
            do {
                try realm.write {
                    item.viewed = true
                }
            }
            catch {
                print("\n Проблема с изменением данных(viewed) в Realm: \(error) ---(после перехода на MoreInfo)--- \n")
            }
            
            let path = IndexPath(item: indexPath!.row, section: 0)
            tableView.reloadRows(at: [path], with: .automatic)
            
            destinationVC.titleOf = item.titleOf
            destinationVC.published = item.published_at
            destinationVC.urlOf = item.urlOfNews

            //Если Description Пустой
            if item.descriptionOf != String([]) {
                destinationVC.descriptionOf = item.descriptionOf
            } else {
                destinationVC.descriptionOf = "(Empty)"
            }
            
            //Если отсутствует ссылка на image
            if item.urlOfImage != String([]) {
                let pictureURL = URL(string: item.urlOfImage)!
                if NSData(contentsOf: pictureURL as URL) != nil {
                    destinationVC.imageUrl = item.urlOfImage
                }
            } else {
                destinationVC.imageUrl = "NewsImg"
            }
        }
    }
}
