//
//  UserProfile.swift
//  Networking1
//
//  Created by Misha Volkov on 1.09.22.
//

import Foundation

// Facebook data
struct UserProfile {
    
    var name: String?
    var id: Int?
    var email: String?
    
    init(data: [String: Any]) {
        
        let name = data["name"] as? String
        let id = data["id"] as? Int
        let email = data["email"] as? String
        
        self.name = name
        self.id = id
        self.email = email
    }
    
}
