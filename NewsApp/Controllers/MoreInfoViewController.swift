//
//  ViewController.swift
//  NewsApp
//
//  Created by Aleksandr Skorotkin on 31/05/2019.
//  Copyright © 2019 Aleksandr Skorotkin. All rights reserved.
//

import UIKit

class MoreInfoViewController: UIViewController {
    
    //Allias
    @IBOutlet weak var imageFromUrl: UIImageView!
    @IBOutlet weak var titleOfNews: UILabel!
    @IBOutlet weak var publishedDate: UILabel!
    @IBOutlet weak var descritionOfNews: UILabel!
    @IBOutlet weak var urlOfNews: UILabel!
    
    
    var titleOf: String = ""
    var published: String = ""
    var descriptionOf: String = ""
    var urlOf: String = ""
    var imageUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleOfNews.text = titleOf
        publishedDate.text = published
        descritionOfNews.text = descriptionOf
        urlOfNews.text = urlOf
        loadImage(url: imageUrl)
        
        //Кликабельность ссылки через GestureRecognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onClicLabel(sender:)))
        urlOfNews.isUserInteractionEnabled = true
        urlOfNews.addGestureRecognizer(tap)
        
    }

    func loadImage(url: String?) {
        if url != "NewsImg" {
            if let pictureURL = URL(string: url!) {
                if let pictureData = NSData(contentsOf: pictureURL as URL) {
                    imageFromUrl.image = UIImage(data: pictureData as Data)
                }
            } else {
                imageFromUrl.image = UIImage(named: "NewsImg")
            }
        } else {
            imageFromUrl.image = UIImage(named: "NewsImg")
        }
    }
    
    //Кликабельность ссылки и переход в сафари
    @objc func onClicLabel(sender:UITapGestureRecognizer) {
        openUrl(urlString: urlOfNews.text)
    }
    
    //Возможность открытия и само открытие ссылки
    func openUrl(urlString:String!) {
        let url = URL(string: urlString)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}

