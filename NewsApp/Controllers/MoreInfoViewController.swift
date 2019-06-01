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
    @IBOutlet weak var urlOfNews: UITextView!
    
    var imageUrl : String?
    var titleOf : String?
    var published : String?
    var descriptionOf : String?
    var urlOf : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleOfNews.text = titleOf
        publishedDate.text = published
        descritionOfNews.text = descriptionOf
        urlOfNews.text = urlOf
        loadImage(url: imageUrl)
        
    }

    func loadImage(url: String?) {
        if url != "NewsImg" {
            let pictureURL = URL(string: url!)!
            if let pictureData = NSData(contentsOf: pictureURL as URL) {
                imageFromUrl.image = UIImage(data: pictureData as Data)
            }
        } else {
            imageFromUrl.image = UIImage(named: "NewsImg")
        }
    }
}

