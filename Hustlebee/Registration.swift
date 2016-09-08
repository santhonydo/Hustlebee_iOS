//
//  User.swift
//  Hustlebee
//
//  Created by Anthony Do on 7/4/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import Foundation

struct UserRegistrationInfo {
    static var UserData = [String:AnyObject]()
}

class Registration {
    
    var userData = [String:AnyObject]()
    
    func registerUser(_ completion: ((User?, Error?) -> Void)) {
        let userData = UserRegistrationInfo.UserData
        Request.registerUser(userData as NSDictionary) { data, error in
            if let error = error {
                completion(nil, error)
            } else if let data = data {
                completion(data, nil)
            }
        }
    }
    
    func isWrongData(fieldName: String, fieldData: String) -> Bool {
        switch fieldName {
            case TextFieldName.FirstName:
                if fieldData != "" && isFieldContainsOnly(letters: fieldData) {
                    userData[fieldName] = fieldData as AnyObject
                    return false
                } else {
                    userData[fieldName] = nil
                    return true
                }
            case TextFieldName.LastName:
                if fieldData != "" && isFieldContainsOnly(letters: fieldData) {
                    userData[fieldName] = fieldData as AnyObject
                    return false
                } else {
                    userData[fieldName] = nil
                    return true
                }
            case TextFieldName.PhoneNumber:
                if fieldData != "" && isFieldContainsSeven(values: fieldData) {
                    userData[fieldName] = fieldData as AnyObject
                    return false
                } else {
                    userData[fieldName] = nil
                    return true
                }
            case TextFieldName.CompanyName:
                if fieldData == "" {
                    userData[fieldName] = nil
                    return true
                } else {
                    userData[fieldName] = fieldData as AnyObject
                    return false
                }
            case TextFieldName.LicenseNumber:
                if fieldData == "" || isContainWhiteSpaces(letters: fieldData) {
                    userData[fieldName] = nil
                    return true
                } else {
                    userData[fieldName] = fieldData as AnyObject
                    return false
                }
            case TextFieldName.Email:
                if fieldData != "" && fieldData.isValidEmail {
                    userData[fieldName] = fieldData as AnyObject
                    return false
                } else {
                    userData[fieldName] = nil
                    return true
                }
            case TextFieldName.Password:
                if fieldData != "" && fieldData.isValidPassword {
                    userData[fieldName] = fieldData as AnyObject
                    return false
                } else {
                    userData[fieldName] = nil
                    return true
                }
            case TextFieldName.ConfirmPassword:
                if fieldData != "" && fieldData.isValidPassword && isMatching(confirmPassword: fieldData) {
                    userData[fieldName] = fieldData as AnyObject
                    return false
                } else {
                    userData[fieldName] = nil
                    return true
                }
            default:
                return false
        }
    }
    
    private func isMatching(confirmPassword: String) -> Bool {
        var isTheSamePassword = false
        
        if let password = userData[Registration.TextFieldName.Password] as? String {
            if password == confirmPassword {
                isTheSamePassword = true
            }
        }
        return isTheSamePassword
    }
    
    private func isFieldContainsOnly(letters: String) -> Bool {
        let regex = try? NSRegularExpression(pattern: ".*[^A-Za-z].*", options: .caseInsensitive)
        if (regex?.firstMatch(in: letters, options: .withoutAnchoringBounds, range: NSMakeRange(0, letters.characters.count)) == nil) {
            return true
        } else {
            return false
        }
    }
    
    private func isContainWhiteSpaces(letters: String) -> Bool {
        var isWhiteSpace = true
        (letters.rangeOfCharacter(from: NSCharacterSet.whitespaces) == nil) ? (isWhiteSpace = false) : (isWhiteSpace = true)
        return isWhiteSpace
    }
    
    private func isFieldContainsSeven(values: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: values)
        return result
    }
    
    func isUserDataNil(registrationPage: Int) -> Bool {
        var nilData = true
        
        switch registrationPage {
            case 1:
                if  userData[TextFieldName.FirstName] == nil ||
                    userData[TextFieldName.LastName] == nil ||
                    userData[TextFieldName.PhoneNumber] == nil ||
                    userData[TextFieldName.StateOfLicensure] == nil ||
                    userData[TextFieldName.LicenseNumber] == nil ||
                    userData[TextFieldName.LicenseExpirationDate] == nil
                {
                    nilData = true
                } else if userData[TextFieldName.IsEmployer] as! Bool {
                    (userData[TextFieldName.CompanyName] == nil) ? (nilData = true) : (nilData = false)
                } else {
                    (userData[TextFieldName.Occupation] == nil) ? (nilData = true) : (nilData = false)
            }
            default: break
        }
        
        return nilData
    }
    
    struct ArrayOf {
        static let Occupations = ["Pharmacist", "Physician", "Dentist", "Nurse", "Physician Assistant", "Optometrist"]
        static let States = ["Alabama", "Alaska","Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]
    }
    
    struct TextFieldName {
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let PhoneNumber = "phoneNumber"
        static let Occupation = "occupation"
        static let CompanyName = "companyName"
        static let StateOfLicensure = "stateOfLicensure"
        static let LicenseNumber = "licenseNumber"
        static let LicenseExpirationDate = "licenseExpirationDate"
        static let IsEmployer = "isEmployer"
        static let Email = "email"
        static let Password = "password"
        static let ConfirmPassword = "confirmPassword"
    }
    
    
}
