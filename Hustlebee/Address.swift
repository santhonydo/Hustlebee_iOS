//
//  Address.swift
//  Hustlebee
//
//  Created by Anthony Do on 8/4/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import Foundation

class Address: NSObject
{
    let street: String
    let city: String
    let zipcode: Int
    let state: String
    let suite: String
    let longitude: Float?
    let latitude: Float?
    
    override var description: String { return "\(street) \((suite.characters.count > 0) ? suite : "")\n\(city), \(state) \(zipcode)" }
    
    init?(data: NSDictionary?) {
        guard
            let street = data?.value(forKey: AddressInfo.Street) as? String,
            let city = data?.value(forKey: AddressInfo.City) as? String,
            let zipcode = data?.value(forKey: AddressInfo.Zipcode) as? Int,
            let state = data?.value(forKey: AddressInfo.State) as? String
        else {
            return nil
        }
        
        self.street = street
        self.city = city
        self.zipcode = zipcode
        self.state = state
        self.suite = data?.value(forKey: AddressInfo.Suite) as? String ?? ""
        self.longitude = data?.value(forKey: AddressInfo.Longitude) as? Float ?? nil
        self.latitude = data?.value(forKey: AddressInfo.Latitude) as? Float ?? nil
    }
    
    struct AddressInfo {
        static let Street = "street"
        static let Suite = "suite"
        static let City = "city"
        static let Zipcode = "zipcode"
        static let State = "state"
        static let Longitude = "longitude"
        static let Latitude = "latitude"
    }
}
