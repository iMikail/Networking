//
//  CoursesViewController.swift
//  Networking1
//
//  Created by Misha Volkov on 19.08.22.
//

import UIKit

class CoursesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let postRequestUrl = "https://jsonplaceholder.typicode.com/posts"
    private let putRequestUrl = "https://jsonplaceholder.typicode.com/posts/1"
    private let jsonUrlString = "https://swiftbook.ru//wp-content/uploads/api/api_courses"
    
    private let networkManager = NetworkManager()
    
    private var courses = [Course]()
    private var courseName: String?
    private var courseURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    func fetchData() {
        networkManager.fetchData(url: jsonUrlString) { courses in
            self.courses = courses
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchDataWithAlamofire() {
        AlamofireNetworkRequest.sendRequest(url: jsonUrlString) { courses in
            self.courses = courses
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func postRequest() {
        AlamofireNetworkRequest.postRequest(url: postRequestUrl) { courses in
            self.courses = courses
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func putRequest() {
        AlamofireNetworkRequest.putRequest(url: putRequestUrl) { courses in
            
            self.courses = courses
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func configureCell(cell: CustomViewCell, for indexPath: IndexPath) {
        let course = courses[indexPath.row]
        cell.courseNameLabel.text = course.name
        
        if let numberOfLessons = course.numberOfLessons {
            cell.numberOfLessons.text = "Number of lessons: \(numberOfLessons)"
        }
        
        if let numberOfTests = course.numberOfTests {
            cell.numberOfTests.text = "Number of tests: \(numberOfTests)"
        }
        
        DispatchQueue.global().async {
            guard let imageUrl = URL(string: course.imageUrl!) else { return }
            guard let imageData = try? Data(contentsOf: imageUrl) else { return }
            
            DispatchQueue.main.async {
                cell.courseImage.image = UIImage(data: imageData)
            }
        }
        
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let webViewController = segue.destination as? WebViewController {
            webViewController.nameCourse = courseName
            if let link = courseURL {
                webViewController.link = link
            }
        }
    }


}

// MARK: - TableViewDataSource
extension CoursesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomViewCell
        
        configureCell(cell: cell, for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let course = courses[indexPath.row]
        
        courseURL = course.link
        courseName = course.name
        
        performSegue(withIdentifier: "description", sender: self)
    }
    
}
