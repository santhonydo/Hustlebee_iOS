//
//  User.swift
//  Hustlebee
//
//  Created by Anthony Do on 7/28/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding {
    let id: String
    let name: String
    let phoneNumber: String
    let email: String
    let profession: String?
    let state: String
    let licenseNumber: String
    let licenseExpirationDate: String
    let verified: Bool
    let isEmployer: Bool
    let address: [Address]?
    let companyName: String?
    let industry: String?
    let profileImageURL: URL?
    
    override var description: String { return "\(name)\(verified ? " ✅": " 🚫")" }
    
    init?(data: NSDictionary?) {
        guard
            let id = data?.value(forKey: UserInfo.ID) as? String,
            let name = data?.value(forKeyPath: UserInfo.Name) as? String,
            let phoneNumber = data?.value(forKeyPath: UserInfo.Contact.PhoneNumber) as? String,
            let email = data?.value(forKeyPath: UserInfo.Contact.Email) as? String,
            let state = data?.value(forKey: UserInfo.Contact.State) as? String,
            let licenseNumber = data?.value(forKey: UserInfo.License.Number) as? String,
            let licenseExpirationDate = data?.value(forKey: UserInfo.License.ExpirationDate) as? String
        else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.state = state
        self.licenseNumber = licenseNumber
        self.licenseExpirationDate = licenseExpirationDate
        self.profession = data?.value(forKeyPath: UserInfo.Profession) as? String ?? nil
        self.verified = data?.value(forKeyPath: UserInfo.Verified) as! Bool? ?? false
        self.isEmployer = data?.value(forKey: UserInfo.Employer.IsEmployer) as! Bool? ?? false
        self.address = User.addressesFromUserData(data?.value(forKey: UserInfo.Contact.Address) as? NSArray)
        self.companyName = data?.value(forKey: UserInfo.Employer.CompanyName) as? String ?? nil
        self.industry = data?.value(forKeyPath: UserInfo.Employer.Industry) as? String ?? nil
        let urlString = data?.value(forKeyPath: UserInfo.ProfileImageURL) as? String ?? ""
        self.profileImageURL = (urlString.characters.count > 0) ? URL(string: urlString) : nil
    
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        var userData = [String:AnyObject]()
        guard
            let id = aDecoder.decodeObject(forKey: UserInfo.ID) as? String,
            let name = aDecoder.decodeObject(forKey: UserInfo.Name) as? String,
            let phoneNumber = aDecoder.decodeObject(forKey: UserInfo.Contact.PhoneNumber) as? String,
            let email = aDecoder.decodeObject(forKey: UserInfo.Contact.Email) as? String,
            let state = aDecoder.decodeObject(forKey: UserInfo.Contact.State) as? String,
            let licenseNumber = aDecoder.decodeObject(forKey: UserInfo.License.Number) as? String,
            let licenseExpirationDate = aDecoder.decodeObject(forKey: UserInfo.License.ExpirationDate) as? String
        else {
            return nil
        }
        
        userData[UserInfo.ID] = id as AnyObject
        userData[UserInfo.Name] = name as AnyObject
        userData[UserInfo.Contact.PhoneNumber] = phoneNumber as AnyObject
        userData[UserInfo.Contact.Email] = email as AnyObject
        userData[UserInfo.Contact.State] = state as AnyObject
        userData[UserInfo.License.Number] = licenseNumber as AnyObject
        userData[UserInfo.License.ExpirationDate] = licenseExpirationDate as AnyObject
        userData[UserInfo.Profession] = aDecoder.decodeObject(forKey: UserInfo.Profession) as AnyObject
        userData[UserInfo.Verified] = aDecoder.decodeBool(forKey: UserInfo.Verified) as AnyObject
        userData[UserInfo.Employer.IsEmployer] = aDecoder.decodeBool(forKey: UserInfo.Employer.IsEmployer) as AnyObject
        userData[UserInfo.Contact.Address] = aDecoder.decodeObject(forKey: UserInfo.Contact.Address) as AnyObject
        userData[UserInfo.Employer.CompanyName] = aDecoder.decodeObject(forKey: UserInfo.Employer.CompanyName) as AnyObject
        userData[UserInfo.Employer.Industry] = aDecoder.decodeObject(forKey: UserInfo.Employer.Industry) as AnyObject
        userData[UserInfo.ProfileImageURL] = aDecoder.decodeObject(forKey: UserInfo.ProfileImageURL) as AnyObject
        
        self.init(data: userData as NSDictionary?)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: UserInfo.ID)
        aCoder.encode(name, forKey: UserInfo.Name)
        aCoder.encode(phoneNumber, forKey: UserInfo.Contact.PhoneNumber)
        aCoder.encode(email, forKey: UserInfo.Contact.Email)
        aCoder.encode(profession, forKey: UserInfo.Profession)
        aCoder.encode(state, forKey: UserInfo.Contact.State)
        aCoder.encode(licenseNumber, forKey: UserInfo.License.Number)
        aCoder.encode(licenseExpirationDate, forKey: UserInfo.License.ExpirationDate)
        aCoder.encode(verified, forKey: UserInfo.Verified)
        aCoder.encode(isEmployer, forKey: UserInfo.Employer.IsEmployer)
        aCoder.encode(address, forKey: UserInfo.Contact.Address)
        aCoder.encode(companyName, forKey: UserInfo.Employer.CompanyName)
        aCoder.encode(industry, forKey: UserInfo.Employer.Industry)
        aCoder.encode(profileImageURL, forKey: UserInfo.ProfileImageURL)
    
    }
    
    private static func addressesFromUserData(_ userData: NSArray?) -> [Address] {
        var addresses = [Address]()
        for addressItemData in userData ?? [] {
            if let addressItem = Address(data: addressItemData as? NSDictionary) {
                addresses.append(addressItem)
            }
        }
        
        return addresses
    }
    
//    var asPropertyList: AnyObject {
//        return [
//            UserInfo.Name : name,
//            UserInfo.PhoneNumber : phoneNumber,
//            UserInfo.Email : email,
//            UserInfo.Profession : profession,
//            UserInfo.Verified : verified ? "YES" : "NO",
//            UserInfo.IsEmployer : isEmployer ? "YES" : "NO",
//            UserInfo.Industry : (industry?.characters.count > 0) ? industry! : "",
//            UserInfo.ProfileImageURL : profileImageURL?.absoluteString ?? ""
//        
//        ]
//    }
    
    struct UserInfo {
        static let ID = "id"
        static let Name = "name"
        static let Verified = "verified"
        static let ProfileImageURL = "profileImageURL"
        static let Profession = "profession"
    
        struct Employer {
            static let Industry = "Industry"
            static let CompanyName = "companyName"
            static let IsEmployer = "isEmployer"
        }
        
        struct Contact {
            static let PhoneNumber = "phoneNumber"
            static let Email = "email"
            static let State = "state"
            static let Address = "address"
        }
        
        struct License {
            static let state = "stateOfLicensure"
            static let Number = "licenseNumber"
            static let ExpirationDate = "licenseExpirationDate"
        }
    }
}
