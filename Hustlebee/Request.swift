//
//  Request.swift
//  Hustlebee
//
//  Created by Anthony Do on 7/28/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import Foundation

class Request
{
    class func loadAllShifts(_ page: Int, _ toGeoCode: Bool, _ completion: (([Shift]?, NSError?) -> Void)) {
    
        if let shiftsURL = URL(string: HustlebeAPIs.LoginUrl + HustlebeAPIs.AllShifts) {
            let shiftsToGet: [String: AnyObject] = ["skip": page as AnyObject, "toGeoCode": toGeoCode as AnyObject]
            
            self.performRequest(url: shiftsURL, content: shiftsToGet as NSDictionary) { data, error in
                if let error = error {
                    completion(nil, error)
                } else if let data = data {
                    completion(parseShiftsDictionary(dic: data), nil)
                }
            }
        }
    }
    
    class func userAuth(_ email: String, _ password: String, _ completion: @escaping (User?, NSError?) -> Void){
        if let userURL = URL(string: HustlebeAPIs.LoginUrl + HustlebeAPIs.UserAuth) {
            let userToGet = ["email": email, "password": password]
            
            self.performRequest(url: userURL, content: userToGet as NSDictionary) { data, error in
                if let error = error {
                    print("request error: \(error)")
                    completion(nil, error)
                } else if let data = data {
                    var errorMessage: NSError?
                    
                    if data.value(forKey: "noUserFound") != nil || data.value(forKey: "passwordError") != nil {
                        errorMessage = NSError(domain: "Invalid email or password. Please try again.", code: 0, userInfo: nil)
                        completion(nil, errorMessage)
                    } else if data.value(forKey: "logInError") != nil {
                        errorMessage = NSError(domain: "Unknown error. Please try again.", code: 1, userInfo: nil)
                        completion(nil, errorMessage)
                    } else {
                        completion(parseUser(data), nil)
                    }
                    
                }
            }
        }
    }
    
    class func registerUser(_ data: NSDictionary, _ completion: @escaping (User?, NSError?) -> Void){
        if let userRegistrationURL = URL(string: HustlebeAPIs.LoginUrl + HustlebeAPIs.UserRegistration) {
            
            self.performRequest(url: userRegistrationURL, content: data) { data, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                if let data = data {
                    if data.value(forKey: "userExist") != nil {
                        let userExistError = NSError(domain: "userExist", code: 0, userInfo: nil)
                        completion(nil, userExistError)
                    } else {
                        completion(parseUser(data), nil)
                    }
                }
            }
        }
    }
    
    static func performRequest(url: URL, content: NSDictionary, _ completion: @escaping (NSDictionary?, NSError?) -> Void ) {
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let json = try JSONSerialization.data(withJSONObject: content, options: [])
            request.httpBody = json
        } catch let error as NSError {
            completion(nil, error)
        }

        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let dataTask = session.dataTask(with: request as URLRequest) { data, response, error  in
            if let error = error {
                completion(nil, error as NSError?)
            } else if let httpResponse = response as? HTTPURLResponse{
                if httpResponse.statusCode == 200 {
                    if let data = data, let dictionary = self.parseJSON(data: data) {
                        completion(dictionary as NSDictionary?, nil)
                    }
                }
            } else {
                print("failure: \(response)")
            }
        }
        
