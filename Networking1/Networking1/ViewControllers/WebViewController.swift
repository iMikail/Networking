//
//  WebViewController.swift
//  Networking1
//
//  Created by Misha Volkov on 19.08.22.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var nameCourseLabel: UILabel!
    @IBOutlet weak var linkCourseLabel: UILabel!
    
    var nameCourse: String?
    var link: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameCourseLabel.text = nameCourse
        linkCourseLabel.text = link
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
