//
//  AlamofireNetworkRequest.swift
//  Networking1
//
//  Created by Misha Volkov on 29.08.22.
//

import Foundation
import Alamofire
import UIKit

class AlamofireNetworkRequest {
    
    static var onProgress: ((Double) -> ())?
    static var completed: ((String) -> ())?
    
    static func sendRequest(url: String, completion: @escaping (_ courses: [Course]) -> ()) {
        
        guard let url = URL(string: url) else { return }
        
        AF.request(url, method: .get).validate().responseJSON { (response) in
           
            switch response.result {
                case .success(let value):
                    
                    var courses = [Course]()
                    courses = Course.getArray(from: value)!
                    completion(courses)
                    
                case .failure(let error):
                    print(error)
            }
          
        }

    }
    
    static func responseData(url: String) {
        
        AF.request(url).responseData { (responseData) in
            switch responseData.result {
                case .success(let data):
                    
                    guard let string = String(data: data, encoding: .utf8) else { return }
                    print(string)
                    
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    static func responseString(url: String) {
        AF.request(url).responseString { (responseString) in
            
            switch responseString.result {
                case .success(let string):
                    print(string)
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    static func response(url: String) {
        
        AF.request(url).response { (response) in
            
            guard let data = response.data,
                  let string = String(data: data, encoding: .utf8)
            else { return }
            print(string)
        }
    }
    
    static func downloadImage(url: String, completion: @escaping (_ image: UIImage) -> ()) {
        
        guard let url = URL(string: url) else { return }
        
        AF.request(url).responseData { (responseData) in
            switch responseData.result {
                case .success(let data):
                    
                    guard let image = UIImage(data: data) else { return }
                    completion(image)
                    
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    // Download Large Image with Progress
    static func downloadImageWithProgress(url: String, completion: @escaping (_ image: UIImage) -> ()) {
        
        guard let url = URL(string: url) else { return }
      
        AF.request(url).validate().downloadProgress { (progress) in
            
            self.onProgress?(progress.fractionCompleted)
            self.completed?(progress.localizedDescription)
            
            print("totalUnitCount: \(progress.totalUnitCount)")
            print("completedUnitCount: ", progress.completedUnitCount)
            print("fractionCompleted: ", progress.fractionCompleted)
            print("localizedDescription: ", progress.localizedDescription ?? "nil")
            print("----------------")
           // print("localizedAdditionalDescription: ", progress.localizedAdditionalDescription)
        }.response { (response) in
            
            guard let data = response.data,
                  let image = UIImage(data: data)
            else { return }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    // POST Request
    static func postRequest(url: String, completion: @escaping (_ courses: [Course]) -> ()) {
        
        guard let url = URL(string: url) else { return }
        
        let userData: [String: Any] = ["name": "Network request",
                                       "link": "https://swiftbook.ru/contents/applications-based-on-tableview/",
                                       "imageUrl": "https://swiftbook.ru/wp-content/uploads/2018/03/3-courselogo-1.jpg",
                                       "number_of_lessons": 67,
                                       "number_of_tests": 0]
        
        AF.request(url, method: .post, parameters: userData).responseJSON { (responseJSON) in
            
            guard let statusCode = responseJSON.response?.statusCode else { return }
            print("statusCode: ", statusCode)
            
            switch responseJSON.result {
                case .success(let value):
                    print(value)
                    
                    guard let jsonObject = value as? [String: Any],
                          let course = Course(json: jsonObject)
                    else { return }
                    
                    var courses = [Course]()
                    courses.append(course)
                    
                    completion(courses)
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    // PUT Requset
    static func putRequest(url: String, completion: @escaping (_ courses: [Course]) -> ()) {
        
        guard let url = URL(string: url) else { return }
        
        let userData: [String: Any] = ["name": "Network request with Alamofire",
                                       "link": "https://swiftbook.ru/contents/applications-based-on-tableview/",
                                       "imageUrl": "https://swiftbook.ru/wp-content/uploads/2018/03/3-courselogo-1.jpg",
                                       "number_of_lessons": 67,
                                       "number_of_tests": 0]
        
        AF.request(url, method: .put, parameters: userData).responseJSON { (responseJSON) in
            
            guard let statusCode = responseJSON.response?.statusCode else { return }
            print("statusCode: ", statusCode)
            
            switch responseJSON.result {
                case .success(let value):
                    print(value)
                    
                    guard let jsonObject = value as? [String: Any],
                          let course = Course(json: jsonObject)
                    else { return }
                    
                    var courses = [Course]()
                    courses.append(course)
                    
                    completion(courses)
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    static func uploadImage(url: String) {
        
        guard let url = URL(string: url) else { return }
        
        let image = UIImage(named: "Notification")!
        let data = image.pngData()!
        
        let httpHeaders = ["Authorization": "Client-ID 1bd22b9ce396a4c"]
       
        AF.upload(multipartFormData: { (multipartFormData) in
            
            multipartFormData.append(data, withName: "image")
            
        }, to: url, headers: HTTPHeaders(httpHeaders)).validate().responseJSON { (response) in
            
            switch response.result {
                    
                case .success(let value):
                    print(value)
                case .failure(let error):
                    print(error)
            }
        }
    }
    
}
