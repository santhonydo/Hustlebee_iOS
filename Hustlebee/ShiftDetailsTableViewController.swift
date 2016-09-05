//
//  ShiftDetailsTableViewController.swift
//  Hustlebee
//
//  Created by Anthony Do on 8/11/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import UIKit
import MapKit

class ShiftDetailsTableViewController: UITableViewController, MKMapViewDelegate {
    
    var shift: Shift? {
        didSet {
            print("got shift trnasfer")
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
        let alert = UIAlertController(title: Messages.AcceptTitle, message: Messages.AcceptCondition, preferredStyle: UIAlertControllerStyle.alert)
        let acceptAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default) { Void in
            print("assign shift!")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: nil)
        alert.addAction(acceptAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        updateLabels()
        annotateShiftLocation()
        self.title = shift?.user.companyName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.topItem?.title = ""
        if let shiftData = shift {
            self.title = shiftData.user.companyName
        }
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
        mapView.delegate = self
        navigationController?.navigationBar.topItem?.title = ""
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
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
    
    private struct ShiftInfo {
        static let Address = "address"
    }
    
    private struct Messages {
        static let AcceptTitle = "Are you sure?"
        static let AcceptCondition = "By accepting, you agree to show up and to be on time. \n\n Remember to bring your license and photo ID. \n\n We have a 3-strike policy, after which accounts are banned. \n\n - Cancelation or no-show = 1 strike \n\n - Late = 1 strike"
    }

}
