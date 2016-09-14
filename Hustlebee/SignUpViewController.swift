//
//  SignUpViewController.swift
//  Hustlebee
//
//  Created by Anthony Do on 7/4/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Model
    let registration = Registration()

    // MARK: - UIView Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTextFieldTargetAction()
        if registrationPage == 1 {
            showEmployeeTextFields()
            setUpPickerView()
            nextBtn.changeBtnStateTo(enabled: false)
            UserRegistrationInfo.UserData[Registration.TextFieldName.IsEmployer] = false as AnyObject
        } else {
            hideActivityIndicator()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if registrationPage == 1 {
            registerKeyboardNotifications()
        } else if registrationPage == 2 {
            self.title = "Almost there..."
            self.navigationController?.navigationBar.topItem?.title = ""
            self.navigationController?.navigationBar.tintColor = UIColor.yellowTheme()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unregisterKeyboardNotifications()
    }
    
    
    // MARK: Variables
    private var activeTextField: UITextField!
    lazy var itemPickerView = UIPickerView()
    lazy var datePickerView = UIDatePicker()
    private var registrationPage = Int()
    private var isLoading = false {
        didSet {
            if isLoading {
                showActivityIndicator()
            } else {
                hideActivityIndicator()
            }
        }
    }

    
    // MARK: - Outlets
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstName: UITextField! { didSet { firstName.delegate = self; registrationPage = 1 } }
    @IBOutlet weak var lastName: UITextField! { didSet { lastName.delegate = self } }
    @IBOutlet weak var state: UITextField! { didSet { state.delegate = self } }
    @IBOutlet weak var phone: UITextField! { didSet { phone.delegate = self } }
    @IBOutlet weak var occupation: UITextField! { didSet { occupation.delegate = self } }
    @IBOutlet weak var companyName: UITextField! { didSet { companyName.delegate = self } }
    @IBOutlet weak var licenseNumber: UITextField! { didSet { licenseNumber.delegate = self } }
    @IBOutlet weak var licenseExpirationDate: UITextField! { didSet { licenseExpirationDate.delegate = self } }
    @IBOutlet weak var email: UITextField! { didSet { email.delegate = self; registrationPage = 2} }
    @IBOutlet weak var password: UITextField! { didSet {password.delegate = self} }
    @IBOutlet weak var confirmPassword: UITextField! { didSet {confirmPassword.delegate = self} }
    @IBOutlet weak var nextBtn: UIButton!
    
    // MARK: - Action Controller
    
    @IBAction func userType(_ sender: UISegmentedControl) {
        activeTextField?.resignFirstResponder()
        switch sender.selectedSegmentIndex {
            case 0 :
                companyName.text = ""
                nextBtn.changeBtnStateTo(enabled: false)
                showEmployeeTextFields()
                UserRegistrationInfo.UserData[Registration.TextFieldName.IsEmployer] = false as AnyObject
            case 1 :
                occupation.text = ""
                nextBtn.changeBtnStateTo(enabled: false)
                showEmployerTextFields()
                UserRegistrationInfo.UserData[Registration.TextFieldName.IsEmployer] = true as AnyObject
            default : assert(false, "Unexpected Segment Index")
        }
    }
    
    @IBAction func cancelSignUpBtn(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        activeTextField?.resignFirstResponder()
    }
    @IBAction func nextBtnAction(_ sender: UIButton) {
        UserRegistrationInfo.UserData = registration.userData
    }
    
    
    @IBAction func signUpBtn(_ sender: UIButton) {
        isLoading = true
        if registration.userData[Registration.TextFieldName.Email] == nil {
            isLoading = false
           self.present(UIView.warningAlert(title: HustlebeeStrings.AlertStrings.ErrorTitle, message: HustlebeeStrings.AlertStrings.EmailIsInvalid), animated: true, completion: nil)
        } else if registration.userData[Registration.TextFieldName.Password] == nil || registration.userData[Registration.TextFieldName.ConfirmPassword] == nil {
            isLoading = false
            self.present(UIView.warningAlert(title: HustlebeeStrings.AlertStrings.ErrorTitle, message: HustlebeeStrings.AlertStrings.PasswordIsInvalid), animated: true, completion: nil)
        } else {
            let password = registration.userData[Registration.TextFieldName.Password] as? String
            let confirmPassword = registration.userData[Registration.TextFieldName.ConfirmPassword] as? String
            if password == confirmPassword {
                registerUser()
            } else {
                isLoading = false
                self.present(UIView.warningAlert(title: HustlebeeStrings.AlertStrings.ErrorTitle, message: HustlebeeStrings.AlertStrings.PasswordDoNotMatch), animated: true, completion: nil)
            }
        }
    }
    
    
    // MARK: - Functions
    
    private func registerUser() {
        for key in registration.userData.keys {
            UserRegistrationInfo.UserData[key] = registration.userData[key]
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak weakSelf = self] in
            weakSelf?.registration.registerUser() { data, error in
                DispatchQueue.main.async{
                    weakSelf?.isLoading = false
                    if let error = error {
                        if error._domain == "userExist" {
                            weakSelf?.present(UIView.warningAlert(title: "Account Already Exist", message: "Please try again using a different email address."), animated: true, completion: nil)
                        }
                    } else if data != nil {
                        UserDefaults.standard.set(true, forKey: "userLoggedIn")
                        let appDelegate = UIApplication.shared.delegate
                        appDelegate?.window??.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                    } else {
                        weakSelf?.present(UIView.warningAlert(title: "Unknown Error", message: "Please try again."), animated: true, completion: nil)
                    }
                }
            }
        }

    }
    
    private func showActivityIndicator() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }
    
    private func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    private func setUpPickerView() {
        itemPickerView.delegate = self
        itemPickerView.dataSource = self
        occupation.inputView = itemPickerView
        state.inputView = itemPickerView
        
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
        registration.userData[Registration.TextFieldName.LicenseExpirationDate] = licenseExpirationDate.text as AnyObject
    }
    
    private func showEmployerTextFields() {
        companyName.isHidden = false
        occupation.isHidden = true
        registration.userData[Registration.TextFieldName.IsEmployer] = true as AnyObject
    }
    
    private func showEmployeeTextFields() {
        companyName.isHidden = true
        occupation.isHidden = false
        registration.userData[Registration.TextFieldName.IsEmployer] = false as AnyObject
    }
    
    private func addTextFieldTargetAction() {
        if registrationPage == 1 {
            firstName.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: UIControlEvents.editingChanged)
            lastName.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: UIControlEvents.editingChanged)
            phone.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: UIControlEvents.editingChanged)
            occupation.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: UIControlEvents.editingChanged)
            companyName.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: UIControlEvents.editingChanged)
            state.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: UIControlEvents.editingChanged)
            licenseNumber.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: UIControlEvents.editingChanged)
        } else {
            email.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: UIControlEvents.editingChanged)
            password.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: UIControlEvents.editingChanged)
            confirmPassword.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: UIControlEvents.editingChanged)
        }
    }
    
    private func shouldEnableOrDisableNextBtn(page: Int) {
        if page == 1 {
            let trueOrFalse = registration.isUserDataNil(registrationPage: page)
            nextBtn.changeBtnStateTo(enabled: !trueOrFalse)
        }
    }
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardDidShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (userInfo.object(forKey: UIKeyboardFrameBeginUserInfoKey)! as AnyObject).cgRectValue.size
        let contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var viewRect = view.frame
        viewRect.size.height -= keyboardSize.height
        
        if (!viewRect.contains(activeTextField.frame.origin)) {
            scrollView.scrollRectToVisible(activeTextField.frame, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(notificaton: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    // MARK: - UITextFieldDelegates
    
    @objc private func textFieldDidChanged(_ textField: UITextField){
        if let textData = activeTextField {
            switch textField.tag {
            case 0:
                !registration.isWrongData(fieldName: Registration.TextFieldName.FirstName, fieldData: textData.text!) ? (activeTextField.textColor = UIColor.black) : (activeTextField.textColor = UIColor.red)
            case 1:
                !registration.isWrongData(fieldName: Registration.TextFieldName.LastName, fieldData: textData.text!) ? (activeTextField.textColor = UIColor.black) : (activeTextField.textColor = UIColor.red)
            case 2:
                !registration.isWrongData(fieldName: Registration.TextFieldName.PhoneNumber, fieldData: textData.text!) ? (activeTextField.textColor = UIColor.black) : (activeTextField.textColor = UIColor.red)
            case 4:
                if !registration.isWrongData(fieldName: Registration.TextFieldName.CompanyName, fieldData: textData.text!){
                    activeTextField.textColor = UIColor.black
                }
            case 6:
                !registration.isWrongData(fieldName: Registration.TextFieldName.LicenseNumber, fieldData: textData.text!) ? (activeTextField.textColor = UIColor.black) : (activeTextField.textColor = UIColor.red)
            case 8:
                !registration.isWrongData(fieldName: Registration.TextFieldName.Email, fieldData: textData.text!) ? (activeTextField.textColor = UIColor.black) : (activeTextField.textColor = UIColor.red)
            case 9:
                !registration.isWrongData(fieldName: Registration.TextFieldName.Password, fieldData: textData.text!) ? (activeTextField.textColor = UIColor.black) : (activeTextField.textColor = UIColor.red)
            case 10:
                !registration.isWrongData(fieldName: Registration.TextFieldName.ConfirmPassword, fieldData: textData.text!) ? (activeTextField.textColor = UIColor.black) : (activeTextField.textColor = UIColor.red)
            default:
                break
            }
        }
        
        shouldEnableOrDisableNextBtn(page: registrationPage)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        if activeTextField.tag == 3 || activeTextField.tag == 5 || activeTextField.tag == 7{
            itemPickerView.reloadAllComponents()
        }
        shouldEnableOrDisableNextBtn(page: registrationPage)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        shouldEnableOrDisableNextBtn(page: registrationPage)
        activeTextField = nil
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if activeTextField.tag == 3 || activeTextField.tag == 5 || activeTextField.tag == 7 {
            return false
        } else {
            return true
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField.tag {
            case 8:
                registration.userData[Registration.TextFieldName.Email] = nil
            case 9:
                registration.userData[Registration.TextFieldName.Password] = nil
            case 10:
                registration.userData[Registration.TextFieldName.ConfirmPassword] = nil
            default:
                    break
        }
        return true
    }
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRows = 0
        
        if let tf = activeTextField {
            switch tf.tag {
            case 3:
                numberOfRows = Registration.ArrayOf.Occupations.count
            case 5:
                numberOfRows = Registration.ArrayOf.States.count
            default:
                numberOfRows = 0
            }
        }
        
        return numberOfRows
    }
    
    // MARK: - UIPickerViewDelegates
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var rowData: String?
        
        if let tf = activeTextField {
            switch tf.tag {
            case 3:
                rowData = Registration.ArrayOf.Occupations[row]
            case 5:
                rowData = Registration.ArrayOf.States[row]
            default:
                rowData = nil
            }
        }
        
        return rowData
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if let tf = activeTextField {
            switch tf.tag {
            case 3:
                occupation.text = Registration.ArrayOf.Occupations[row]
                registration.userData[Registration.TextFieldName.Occupation] = Registration.ArrayOf.Occupations[row] as AnyObject
            case 5:
                state.text = Registration.ArrayOf.States[row]
                registration.userData[Registration.TextFieldName.StateOfLicensure] = Registration.ArrayOf.States[row] as AnyObject
            default: break
            }
        }
        
    }
}
