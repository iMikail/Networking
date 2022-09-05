//
//  SignInViewController.swift
//  Networking1
//
//  Created by Misha Volkov on 2.09.22.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    lazy var continueButton: UIButton = {
       let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        button.center = CGPoint(x: view.center.x, y: view.frame.height - 100)
        button.backgroundColor = .darkGray
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        return button
    }()
    

   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addVerticalGradientLayer(topColor: .darkGray, bottomColor: .lightGray)
        view.addSubview(continueButton)
        setContinueButton(enabled: false)
        configureTextField()
        
        configureActivityInadicator()
        view.addSubview(activityIndicator)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillAppear),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
    }
    
    fileprivate func configureActivityInadicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .lightGray
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = continueButton.center
    }
    
    private func configureTextField() {
        
        emailTextField.addBottomLine()
        emailTextField.attributedPlaceholder = NSAttributedString(string: "enter email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        passwordTextField.addBottomLine()
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "enter password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        emailTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
    }
    
    @objc private func handleSignIn() {
        
        setContinueButton(enabled: false)
        continueButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text
        else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
            
            guard let self = self else { return }
            
            if let error = error {
                print(error.localizedDescription)
                
                self.setContinueButton(enabled: true)
                self.continueButton.setTitle("Continue", for: .normal)
                self.activityIndicator.stopAnimating()
                
                return
            }
            
            print("Successfully logged into Firebase with User Email")
            self.presentingViewController?.presentingViewController?.dismiss(animated: true)
        }
    }
    
    @objc private func textFieldChanged() {
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text
        else { return }
        
        let formFilled = !email.isEmpty && !password.isEmpty
        
        setContinueButton(enabled: formFilled)
    }
    
    private func setContinueButton(enabled: Bool) {
        
        if enabled {
            continueButton.alpha = 1.0
            continueButton.isEnabled = true
        } else {
            continueButton.alpha = 0.5
            continueButton.isEnabled = false
        }
    }
    
    @objc private func keyboardWillAppear(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        continueButton.center = CGPoint(x: view.center.x,
                                        y: view.frame.height - keyboardFrame.height - 15.0 - continueButton.frame.height / 2)
        activityIndicator.center = continueButton.center
    }
    
    @objc private func keyboardWillHide() {
        
        continueButton.center = CGPoint(x: view.center.x, y: view.frame.height - 100)
        activityIndicator.center = continueButton.center
    }
    
    // hide keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
   
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
