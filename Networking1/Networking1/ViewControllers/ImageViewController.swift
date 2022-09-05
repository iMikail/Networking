//
//  ViewController.swift
//  Networking1
//
//  Created by Misha Volkov on 19.08.22.
//

import UIKit
import Alamofire

class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    
    
    private let urlString = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTBcYLSK_2EGraGiAKhuz8MXZ5caC1U0Z1oAA&usqp=CAU"
    private let largeImageUrl = "https://i.imgur.com/3416rvI.jpg"
    private let networkManager = NetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        completedLabel.isHidden = true
        progressView.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }

    func fetchImage() {
        
        networkManager.downloadImage(url: urlString) { image in
            self.activityIndicator.stopAnimating()
            self.imageView.image = image
        }
        
    }
    
    func fetchDataWithAlamofire() {
        AlamofireNetworkRequest.downloadImage(url: urlString) { image in
            self.activityIndicator.stopAnimating()
            self.imageView.image = image
        }
    }
    
    // largeImage
    func downloadImageWithProgress() {
        
        AlamofireNetworkRequest.onProgress = { progress in
            self.progressView.isHidden = false
            self.progressView.progress = Float(progress)
        }
        
        AlamofireNetworkRequest.completed = { completed in
            self.completedLabel.isHidden = false
            self.completedLabel.text = completed
        }
        
        AlamofireNetworkRequest.downloadImageWithProgress(url: largeImageUrl) { image in
            self.activityIndicator.stopAnimating()
            self.progressView.isHidden = true
            self.completedLabel.isHidden = true
            self.imageView.image = image
        }
    }
    
}

