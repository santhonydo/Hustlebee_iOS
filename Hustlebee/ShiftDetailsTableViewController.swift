//
//  ShiftDetailsTableViewController.swift
//  Hustlebee
//
//  Created by Anthony Do on 8/11/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import UIKit
import MapKit

protocol ShiftDetailsTableViewControllerDelegate: class {
    func shiftDetailsTableViewControllerDidAccept(controller: ShiftDetailsTableViewController, didFinishAddingShift shift: Shift)
}

class ShiftDetailsTableViewController: UITableViewController, MKMapViewDelegate {
    
    var shift: Shift? {
        didSet {
            print("got shift transfer")
        }
    }
    
    var user: User?
    weak var delegate: ShiftDetailsTableViewControllerDelegate?
    
    var activityIndicator: UIActivityIndicatorView!
    
    var isLoading = false {
        didSet {
            isLoading ? configActivitySpinner(.ON) : configActivitySpinner(.OFF)
        }
    }
    // MARK: - Outlets
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var hourlyRate: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var shiftDescription: UILabel!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Actions
    
    @IBAction func AcceptShift(_ sender: UIBarButtonItem) {
        if (user != nil) {
            let alert = UIAlertController(title: Messages.AcceptTitle, message: Messages.AcceptCondition, preferredStyle: UIAlertControllerStyle.alert)
            let acceptAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default) { [weak weakSelf = self] Void in
                weakSelf?.assignShift()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: nil)
            alert.addAction(acceptAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        } else {
            self.present(UIView.warningAlert(title: "Please Log In", message: "Can't wait for you to start! Log in or create an account to accept shifts."), animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        updateLabels()
        annotateShiftLocation()
        loadUserProfile()
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 150
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    // MARK: - Functions
    
    private func setUpUI() {
        self.title = shift?.user.companyName
        mapView.delegate = self
        navigationController?.navigationBar.topItem?.title = ""
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.center = self.view.center
        view.addSubview(activityIndicator)
    }
    
    private func updateLabels(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy - h:mm a"
        
        if let shiftData = shift {
            startDate.text = dateFormatter.string(from: shiftData.startDateAndTime)
            endDate.text = dateFormatter.string(from: shiftData.endDateAndTime)
            hourlyRate.text = shiftData.hourlyRate
            address.text = shiftData.address.description
            shiftDescription.text = shiftData.shiftDescription
            position.text = shiftData.position
        }
        
    }
    
    private func annotateShiftLocation() {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        var coord = CLLocationCoordinate2D()
        let annotation = MKPointAnnotation()
        if let shift = shift{
            coord = CLLocationCoordinate2DMake(CLLocationDegrees(shift.address.latitude!), CLLocationDegrees(shift.address.longitude!))
            annotation.coordinate = coord
            annotation.title = shift.user.companyName
            annotation.subtitle = shift.position
        }
        let region = MKCoordinateRegionMake(coord, span)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    private func loadUserProfile() {
        if let userProfileData = UserDefaults.standard.object(forKey: "userProfileData") as? Data {
            user = NSKeyedUnarchiver.unarchiveObject(with: userProfileData) as? User
        } else {
            print("failed to load user profile data")
        }
    }
    
    private func assignShift() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async { [weak weakSelf = self] in
            Request.assignShiftTo((weakSelf?.user!.id)!, (weakSelf?.shift!.id)!) { data, error in
                DispatchQueue.main.async {
                    weakSelf?.isLoading = false
                    if let error = error {
                        weakSelf?.present(UIView.warningAlert(title: "Error", message: error.localizedDescription), animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(title: "Success!", message: "The shift is now yours.", preferredStyle: UIAlertControllerStyle.alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { action in
                            _ = weakSelf?.navigationController?.popViewController(animated: true)
                            weakSelf?.delegate?.shiftDetailsTableViewControllerDidAccept(controller: self, didFinishAddingShift: self.shift!)
                        }
                        alert.addAction(okAction)
                        weakSelf?.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    private func configActivitySpinner(_ status: Spinner) {
        switch status {
            case .ON:
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
            case .OFF:
                activityIndicator.isHidden = true
                activityIndicator.stopAnimating()
        }
    }
    
    private enum Spinner {
        case ON
        case OFF
    }
    private struct ShiftInfo {
        static let Address = "address"
    }
    
    private struct Messages {
        static let AcceptTitle = "Are you sure?"
        static let AcceptCondition = "By accepting, you agree to show up and to be on time. \n\n Remember to bring your license and photo ID. \n\n We have a 3-strike policy, after which accounts are banned. \n\n - Cancelation or no-show = 1 strike \n\n - Late = 1 strike"
    }
}
















