//
//  ViewController.swift
//  NewsApp
//
//  Created by Aleksandr Skorotkin on 31/05/2019.
//  Copyright © 2019 Aleksandr Skorotkin. All rights reserved.
//

import UIKit
import SDWebImage

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
        imageFromUrl.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "NewsImg"))
        //Кликабельность ссылки через GestureRecognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onClicLabel(sender:)))
        urlOfNews.isUserInteractionEnabled = true
        urlOfNews.addGestureRecognizer(tap)
        
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

