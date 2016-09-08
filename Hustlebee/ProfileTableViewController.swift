//
//  ProfileViewController.swift
//  Hustlebee
//
//  Created by Anthony Do on 8/16/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController, UserShiftDetailTableViewControllerDelegate {
    
    var user: User! {
        didSet {
            loadUserShifts()
        }
    }
    
    var shifts: [Shift]? {
        didSet {
            refreshControl?.endRefreshing()
            tableView.reloadData()
        }
    }
    
    private var isLoadingShifts = false
    private var networkError: Error? {
        didSet {
            refreshControl?.endRefreshing()
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        registerCellNibs()
        setupUI()
        loadUserProfile()
        loadUserShifts()
        refreshControl?.addTarget(self, action: #selector(refreshShifts), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadUserShifts()
    }
    
    @IBAction func LogOut(_ sender: UIBarButtonItem) {
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
        UserDefaults.standard.set(nil, forKey: "userProfileData")
        UIApplication.shared.delegate?.window??.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
    }
    
    // MARK: - Func
    
    private func loadUserProfile() {
        if let userProfileData = UserDefaults.standard.object(forKey: "userProfileData") as? Data {
            user = NSKeyedUnarchiver.unarchiveObject(with: userProfileData) as! User
        } else {
            print("failed to load user profile data")
        }
    }
    
    @objc private func refreshShifts() {
        loadUserShifts()
        refreshControl?.beginRefreshing()
    }
    
    private func registerCellNibs() {
        let loadingCellNib = UINib(nibName: CellIdentifier.LoadingTableViewCell, bundle: nil)
        tableView.register(loadingCellNib, forCellReuseIdentifier: CellIdentifier.LoadingTableViewCell)
        let shiftCellNib = UINib(nibName: CellIdentifier.ShiftDetailsTableViewCell, bundle: nil)
        tableView.register(shiftCellNib, forCellReuseIdentifier: CellIdentifier.ShiftDetailsTableViewCell)
        let messageCellNib = UINib(nibName: CellIdentifier.MessageShiftTableViewCell, bundle: nil)
        tableView.register(messageCellNib, forCellReuseIdentifier: CellIdentifier.MessageShiftTableViewCell)
        let userShiftCellNib = UINib(nibName: TypesOfCell.UserShiftTableViewCell, bundle: nil)
        tableView.register(userShiftCellNib, forCellReuseIdentifier: TypesOfCell.UserShiftTableViewCell)
    }
    
    private func setupUI(){
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
    }
    
    private func loadUserShifts() {
        isLoadingShifts = true
        DispatchQueue.global(qos: .userInitiated).async { [weak weakSelf = self] in
            Request.loadShifts(nil, nil, weakSelf?.user.id) { shifts, error in
                weakSelf?.isLoadingShifts = false
                DispatchQueue.main.async {
                    if let error = error {
                        weakSelf?.networkError = error
                    } else if let shifts = shifts {
                        var scheduledShifts = [Shift]()
                        for shift in shifts {
                            if (shift.status == 1) {
                                scheduledShifts.append(shift)
                            }
                        }
                        
                        weakSelf?.shifts = scheduledShifts
                    }
                }
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0 :
                return 1
            case 1 :
                let count = (shifts != nil && shifts!.count > 0) ? shifts!.count : 1
                print("what is count: \(count)")
                return count
            default: assert(false, "Unexpected Case")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch indexPath.section {
            case 0:
                let profileCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.ProfileCell) as! ProfileTableViewCell
                profileCell.user = self.user
                profileCell.scheduledShifts.text = (shifts != nil) ? "\(shifts!.count) Scheduled" : "0 Scheduled"
                cell = profileCell
            case 1:
                if isLoadingShifts {
                    let loadingCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.LoadingTableViewCell) as! LoadingTableViewCell
                    loadingCell.activityIndicator.startAnimating()
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    cell = loadingCell
                } else if let availableShifts = shifts, shifts!.count > 0{
                    print("shitfs : \(shifts?.count)")
                    let detailCell = tableView.dequeueReusableCell(withIdentifier: TypesOfCell.UserShiftTableViewCell) as! UserShiftTableViewCell
                    detailCell.shift = availableShifts[indexPath.row]
                    detailCell.borderColor = UIColor.clear
                    cell = detailCell
                } else {
                    print("message cell")
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "UserShiftDetail", sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
            case 0:
                tableView.estimatedRowHeight = CGFloat(220.0)
                return UITableViewAutomaticDimension
           
            default: return UITableViewAutomaticDimension
        }
    }
    
    // Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserShiftDetail" {
            let indexPath = sender as! IndexPath
            let destinationVC = segue.destination as! UserShiftDetailTableViewController
            if let shifts = self.shifts {
                destinationVC.shift = shifts[indexPath.row]
                destinationVC.delegate = self
            }
        }
    }
    
    func userShiftDetailTableViewControllerDidComplete(controller: UserShiftDetailTableViewController, didFinishAddingShift shift: Shift) {
        
    }
    // Static Constants
    
    struct CellIdentifier {
        static let ShiftDetailsTableViewCell = "ShiftDetailsTableViewCell"
        static let ProfileCell = "ProfileCell"
        static let LoadingTableViewCell = "LoadingTableViewCell"
        static let MessageShiftTableViewCell = "MessageShiftTableViewCell"
    }
    
    struct Messages {
        static let NetworkError = "Check your network and try again."
        static let NoScheduledShifts = "You have no scheduled shifts."
    }
    
    private struct TypesOfCell {
        static let ShiftTableSectionHeader = "ShiftTableSectionHeader"
        static let MessageShiftTableViewCell = "MessageShiftTableViewCell"
        static let ShiftDetailsTableViewCell = "ShiftDetailsTableViewCell"
        static let LoadingTableViewCell = "LoadingTableViewCell"
        static let UserShiftTableViewCell = "UserShiftTableViewCell"
        
        struct Identifier {
            static let ShiftCell = "Shift Cell"
            static let ShiftPositionCell = "Shift Position Cell"
            static let ShiftDetailsCell = "Shift Details Cell"
            static let LoadingShiftsCell = "Loading Shifts Cell"
            static let PositionShiftCell = "Position Shift Cell"
        }
    }

}
