//
//  CurrentUser.swift
//  Networking1
//
//  Created by Misha Volkov on 2.09.22.
//

import Foundation

struct CurrentUser {
    
    let uid: String
    let name: String
    let email: String
    
    init?(uid: String, data: [String: Any]) {
        
        guard let name = data["name"] as? String,
              let email = data["email"] as? String
        else { return nil }
    
    self.uid = uid
    self.name = name
    self.email = email
    }
    
}
