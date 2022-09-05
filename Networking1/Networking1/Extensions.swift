//
//  Extensions.swift
//  Networking1
//
//  Created by Misha Volkov on 1.09.22.
//

import Foundation
import UIKit

extension UIView {
    
    func addVerticalGradientLayer(topColor: UIColor, bottomColor: UIColor) {
        
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [topColor.cgColor, bottomColor.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func addBottomLine() {
        
        let line = UIView()
        line.backgroundColor = .white
        line.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(line)
        line.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -2).isActive = true
        line.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        line.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        line.heightAnchor.constraint(equalToConstant: 2).isActive = true
    }

}