        dataTask.resume()
    
    }
    
    static func parseJSON(data: Data) -> [String:AnyObject]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    static func parseShiftsDictionary(dic: NSDictionary) -> [Shift] {
        var shifts = [Shift]()
        
        if let results = dic["results"] as? [NSDictionary] {
            for item in results {
                if let shift = parseShift(item) {
                    shifts.append(shift)
                }
            }
            
        }
        
        return shifts
    }
    
    static  func parseShift(_ shift: NSDictionary) -> Shift? {
        var shiftInfo: Shift?

        guard
            let employer = shift.value(forKey: UserInfo.Employer.Employer) as? NSDictionary,
            let addressItem = shift.value(forKey: ShiftInfo.ShiftAddress) as? NSDictionary,
            let id = shift.value(forKey: ShiftInfo._ID) as? String,
            let shiftDate = shift.value(forKey: ShiftInfo.ShiftDate) as? String,
            let startTime = shift.value(forKey: ShiftInfo.StartTime) as? Int,
            let duration = shift.value(forKey: ShiftInfo.Duration) as? Int,
            let position = shift.value(forKey: ShiftInfo.Position) as? String,
            let shiftDateAndTime = parseShiftTime(shiftDate, startTime, duration),
            let startDateAndTime = shiftDateAndTime.value(forKey: ShiftInfo.Start) as? Date,
            let endDateAndTime = shiftDateAndTime.value(forKey: ShiftInfo.End) as? Date,
            let hourlyRate = shift.value(forKey: ShiftInfo.Wage) as? String,
            let shiftDescription = shift.value(forKey: ShiftInfo.Description) as? String
        else {
            return nil
        }
        
        let image = shift.value(forKey: ShiftInfo.Image) as? String ?? ""
        
        if let user = parseUser(employer), let address = parseAddress(addressItem) {
            let newShift: NSDictionary = [
                UserInfo.User : user,
                ShiftInfo.ID : id,
                ShiftInfo.Position : position,
                ShiftInfo.Address.Address : address,
                ShiftInfo.StartDateAndTime : startDateAndTime,
                ShiftInfo.EndDateAndTime : endDateAndTime,
                ShiftInfo.HourlyRate : hourlyRate,
                ShiftInfo.Image : image,
                ShiftInfo.ShiftDescription : shiftDescription
            ]
            
            shiftInfo = Shift(data: newShift)
        }
        
        return shiftInfo
    }
    
    static func parseShiftTime(_ shiftDate: String, _ startTime: Int, _ duration: Int) -> NSDictionary? {
        var shiftDateAndTime = NSDictionary()
        
        let startTimeHr = startTime / 60
        let startTimeMin = startTime % 60
        let minutesToAdd = duration
    
        var startDateAndTimeFormatted: String {
            
            switch (startTimeHr, startTimeMin) {
                case (0..<10, 0..<10) :
                    return shiftDate + " 0\(startTimeHr):0\(startTimeMin)"
                case (0..<10, _) :
                    return shiftDate + " 0\(startTimeHr):\(startTimeMin)"
                case (_, 0..<10) :
                    return shiftDate + " \(startTimeHr):0\(startTimeMin)"
                default:
                    return shiftDate + " \(startTimeHr):\(startTimeMin)"
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        if let newStartDateAndTime = dateFormatter.date(from: startDateAndTimeFormatted) {
            if let endDateAndTime = Calendar.current.date(byAdding: .minute, value: minutesToAdd, to: newStartDateAndTime) {
                shiftDateAndTime = [ShiftInfo.Start : newStartDateAndTime, ShiftInfo.End : endDateAndTime]
            }
        }

        return shiftDateAndTime
    }
    
    static func parseAddress(_ address: NSDictionary) -> Address? {
        guard
            let street = address.value(forKey: ShiftInfo.Address.Street) as? String,
            let city = address.value(forKey: ShiftInfo.Address.City) as? String,
            let state = address.value(forKey: ShiftInfo.Address.State) as? String,
            let zipcode = address.value(forKey: ShiftInfo.Address.Zipcode) as? Int,
            let coordinate = address.value(forKey: ShiftInfo.Address.Coordinate) as? NSDictionary
        else {
            return nil
        }
        
        let suite = address.value(forKey: ShiftInfo.Address.Suite) as? String ?? ""
        
        let longitude = coordinate.value(forKey: ShiftInfo.Address.Longitude) as? Float ?? 0.0
        let latitude = coordinate.value(forKey: ShiftInfo.Address.Latitude) as? Float ?? 0.0
        
        let newAddress: NSDictionary? = [
            ShiftInfo.Address.Street : street,
            ShiftInfo.Address.City : city,
            ShiftInfo.Address.State : state,
            ShiftInfo.Address.Zipcode : zipcode,
            ShiftInfo.Address.Suite : suite,
            ShiftInfo.Address.Longitude : longitude,
            ShiftInfo.Address.Latitude : latitude
        ]
        
        return Address(data: newAddress)
    }
    
    static func parseUser(_ user: NSDictionary) -> User? {
       
        guard
            let id = user.value(forKey: UserInfo._ID) as? String,
            let firstName = user.value(forKey: UserInfo.FirstName) as? String,
            let lastName = user.value(forKey: UserInfo.LastName) as? String,
            let phoneNumber = user.value(forKey: UserInfo.Contact.PhoneNumber) as? String,
            let email = user.value(forKey: UserInfo.Contact.Email) as? String
        else {
            return nil
        }
        
        
        let name = "\(firstName) \(lastName)"
        let state = user.value(forKey: UserInfo.License.State) as? String ?? ""
        let licenseNumber = user.value(forKey: UserInfo.License.Number) as? String ?? ""
        let licenseExpirationDate = user.value(forKey: UserInfo.License.ExpirationDate) as? String ?? ""
        let profession = user.value(forKey: UserInfo.Occupation) as? String ?? ""
        let verified = (user.value(forKey: UserInfo.Employer.Status) as? Bool) ?? false
        let isEmployer = (user.value(forKey: UserInfo.Employer.Employer) as? Bool) ?? false
        let companyName = user.value(forKey: UserInfo.Employer.CompanyName) as? String ?? ""
        let industry = user.value(forKey: UserInfo.Employer.Industry) as? String ?? ""
        let profileImageURL = user.value(forKey: UserInfo.ProfileImageURL) as? String ?? ""
        
        let userData: NSDictionary? = [
            UserInfo.ID : id,
            UserInfo.Name : name,
            UserInfo.Contact.PhoneNumber : phoneNumber,
            UserInfo.Contact.Email : email,
            UserInfo.Contact.State : state,
            UserInfo.License.Number : licenseNumber,
            UserInfo.License.ExpirationDate : licenseExpirationDate,
            UserInfo.Profession : profession,
            UserInfo.Verified : verified,
            UserInfo.Employer.IsEmployer : isEmployer,
            UserInfo.Employer.CompanyName : companyName,
            UserInfo.Employer.Industry : industry,
            UserInfo.ProfileImageURL : profileImageURL
        ]
        
        return User(data: userData)
    }
    
    enum RegistrationError: Error {
        case UserExists
        case Unknown
    }
    
    struct UserInfo {
        static let User = "user"
        static let ID = "id"
        static let _ID = "_id"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Name = "name"
        static let Verified = "verified"
        static let ProfileImageURL = "profileImageURL"
        static let Profession = "profession"
        static let Occupation = "occupation"
        
        struct Employer {
            static let Industry = "Industry"
            static let CompanyName = "companyName"
            static let IsEmployer = "isEmployer"
            static let Status = "status"
            static let Employer = "employer"
        }
        
        struct Contact {
            static let PhoneNumber = "phoneNumber"
            static let Email = "email"
            static let State = "state"
            static let Address = "address"
        }
        
        struct License {
            static let State = "stateOfLicensure"
            static let Number = "licenseNumber"
            static let ExpirationDate = "licenseExpirationDate"
        }
    }
    
    struct ShiftInfo {
        static let ID = "id"
        static let _ID = "_id"
        static let Position = "position"
        static let Description = "description"
        static let ShiftDescription = "shiftDescription"
        static let ShiftDate = "date"
        static let StartTime = "startTime"
        static let Start = "start"
        static let End = "end"
        static let StartDateAndTime = "startDateAndTime"
        static let EndDateAndTime = "endDateAndTime"
        static let Duration = "duration"
        static let ShiftAddress = "shiftAddress"
        static let Image = "image"
        static let Wage = "wage"
        static let HourlyRate = "hourlyRate"
        struct Address {
            static let Coordinate = "coordinate"
            static let Address = "address"
            static let Street = "street"
            static let City = "city"
            static let State = "state"
            static let Zipcode = "zipcode"
            static let Suite = "suite"
            static let Longitude = "longitude"
            static let Latitude = "latitude"
        }
    }

    struct HustlebeAPIs {
        static let LoginUrl = "http://localhost:8888/api/"
        static let AllShifts = "allShifts"
        static let UserAuth = "login"
        static let UserRegistration = "registeration"
    }
}

