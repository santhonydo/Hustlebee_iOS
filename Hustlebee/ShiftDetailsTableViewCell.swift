//
//  ShiftDetailsTableViewCell.swift
//  Hustlebee
//
//  Created by Anthony Do on 7/20/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import UIKit

class ShiftDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var hourlyRate: UILabel!
    @IBOutlet weak var companyLogo: UIImageView!
    
    var shift: Shift? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        if let shiftData = shift {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            dateFormatter.dateFormat = "MMM d, yyyy - h:mm a"
        
            let shiftStartDateAndTime = shiftData.startDateAndTime        
            startDate.text = dateFormatter.string(from: shiftStartDateAndTime)
            position.text = shiftData.position
            companyLogo.image = UIImage(named: "hustlebee_logo")
            hourlyRate.text = shiftData.hourlyRate
            company.text = shiftData.user.companyName
        }
    }
}
