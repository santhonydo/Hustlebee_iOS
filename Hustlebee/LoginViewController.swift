//
//  ViewController.swift
//  Hustlebee
//
//  Created by Anthony Do on 7/1/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Model
    private var auth = Auth()
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        isLoading = false
    }
    
    // Mark: - Variables
    
    private var isLoading = false {
        didSet {
            if isLoading {
                startActivityIndicator()
            } else {
                stopActivityIndicator()
            }
        }
    }
    
    private var userEmailAndPassword = ["email": false, "password": false] {
        didSet {
            if let email = userEmailAndPassword["email"], let password = userEmailAndPassword["password"] {
                switch (email, password) {
                    case (false, false):
                        isLoading = false
                        self.present(UIView.warningAlert(title: HustlebeeStrings.AlertStrings.ErrorTitle, message: HustlebeeStrings.AlertStrings.EmailIsInvalid), animated: true, completion: nil)
                    case (true, false):
                        isLoading = false
                        self.present(UIView.warningAlert(title: HustlebeeStrings.AlertStrings.ErrorTitle, message: HustlebeeStrings.AlertStrings.PasswordIsShort), animated: true, completion: nil)
                    case (false, true):
                        isLoading = false
                        self.present(UIView.warningAlert(title: HustlebeeStrings.AlertStrings.ErrorTitle, message: HustlebeeStrings.AlertStrings.EmailIsInvalid), animated: true, completion: nil)
                    case (true, true):
                        signInUser()
                }
            }
        }
    }
    
    // Mark: - Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Mark: - Actions
    
    @IBAction func tapGesture(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            view.endEditing(true)
        }
    }
    
    @IBAction private func forgotPasswordBtn(_ sender: UIButton) {
    }
    
    @IBAction private func registerationBtn(_ sender: UIButton) {
    }
    
    @IBAction private func loginBtn(_ sender: UIButton) {
        userEmailAndPassword = auth.validateUserInputFields(email: emailTextField.text!, password: passwordTextField.text!)
    }
    
    private func signInUser() {
        isLoading = true
        let userEmail = emailTextField.text!
        let userPass = passwordTextField.text!
        DispatchQueue.global(qos: .userInitiated).async{ [weak weakSelf = self] in
            weakSelf?.auth.getUserInfoFromDB(userEmail, userPass) { user, error in
                DispatchQueue.main.async{
                    if let error = error {
                        weakSelf?.isLoading = false
                        weakSelf?.present(UIView.warningAlert(title: "Log In Error", message: error.domain), animated: true, completion: nil)
                    } else if user != nil {
                        UIApplication.shared.delegate?.window??.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                    }
                }
            }
        }
    }
    
    private func startActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}

