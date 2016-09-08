//
//  UserShiftTableViewCell.swift
//  Hustlebee
//
//  Created by Anthony Do on 9/6/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import UIKit

class UserShiftTableViewCell: UITableViewCell {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var shiftDate: UILabel!
    
    var shift: Shift? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        
        if let shiftData = shift {
            let shiftStartDateAndTime = shiftData.startDateAndTime
            shiftDate.text = dateFormatter.string(from: shiftStartDateAndTime)
            logo.image = UIImage(named: "hustlebee_logo")
            companyName.text = shiftData.user.companyName
        }
        
    }
}
