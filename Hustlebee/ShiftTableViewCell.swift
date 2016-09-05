//
//  ShiftTableViewCell.swift
//  Hustlebee
//
//  Created by Anthony Do on 7/17/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import UIKit

class ShiftTableViewCell: UITableViewCell {

    @IBOutlet weak var hourlyRate: UILabel!
    @IBOutlet weak var shiftImage: UIImageView!
    
    var shift: Shift? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI(){
        hourlyRate.text = nil
        shiftImage.image = nil
        
        if let cellData = shift {
            hourlyRate.text = "\(cellData.hourlyRate)/HR"
            shiftImage.image = UIImage(named: "pa")
    
        }
    }

}
