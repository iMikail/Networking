//
//  CourseModel.swift
//  Networking1
//
//  Created by Misha Volkov on 19.08.22.
//

import Foundation

struct WebsiteDescription: Codable {
    
    let websiteName: String?
    let websiteDescription: String?
    
    let courses: [Course?]
}

// для одновренменной работы URLSession and Alamofire
struct Course: Codable {
    
    let id: Int?
    let name: String?
    let link: String?
    let imageUrl: String?
    let numberOfLessons: Int?
    let numberOfTests: Int?
    
    init?(json: [String: Any]) {
        let id = json["id"] as? Int,
            name = json["name"] as? String,
            link = json["link"] as? String,
            imageUrl = json["imageUrl"] as? String,
            numberOfLessons = json["number_of_lessons"] as? Int,
            numberOfTests = json["number_of_tests"] as? Int
        
        self.id = id
        self.name = name
        self.link = link
        self.imageUrl = imageUrl
        self.numberOfLessons = numberOfLessons
        self.numberOfTests = numberOfTests
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, link, imageUrl
        case numberOfLessons = "number_of_lessons"
        case numberOfTests = "number_of_tests"
    }
    
    static func getArray( from jsonArray: Any) -> [Course]? {
        
        guard let jsonArray = jsonArray as? Array<[String: Any]> else { return nil }
        
        return jsonArray.compactMap { Course(json: $0) }
        
        // аналог
//        var courses: [Course] = []
//
//        for jsonObject in jsonArray {
//            if let course = Course(json: jsonObject) {
//                courses.append(course)
//            }
//        }
//
//        return courses
    }
    
}

//struct Course: Codable {
//
//    let id: Int?
//    let name: String?
//    let link: String?
//    let imageUrl: String?
//    let numberOfLessons: Int?
//    let numberOfTests: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, link, imageUrl
//        case numberOfLessons = "number_of_lessons"
//        case numberOfTests = "number_of_tests"
//    }
//
//}


