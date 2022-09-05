//
//  LoginViewController.swift
//  Networking1
//
//  Created by Misha Volkov on 31.08.22.
//

import UIKit
import FacebookLogin
import Alamofire
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import GoogleSignIn

class LoginViewController: UIViewController {
    
    var userProfile: UserProfile?
    
    lazy var loginButtonFB: UIButton = {
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 0, y: 0, width: view.frame.width - 60, height: 50)
        loginButton.center = view.center
        loginButton.delegate = self
        return loginButton
    }()
    
    lazy var customFBLoginButton: UIButton = {
       let loginButton = UIButton()
        loginButton.backgroundColor = .systemGreen
        loginButton.setTitle("Login with Facebook", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        loginButton.setTitleColor(UIColor.brown, for: .normal)
        loginButton.frame = CGRect(x: 0, y: 0, width: view.frame.width - 60, height: 50)
        loginButton.center = view.center
        loginButton.center.y += 70
        loginButton.layer.cornerRadius = 5
        loginButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        return loginButton
    }()
    
    lazy var googleLoginButton: GIDSignInButton = {
       
        let loginButton = GIDSignInButton()
        loginButton.frame = CGRect(x: 0, y: 0, width: view.frame.width - 60, height: 50)
        loginButton.center = view.center
        loginButton.center.y += 70 + 70
        loginButton.addTarget(self, action: #selector(signInWithGoogle), for: .touchUpInside)
        
        return loginButton
    }()
    
    lazy var emailLoginButton: UIButton = {
        
        var loginButton = UIButton()
        loginButton.frame = CGRect(x: 0, y: 0, width: view.frame.width - 60, height: 50)
        loginButton.center = view.center
        loginButton.center.y += 70 + 70 + 70
        loginButton.setTitle("Sign in with Email", for: .normal)
        loginButton.setTitleColor(UIColor.black, for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        loginButton.addTarget(self, action: #selector(openSignInVC), for: .touchUpInside)
        
        return loginButton
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addVerticalGradientLayer(topColor: .darkGray, bottomColor: .lightGray)
        setupViews()
        
    }
    
    private func setupViews() {
        view.addSubview(loginButtonFB)
        view.addSubview(customFBLoginButton)
        view.addSubview(googleLoginButton)
        view.addSubview(emailLoginButton)
    }
    
    @objc private func openSignInVC() {
        performSegue(withIdentifier: "openSignIn", sender: self)
    }
    
}
// MARK: - Facebook SDK
extension LoginViewController: LoginButtonDelegate {
    
    // default button
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if error != nil {
            print(error!)
            return
        }
        
        guard AccessToken.isCurrentAccessTokenActive else { return }
        
        singIntoFirebase()
        print("Succefully logged in with facebook")
        
    }
    
    // log out
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
        print("Did log out of facebook")
    }
    
    private func openMainViewController() {
        dismiss(animated: true)
    }
    
    // action for custom facebook button
   @objc private func handleCustomFBLogin() {
        
       let loginManager = LoginManager()
       loginManager.logIn(permissions: ["public_profile", "email"], from: self) { result, error in
           
           if let error = error {
               print("Encountered Erorr: \(error)")
           } else if let result = result, result.isCancelled {
               return
               //print("Cancelled")
           } else {
               self.singIntoFirebase()
               //print("Logged In")
           }
       }
   }
    
    // fetch facebook public fields, name, id, email...
    private func fetchFacebookFields() {
        
        GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start { (_, result, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            if let userData = result as? [String: Any] {
                self.userProfile = UserProfile(data: userData)
                print(self.userProfile?.name ?? "nil")
                self.saveIntoFirebase()
            }
        }
    }
    
    // MARK: - Firebase SDK
    
    private func singIntoFirebase() {
        
        let accessToken = AccessToken.current
        
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        Auth.auth().signIn(with: credentials) { (user, error) in
            
            if let error = error {
                print("Something went wrong with our facebook user: ", error)
                return
            }
            
            print("Successfully logged in with our FB user")
            self.fetchFacebookFields()
        }
    }
    
    private func saveIntoFirebase() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userData = ["name": userProfile?.name, "email": userProfile?.email]
        
        let values = [uid: userData]
        
        Database.database().reference().child("users").updateChildValues(values) { (error, _) in
            
            if let error = error {
                print(error)
                return
            }
            
            print("Successfully saved user into firebase database")
            self.openMainViewController()
        }
    }
    
}

// MARK: - Google SDK

extension LoginViewController {
    
    
   @objc private func signInWithGoogle() {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] (user, error) in
            
            if let error = error {
                print("Failsed to log into Google: ", error)
                return
            }
            
            // data into firebase
            if let userName = user?.profile?.name,
               let userEmail = user?.profile?.email {
                
                let userData = ["name": userName, "email": userEmail]
                userProfile = UserProfile(data: userData)
            }
            
            guard let authentication = user?.authentication,
                  let idToken = authentication.idToken
            else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { (user, error) in
                
                if let error = error {
                    print("Something went wrong with our Google user: ", error)
                    return
                }
                
                print("Successfully logged into Firebase with Google")
                self.saveIntoFirebase()
            }
        }
    }
    
}
