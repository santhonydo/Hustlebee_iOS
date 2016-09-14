//
//  ProfileTableViewCell.swift
//  Hustlebee
//
//  Created by Anthony Do on 8/25/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    
    var user: User? {
        didSet {
            updateUI()
        }
    }

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profession: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var scheduledShiftsBtn: UIButton!
    @IBOutlet weak var completedShiftsBtn: UIButton!
   
    private func updateUI() {
        if let user = user {
            name.text = user.description
            profession.text = user.profession
            profileImage.image = UIImage(named: "bee_logo")
        }
    }

}
