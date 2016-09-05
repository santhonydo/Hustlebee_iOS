//
//  EmployeeTabBarViewController.swift
//  Hustlebee
//
//  Created by Anthony Do on 7/15/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import UIKit

class WorkersTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

}
