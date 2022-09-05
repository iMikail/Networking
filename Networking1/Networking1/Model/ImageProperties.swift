//
//  ImageProperties.swift
//  Networking1
//
//  Created by Misha Volkov on 22.08.22.
//

import Foundation
import UIKit

struct ImageProperties {
    
    let key: String
    let data: Data
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        guard let data = image.pngData() else { return nil }
        self.data = data
    }
}
