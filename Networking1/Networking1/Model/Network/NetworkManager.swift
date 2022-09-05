//
//  NetworkManager.swift
//  Networking1
//
//  Created by Misha Volkov on 19.08.22.
//

import Foundation
import UIKit

class NetworkManager {
    
    func fetchData(url: String, completionHandler: @escaping (_ courses: [Course]) -> Void) {
        
//        let jsonUrlString = "https://swiftbook.ru//wp-content/uploads/api/api_course"
//        let jsonUrlString = "https://swiftbook.ru/wp-content/uploads/api/api_website_description"
//        let jsonUrlString = "https://swiftbook.ru/wp-content/uploads/api/api_missing_or_wrong_fields"
        
        guard let url = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            
            guard let data = data else { return }
            let decoder = JSONDecoder()
            do {
                let courses = try decoder.decode([Course].self, from: data)
                completionHandler(courses)
            } catch let error {
                print(error)
            }
            
        }.resume()
    }
    
    // button GET
    func getPressedWith(_ url: String) {
        
        guard let url = URL(string: url) else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { data, response, error in
            
            guard
                let response = response,
                let data = data else { return }
           // print(response)
            print(data)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print(error)
            }
            
        }.resume()
    }
    
    // button POST
     func postPressedWith(_ url: String) {
        
        guard let url = URL(string: url) else { return }
        
        let userData = ["Course": "Networking", "Lesson": "GET and POST Request"]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: userData, options: []) else { return }
        
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, let response = response else { return }
            print(response)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print("-------")
                print(json)
            } catch {
                print(error)
            }
        }.resume()
    }
    
    // button downloadImage
    func downloadImage(url: String, copletion: @escaping (_ image: UIImage) -> ()) {
        
        guard let url = URL(string: url) else { return }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    copletion(image)
                }
            }
        }
        task.resume()
    }
    
    // button uploadImage
    func uploadImage(url: String) {
        
        let httpHeaders = ["Authorization": "Client-ID 1bd22b9ce396a4c"]
        
        guard let url = URL(string: url),
              let image = UIImage(named: "Notification"),
              let imageProperties = ImageProperties(withImage: image, forKey: "image")
        else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = httpHeaders
        request.httpBody = imageProperties.data
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data)
                    print(jsonData)
                } catch {
                    print(error)
                }
            }
        }.resume()
        
    }
    
}
