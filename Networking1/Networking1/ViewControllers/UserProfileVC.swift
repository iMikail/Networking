//
//  UserProfileVC.swift
//  Networking1
//
//  Created by Misha Volkov on 1.09.22.
//

import UIKit
import FacebookLogin
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class UserProfileVC: UIViewController {
    
    private var provider: String?
    private var currentUser: CurrentUser?
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 30, y: view.frame.height - 172, width: view.frame.width - 60, height: 50)
        button.backgroundColor = .darkGray
        button.setTitle("Log Out", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addVerticalGradientLayer(topColor: .darkGray, bottomColor: .white)
        userNameLabel.isHidden = true
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchingUserData()
    }
    
    private func setupViews() {
        view.addSubview(logoutButton)
    }
}

extension UserProfileVC {
    
    @objc private func signOut() {
        
        if let providerData = Auth.auth().currentUser?.providerData {
            
            for userInfo in providerData {
                switch userInfo.providerID {
                    case "facebook.com":
                        LoginManager().logOut()
                        print("User did log out of facebook")
                        openLoginVC()
                    case "google.com":
                        GIDSignIn.sharedInstance.signOut()
                        print("User did log out of google")
                        openLoginVC()
                    case "password":
                        try! Auth.auth().signOut()
                        print("User did sign out")
                        openLoginVC()
                    default:
                        print("User is signed in with \(userInfo.providerID)")
                }
            }
        }
    }
    
    private func openLoginVC() {
        
        do {
            try Auth.auth().signOut()
            
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true)
                
                return
            }
            
        } catch let error {
            print("Failed to sign out with error: ", error.localizedDescription)
        }
      
    }
    
    // MARK: - Firebase SDK
    
    private func fetchingUserData() {
        
        if Auth.auth().currentUser != nil {
            
            if let userName = Auth.auth().currentUser?.displayName {
                
                activityIndicator.stopAnimating()
                userNameLabel.isHidden = false
                userNameLabel.text = getProviderData(with: userName)
            } else {
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                Database.database().reference()
                    .child("users").child(uid)
                    .observeSingleEvent(of: .value) { [weak self] snapshot in
                        
                        guard let self = self else { return }
                        guard let userData = snapshot.value as? [String: Any] else { return }
                        
                        self.currentUser = CurrentUser(uid: uid, data: userData)
                        self.activityIndicator.stopAnimating()
                        self.userNameLabel.text = self.getProviderData(with: self.currentUser?.name ?? "Noname")
                        self.userNameLabel.isHidden = false
                        
                    } withCancel: { error in
                        print(error)
                    }
                
            }
            
        }
    }
    
    // providerData for Label
    private func getProviderData(with user: String) -> String {
        
        var greetings = ""
        
        if let providerData = Auth.auth().currentUser?.providerData {
            
            for userInfo in providerData {
                
                switch userInfo.providerID {
                    case "facebook.com":
                        provider = "Facebook"
                    case "google.com":
                        provider = "Google"
                    case "password":
                        provider = "Email"
                    default:
                        break
                }
            }
            
            greetings = "\(user) Logged in with \(provider ?? "Noname")"
        }
        
        return greetings
    }
    
    
}
