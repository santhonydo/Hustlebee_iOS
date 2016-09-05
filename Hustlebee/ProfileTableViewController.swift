//
//  ProfileViewController.swift
//  Hustlebee
//
//  Created by Anthony Do on 8/16/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    var user: User!
    
    private var isLoadingShifts = false
    private var networkError: NSError?
    
    override func viewDidLoad() {
        registerCellNibs()
        setupUI()
        loadUserProfile()
    }
    @IBAction func LogOut(_ sender: UIBarButtonItem) {
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
        UserDefaults.standard.set(nil, forKey: "userProfileData")
        UIApplication.shared.delegate?.window??.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
    }
    
    private func loadUserProfile() {
        if let userProfileData = UserDefaults.standard.object(forKey: "userProfileData") as? Data {
            user = NSKeyedUnarchiver.unarchiveObject(with: userProfileData) as! User
        } else {
            print("failed to load user profile data")
        }
    }
    
    private func registerCellNibs() {
        let loadingCellNib = UINib(nibName: CellIdentifier.LoadingTableViewCell, bundle: nil)
        tableView.register(loadingCellNib, forCellReuseIdentifier: CellIdentifier.LoadingTableViewCell)
        let shiftCellNib = UINib(nibName: CellIdentifier.ShiftDetailsTableViewCell, bundle: nil)
        tableView.register(shiftCellNib, forCellReuseIdentifier: CellIdentifier.ShiftDetailsTableViewCell)
        let messageCellNib = UINib(nibName: CellIdentifier.MessageShiftTableViewCell, bundle: nil)
        tableView.register(messageCellNib, forCellReuseIdentifier: CellIdentifier.MessageShiftTableViewCell)
    }
    
    private func setupUI(){
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0 : return 1
            case 1 : return 1
            default: assert(false, "Unexpected Case")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch indexPath.section {
            case 0:
                let profileCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.ProfileCell) as! ProfileTableViewCell
                profileCell.user = self.user
                cell = profileCell
            case 1:
                if isLoadingShifts {
                    let loadingCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.LoadingTableViewCell) as! LoadingTableViewCell
                    loadingCell.activityIndicator.startAnimating()
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    cell = loadingCell
//                } else if let availableShifts = shifts where shifts!.count > 0{
//                    let detailCell = tableView.dequeueReusableCell(withIdentifier: TypesOfCell.ShiftDetailsTableViewCell) as! ShiftDetailsTableViewCell
//                    detailCell.shift = availableShifts[indexPath.row]
//                    detailCell.borderColor = UIColor.clear()
//                    cell = detailCell
                } else {
                    let messageCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.MessageShiftTableViewCell) as! MessageShiftTableViewCell
                    if (networkError != nil){
                        messageCell.message.text = Messages.NetworkError
                    } else {
                        messageCell.message.text = Messages.NoScheduledShifts
                    }
                    
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    cell = messageCell
                }
            default: assert(false, "Unexpected Section")
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            tableView.estimatedRowHeight = CGFloat(220.0)
            return UITableViewAutomaticDimension
        case 1:
            return CGFloat(88.0)
        default:
            assert(false, "Unexpected Height")
        }
    }
    
    // Static Constants
    
    struct CellIdentifier {
        static let ShiftDetailsTableViewCell = "ShiftDetailsTableViewCell"
        static let ProfileCell = "ProfileCell"
        static let LoadingTableViewCell = "LoadingTableViewCell"
        static let MessageShiftTableViewCell = "MessageShiftTableViewCell"
    }
    
    struct Messages {
        static let NetworkError = "Network Error"
        static let NoScheduledShifts = "You have no scheduled shifts."
    }

}
