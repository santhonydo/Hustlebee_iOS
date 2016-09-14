//
//  ProfileEditTableViewController.swift
//  Hustlebee
//
//  Created by Anthony Do on 9/12/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import UIKit
import MessageUI

protocol ProfileEditTableViewControllerDelegate {
    func profileEditTableViewControllerDidSave(controller: ProfileEditTableViewController)
}
class ProfileEditTableViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MFMailComposeViewControllerDelegate {
    
    var user: User?
    var delegate: ProfileEditTableViewControllerDelegate?
    lazy var datePickerView = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        setUpPickerView()
    }
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var licenseNumber: UILabel!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var licenseExpirationDate: UITextField! { didSet { licenseExpirationDate.delegate = self } }
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var occupation: UILabel!
    
    @IBAction func cancelBtn(_ sender: UIBarButtonItem) {
       self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        email.resignFirstResponder()
        phoneNumber.resignFirstResponder()
        licenseExpirationDate.resignFirstResponder()
    }
    
    
    @IBAction func saveBtn(_ sender: UIBarButtonItem) {
        if !isEmailValid() {
            self.present(UIView.warningAlert(title: "Error", message: "Invalid email address."), animated: true, completion: nil)
        } else if !isPhoneValid() {
            self.present(UIView.warningAlert(title: "Error", message: "Invalid phone number. Please use format xxx-xxx-xxxx."), animated: true, completion: nil)
        } else {
            email.resignFirstResponder()
            phoneNumber.resignFirstResponder()
            licenseExpirationDate.resignFirstResponder()
            updateProfile()
        }
    }
    
    @IBAction func logOutBtn(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
        UserDefaults.standard.set(nil, forKey: "userProfileData")
        UIApplication.shared.delegate?.window??.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
    }
    
    @IBAction func contactBtn(_ sender: UIButton) {
        let messageController = MFMailComposeViewController()
        messageController.mailComposeDelegate = self
        messageController.setSubject("Support")
        messageController.setMessageBody("Feature request or bug report?", isHTML: false)
        messageController.setToRecipients(["support@hustlebee.com"])
        
        self.present(messageController, animated: true, completion: nil)
    }
  
    private func setupUI(){
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
        if let user = self.user {
            name.text = user.name
            licenseNumber.text = user.licenseNumber
            licenseExpirationDate.text = user.licenseExpirationDate
            state.text = user.state
            email.text = user.email
            phoneNumber.text = user.phoneNumber
            occupation.text = user.profession
        }
    }
    
    private func isEmailValid() -> Bool {
        var isValid = false
        if let email = email.text { isValid = email.isValidEmail }
        return isValid
    }
    
    private func isPhoneValid() -> Bool {
        var result = false
        if let phoneNumber = phoneNumber.text {
            let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
            let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
            result =  phoneTest.evaluate(with: phoneNumber)
        }
        return result
    }
    
    private func setUpPickerView() {
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.minimumDate = Date()
        licenseExpirationDate.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(dateDidChange(_:)), for: UIControlEvents.valueChanged)
    }
    
    @objc private func dateDidChange(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        licenseExpirationDate.text = dateFormatter.string(from: sender.date)
    }
    
    private func updateProfile() {
        if let ID = user?.id,
            let currentEmail = user?.email,
            let updatedEmail = self.email.text,
            let phoneNumber = self.phoneNumber.text,
            let licenseExpirationDate = self.licenseExpirationDate.text,
            let firstName = user?.firstName,
            let lastName = user?.lastName
        {
            DispatchQueue.global(qos: .userInitiated).async {
                Request.updateUserProfile(ID, firstName, lastName, currentEmail, updatedEmail, phoneNumber, licenseExpirationDate){ [weak weakSelf = self] user, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            weakSelf?.present(UIView.warningAlert(title: "Error", message: error.localizedDescription), animated: true, completion: nil)
                        } else if let user = user {
                            let encodedUserData = NSKeyedArchiver.archivedData(withRootObject: user)
                            let userDefaults = UserDefaults.standard
                            userDefaults.set(encodedUserData, forKey: "userProfileData")
                            userDefaults.set(true, forKey: "userLoggedIn")
                            userDefaults.synchronize()
                            weakSelf?.delegate?.profileEditTableViewControllerDidSave(controller: self)
                            weakSelf?.dismiss(animated: true, completion: nil)
                        } else {
                            weakSelf?.present(UIView.warningAlert(title: "Unknown Error", message: "Please try again."), animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
    
    // MARK: - Mail Delegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
            case MFMailComposeResult.cancelled.rawValue:
                print("Mail cancelled")
            case MFMailComposeResult.saved.rawValue:
                print("Mail saved")
            case MFMailComposeResult.sent.rawValue:
                print("Mail sent")
            case MFMailComposeResult.failed.rawValue:
                print("Mail sent failure: %@", [error!.localizedDescription])
            default:break
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "uploadID" {
            let destinationVC = segue.destination as! UploadIDViewController
            destinationVC.user = self.user!
        }
    }
}
