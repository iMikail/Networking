//
//  MainViewController.swift
//  Networking1
//
//  Created by Misha Volkov on 22.08.22.
//

import UIKit
import UserNotifications
import FacebookLogin
import FirebaseAuth

enum Actions: String, CaseIterable {
    case downloadImage = "Download Image"
    case get = "GET"
    case post = "POST"
    case ourCourses = "Our Courses"
    case uploadImage = "Upload Image"
    case downloadFile = "Download File"
    case ourCoursesAlamofire = "Our Courses(Alamofire)"
    case responseData = "Response Data"
    case responseString = "Response String"
    case response = "Response"
    case downloadLargeImage = " Download Large Image"
    case postAlamofire = "POST witn Alamofire"
    case putRequest = "PUT Request witn Alamofire"
    case uploadImageAlamofire = "Upload Image(Alamofire)"
}

private let reuseIdentifier = "Cell"
private let stringUrl = "https://jsonplaceholder.typicode.com/posts"
private let uploadImageUrl = "https://api.imgur.com/3/image"
private let swiftbookApi = "https://swiftbook.ru//wp-content/uploads/api/api_courses"
private let networkManager = NetworkManager()


class MainViewController: UICollectionViewController {

    let actions = Actions.allCases
    private var alert: UIAlertController!
    private let dataProvider = DataProvider()
    private var filePath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForNotification()
        
        
        dataProvider.fileLocation = { (location) in
            
            // save path
            print("Download finished: \(location.absoluteString)")
            self.filePath = location.absoluteString
            self.alert.dismiss(animated: false)
            self.postNotification()
        }
        
        checkLoggedIn()
    }
    
    // Download alertController
    private func showAlert() {
        alert = UIAlertController(title: "Downloading ...", message: "0%", preferredStyle: .alert)
        
        // height view for indicator and progressBar
        let height = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 170)
        alert.view.addConstraint(height)
        
        
        let canselAction = UIAlertAction(title: "Cansel", style: .destructive) { (action) in
            self.dataProvider.stopDownload()
        }
        alert.addAction(canselAction)
        
        present(alert, animated: true) {
            let size = CGSize(width: 40, height: 40)
            let point = CGPoint(x: self.alert.view.frame.width / 2 - size.width / 2,
                                y: self.alert.view.frame.height / 2 - size.height / 2)
            
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(origin: point, size: size))
            activityIndicator.color = .gray
            activityIndicator.startAnimating()
            
            let progressView = UIProgressView(frame: CGRect(x: 0, y: self.alert.view.frame.height - 44, width: self.alert.view.frame.width, height: 2))
            progressView.tintColor = .blue
            
            self.dataProvider.onProgress = { (progress) in
                progressView.progress = Float(progress)
                self.alert.message = String(Int(progress * 100)) + "%"
            }
            
            self.alert.view.addSubview(activityIndicator)
            self.alert.view.addSubview(progressView)
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return actions.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CustomCollectionViewCell
    
        cell.label.text = actions[indexPath.row].rawValue
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let action = actions[indexPath.row]
        
        switch action {
            case .downloadImage:
                performSegue(withIdentifier: "showImageVC", sender: self)
            case .get:
                networkManager.getPressedWith(stringUrl)
            case .post:
                networkManager.postPressedWith(stringUrl)
            case .ourCourses:
                performSegue(withIdentifier: "ourCourses", sender: self)
            case .uploadImage:
                networkManager.uploadImage(url: uploadImageUrl)
            case .downloadFile:
                showAlert()
                dataProvider.startDownload()
            case .ourCoursesAlamofire:
                performSegue(withIdentifier: "ourCoursesWithAlamofire", sender: self)
            case .responseData:
                performSegue(withIdentifier: "responseData", sender: self)
                AlamofireNetworkRequest.responseData(url: swiftbookApi)
            case .responseString:
                AlamofireNetworkRequest.responseString(url: swiftbookApi)
            case .response:
                AlamofireNetworkRequest.response(url: swiftbookApi)
            case .downloadLargeImage:
                performSegue(withIdentifier: "snowVCLatgeImage", sender: self)
            case .postAlamofire:
                performSegue(withIdentifier: "POSTwitnAlamofire", sender: self)
            case .putRequest:
                performSegue(withIdentifier: "putRequest", sender: self)
            case .uploadImageAlamofire:
                AlamofireNetworkRequest.uploadImage(url: uploadImageUrl)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let coursesVC = segue.destination as? CoursesViewController,
            imageVC = segue.destination as? ImageViewController
        
        switch segue.identifier {
            case "ourCourses":
                coursesVC?.fetchData()
            case "ourCoursesWithAlamofire":
                coursesVC?.fetchDataWithAlamofire()
            case "POSTwitnAlamofire":
                coursesVC?.postRequest()
            case "putRequest":
                coursesVC?.putRequest()
                
            case "showImageVC":
                imageVC?.fetchImage()
            case "responseData":
                imageVC?.fetchDataWithAlamofire()
            case "snowVCLatgeImage":
                imageVC?.downloadImageWithProgress()
                
            default:
                break
        }
    }
}

// push Notification
extension MainViewController {
    
    private func registerForNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (_, _) in
            
        }
    }
    
    private func postNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = "Download complete!"
        content.body = "Your background transfer has completed. File path \(filePath!)"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        let request = UNNotificationRequest(identifier: "TransferComplete", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
}

// MARK: - Facebook SDK

extension MainViewController {
    
    private func checkLoggedIn() {
        
        if Auth.auth().currentUser == nil {
            
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true)
                
                return
            }
        }
    }
    
}
