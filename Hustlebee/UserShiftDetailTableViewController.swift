//
//  UserShiftDetailTableViewController.swift
//  Hustlebee
//
//  Created by Anthony Do on 9/7/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import UIKit
import MapKit

protocol UserShiftDetailTableViewControllerDelegate: class {
    func userShiftDetailTableViewControllerDidComplete(controller: UserShiftDetailTableViewController, didFinishAddingShift shift: Shift)
}

class UserShiftDetailTableViewController: UITableViewController, MKMapViewDelegate{
    
    var shift: Shift?
    
    weak var delegate: UserShiftDetailTableViewControllerDelegate?
    
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var startDateAndTime: UILabel!
    @IBOutlet weak var endDateAndTime: UILabel!
    @IBOutlet weak var hourlyRate: UILabel!
    @IBOutlet weak var descriptionDetail: UILabel!
    @IBOutlet weak var employerName: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var employerEmail: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var mapView: MKMapView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        updateUI()
        annotateShiftLocation()
    }
    @IBAction func doneBtn(_ sender: AnyObject) {
        completeShift()
    }
    
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight:CGFloat = 0.0
        if (indexPath.section == 2 && indexPath.row == 1) {
            rowHeight = 300
        } else {
            rowHeight = UITableViewAutomaticDimension
        }
        return rowHeight
        
    }

    // MARK: - Func
    
    private func updateUI(){
        self.title = shift?.user.companyName
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy - h:mm a"
        
        if let shift = shift {
            position.text = shift.position
            hourlyRate.text = shift.hourlyRate
            startDateAndTime.text = dateFormatter.string(from: shift.startDateAndTime)
            endDateAndTime.text = dateFormatter.string(from: shift.endDateAndTime)
            descriptionDetail.text = shift.shiftDescription
            employerName.text = shift.user.name
            phoneNumber.text = shift.user.phoneNumber
            employerEmail.text = shift.user.email
            address.text = shift.address.description
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
        
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
    
    private func completeShift() {
        let currentDateTime = Date()
        if let shift = shift{
            let shiftEndDateTime = shift.endDateAndTime
            if (currentDateTime.timeIntervalSince(shiftEndDateTime) > 0) {
                print("time expired")
            } else {
                self.present(UIView.warningAlert(title: "Future Shift", message: "You cannot mark shift as completed until the end of your scheduled time.") , animated: true, completion: nil)
            }
        }
    }

}
