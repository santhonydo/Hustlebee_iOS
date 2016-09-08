//
//  ShiftsTableViewController.swift
//  Hustlebee
//
//  Created by Anthony Do on 7/15/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import UIKit
import CoreLocation

class ShiftsTableViewController: UITableViewController, CLLocationManagerDelegate, ShiftDetailsTableViewControllerDelegate {
    
    var shifts: [Shift]? {
        didSet {
            if let shifts = shifts {
                skipShifts = shifts.count
            }
            isLoadingShifts = false
            tableView.reloadData()
        }
    }
    
    var toGeoCode = false
    var skipShifts = 0
    
    private var isLoadingShifts = false
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocation?
    private var lastLocationError: Error?
    private var networkError: Error? {
        didSet {
            if networkError != nil {
                shifts = nil
            }
            refreshControl?.endRefreshing()
            isLoadingShifts = false
            tableView.reloadData()
        }
    }
    private var isUpdatingLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNibs()
        setUpTableViewUI()
        loadShifts { [weak weakSelf = self] shifts in
            if let shifts = shifts {
                weakSelf?.shifts = shifts
            }
        }
        refreshControl?.addTarget(self, action: #selector(refreshShifts), for: .valueChanged)
        getUserLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = ShiftTypes.All
        //reload data to account for shift acceptant 
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @IBAction func shiftsFilter(_ sender: UIBarButtonItem) {
        let filterAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let allShifts = UIAlertAction(title: ShiftTypes.All, style: .default) { Void in
            print("all shifts clicked")
        }
        
        let nearbyShifts = UIAlertAction(title: ShiftTypes.Nearby, style: .default) { Void in
            self.isLoadingShifts = true
            
            if self.lastLocationError != nil {
                self.isLoadingShifts = false
                self.getUserLocation()
                self.present(UIView.warningAlert(title: TextTitle.LocationError, message: self.lastLocationError!.localizedDescription), animated: true, completion: nil)
                return
            }
            
            if let userLocation = self.userLocation {
                if userLocation.timestamp.timeIntervalSinceNow < -120 {
                    self.getUserLocation()
                } else {
                    self.shifts = nil
                    self.skipShifts = 0
                    self.toGeoCode = true
                    self.loadShifts{ shifts in
                        
                    }
                }
            } else {
                self.getUserLocation()
            }
        }
        
        let cancel = UIAlertAction(title: TextTitle.Cancel, style: .cancel, handler: nil)
        
        filterAlert.addAction(nearbyShifts)
        filterAlert.addAction(allShifts)
        filterAlert.addAction(cancel)
        
        self.present(filterAlert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let shifts = shifts, shifts.count > 0 {
            return shifts.count
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if isLoadingShifts {
            let loadingCell = tableView.dequeueReusableCell(withIdentifier: TypesOfCell.LoadingTableViewCell) as! LoadingTableViewCell
            loadingCell.activityIndicator.startAnimating()
            tableView.separatorStyle = .none
            loadingCell.selectionStyle = UITableViewCellSelectionStyle.none
            cell = loadingCell
        } else if let availableShifts = shifts, shifts!.count > 0{
            let detailCell = tableView.dequeueReusableCell(withIdentifier: TypesOfCell.ShiftDetailsTableViewCell) as! ShiftDetailsTableViewCell
            detailCell.shift = availableShifts[indexPath.row]
            detailCell.borderColor = UIColor.clear
            tableView.separatorStyle = .singleLine
            cell = detailCell
        } else {
            let messageCell = tableView.dequeueReusableCell(withIdentifier: TypesOfCell.MessageShiftTableViewCell) as! MessageShiftTableViewCell
            if (networkError != nil){
                messageCell.message.text = Messages.NetworkError
            } else {
                messageCell.message.text = Messages.NoShiftAvailable
            }
            tableView.separatorStyle = .none
            messageCell.selectionStyle = UITableViewCellSelectionStyle.none
            cell = messageCell
        }
        
        
        return cell
    
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var viewHeight: CGFloat = 44.0
        if let navBarHeight = navigationController?.navigationBar.frame.size.height,
           let tabBarHeight = tabBarController?.tabBar.frame.size.height {
            viewHeight = tableView.frame.size.height - navBarHeight - navBarHeight - tabBarHeight
        }
        if let shifts = shifts, shifts.count < 1 {
            return viewHeight
        } else if isLoadingShifts || (networkError != nil){
            return viewHeight
        } else {
            return 88
        }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let shifts = shifts, shifts.count < 1 {
            return
        }
        
        performSegue(withIdentifier: "ShiftDetailsSegue", sender: indexPath)
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        var headerView: ShiftTableSectionHeader?
//        
//        if let availableShifts = shifts {
//            headerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "ShiftTableSectionHeader") as? ShiftTableSectionHeader
//            headerView!.shift = availableShifts[section]
//            headerView!.contentView.isUserInteractionEnabled = false
//        }
//        
//        return headerView
//    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShiftDetailsSegue" {
            let indexPath = sender as! IndexPath
            let destinationVC = segue.destination as! ShiftDetailsTableViewController
            if let shifts = self.shifts {
                destinationVC.shift = shifts[indexPath.row]
                destinationVC.delegate = self
            }
        }
    }
    
    // MARK: - ShiftDetailsTableViewControllerDelegate
    
    func shiftDetailsTableViewControllerDidAccept(controller: ShiftDetailsTableViewController, didFinishAddingShift shift: Shift) {
        shifts = shifts?.filter(){ $0 !== shift }
        tableView.reloadData()
    }
    
    // MARK: - Functions
    
    private func setUpNibs() {
//        let headerNib = UINib(nibName: TypesOfCell.ShiftTableSectionHeader, bundle: nil)
//        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: TypesOfCell.ShiftTableSectionHeader)
        
        let loadingCellNib = UINib(nibName: TypesOfCell.LoadingTableViewCell, bundle: nil)
        tableView.register(loadingCellNib, forCellReuseIdentifier: TypesOfCell.LoadingTableViewCell)
        
        let messageCellNib = UINib(nibName: TypesOfCell.MessageShiftTableViewCell, bundle: nil)
        tableView.register(messageCellNib, forCellReuseIdentifier: TypesOfCell.MessageShiftTableViewCell)
        
        let shiftCellNib = UINib(nibName: TypesOfCell.ShiftDetailsTableViewCell, bundle: nil)
        tableView.register(shiftCellNib, forCellReuseIdentifier: TypesOfCell.ShiftDetailsTableViewCell)
    }
    
    private func setUpTableViewUI() {
        tableView.estimatedRowHeight = 88.0
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
    }
    
    private func loadShifts(completion: (([Shift]?) -> Void)) {
        if isLoadingShifts { return } else { isLoadingShifts = true }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak weakSelf = self] in
            Request.loadShifts((weakSelf?.skipShifts)!, (weakSelf?.toGeoCode)!, nil) { (shifts, error) in
                weakSelf?.isLoadingShifts = false
                DispatchQueue.main.async {
                    if let error = error {
                        weakSelf?.networkError = error
                    } else {
                        weakSelf?.networkError = nil
                        completion(shifts)
                    }
                }
            }
        }
    }
    
