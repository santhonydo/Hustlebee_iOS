//
//  Shift.swift
//  Hustlebee
//
//  Created by Anthony Do on 7/15/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import Foundation

class Shift: NSObject
{
    let user: User
    let id: String
    let address: Address
    let position: String
    let startDateAndTime: Date
    let endDateAndTime: Date
    let hourlyRate: String
    let shiftDescription: String
    let status: Int
    let image: URL?
    
    init?(data: NSDictionary?) {
        guard
            let user = data?.value(forKey: ShiftInfo.User) as? User,
            let id = data?.value(forKey: ShiftInfo.ID) as? String,
            let address = data?.value(forKey: ShiftInfo.Address) as? Address,
            let position = data?.value(forKey: ShiftInfo.Position) as? String,
            let startDateAndTime = data?.value(forKey: ShiftInfo.StartDateAndTime) as? Date,
            let endDateAndTime = data?.value(forKey: ShiftInfo.EndDateAndTime) as? Date,
            let hourlyRate = data?.value(forKey: ShiftInfo.HourlyRate) as? String,
            let shiftDescription = data?.value(forKey: ShiftInfo.ShiftDescription) as? String,
            let shiftStatus = data?.value(forKey: ShiftInfo.Status) as? Int
        else {
            return nil
        }
        
        self.user = user
        self.id = id
        self.address = address
        self.position = position
        self.shiftDescription = shiftDescription
        self.startDateAndTime = startDateAndTime
        self.endDateAndTime = endDateAndTime
        self.hourlyRate = hourlyRate
        self.status = shiftStatus
        let urlString = data?.value(forKeyPath: ShiftInfo.Image) as? String ?? ""
        self.image = (urlString.characters.count > 0) ? URL(string: urlString) : nil
    }
    
    struct ShiftInfo {
        static let User = "user"
        static let ID = "id"
        static let Address = "address"
        static let Position = "position"
        static let StartDateAndTime = "startDateAndTime"
        static let EndDateAndTime = "endDateAndTime"
        static let HourlyRate = "hourlyRate"
        static let Description = "description"
        static let ShiftDescription = "shiftDescription"
        static let Image = "image"
        static let Status = "status"
    }
}
