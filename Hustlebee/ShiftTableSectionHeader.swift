//
//  ShiftTableHeaderSection.swift
//  Hustlebee
//
//  Created by Anthony Do on 7/17/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import UIKit

class ShiftTableSectionHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var state: UILabel!
    
    var shift: Shift? {
        didSet {
            updateHeaderUI()
        }
    }
    
    private func updateHeaderUI() {
        if let shiftData = shift {
            companyName.text = shiftData.user.companyName
            logoImage.image = UIImage(named: "hustlebee_logo")
            city.text = "\(shiftData.address.city),"
            state.text = shiftData.address.state
        }
    }
    
    @IBAction func moreInfoBtn(_ sender: UIButton) {
        
    }

}