    @objc private func refreshShifts() {
        skipShifts = 0
        loadShifts{ [weak weakSelf = self] shifts in
            weakSelf?.shifts = shifts
            weakSelf?.refreshControl?.endRefreshing()
        }
    }
    
    private func getUserLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if authStatus == .denied || authStatus == .restricted {
            self.present(UIView.warningAlert(title: TextTitle.LocationServicesDisabled, message: Messages.EnableLocationServices), animated: true)
            return
        }
        
        startLocationManager()
    }
    
    // MARK: - Core Location Delegates
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        let errorCode = error as NSError
    
        if errorCode.code == CLError.locationUnknown.rawValue {
            lastLocationError = errorCode
            return
        }
        
        lastLocationError = errorCode
        stopLocationManager()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        if userLocation == nil || userLocation!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            userLocation = newLocation
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                stopLocationManager()
            }
        }
    }
    
    private func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            isUpdatingLocation = true
        }
    }
    
    private func stopLocationManager() {
        if isUpdatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            isUpdatingLocation = false
        }
    }

    
    // MARK: - String Constants
    
    private struct TypesOfCell {
        static let ShiftTableSectionHeader = "ShiftTableSectionHeader"
        static let MessageShiftTableViewCell = "MessageShiftTableViewCell"
        static let ShiftDetailsTableViewCell = "ShiftDetailsTableViewCell"
        static let LoadingTableViewCell = "LoadingTableViewCell"
        
        struct Identifier {
            static let ShiftCell = "Shift Cell"
            static let ShiftPositionCell = "Shift Position Cell"
            static let ShiftDetailsCell = "Shift Details Cell"
            static let LoadingShiftsCell = "Loading Shifts Cell"
            static let PositionShiftCell = "Position Shift Cell"
        }
    }
    
    private struct ShiftTypes {
        static let All = "All Shifts"
        static let Nearby = "Nearby Shifts"
    }
    
    private struct TextTitle {
        static let Cancel = "Cancel"
        static let LocationServicesDisabled = "Location Services Disabled"
        static let LocationError = "Location Error"
    }
    
    private struct Messages {
        static let NoShiftAvailable = "All shifts have been taken. \nCheck out our available jobs."
        static let NetworkError = "Check your network and try again."
        static let UnknownLocation = "Unable to retreive your location. Please try again."
        static let EnableLocationServices = "Please enable location services for this app in Settings."
    }

}
