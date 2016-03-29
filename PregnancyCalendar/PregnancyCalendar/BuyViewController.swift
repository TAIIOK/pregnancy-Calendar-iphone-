//
//  BuyViewController.swift
//  PregnancyCalendar
//
//  Created by farestz on 28.03.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class Point {
    var tradePoint: String = ""
    var city: String = ""
    var address: String = ""
    var phone: String = ""
    var latitude: Double
    var longitude: Double
    
    init(tradePoint: String, city: String, address: String, phone: String, latitude: Double, longitude: Double) {
        self.tradePoint = tradePoint
        self.city = city
        self.address = address
        self.phone = phone
        self.latitude = latitude
        self.longitude = longitude
    }
    
    internal func getFormattedString() -> NSMutableAttributedString {
        let myMutableString = NSMutableAttributedString(string: tradePoint + "\nАдрес: " + address + "\n", attributes: [NSFontAttributeName:UIFont(name: "Helvetica Neue", size: 13.0)!])
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor(), range: NSRange(location: tradePoint.characters.count + 8,length: address.characters.count))
        return myMutableString
    }
}

class BuyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let customAnnotationViewIdentifier = "MyAnnotation"
    let calloutAnnotationViewIdentifier = "CalloutAnnotation"
    
    let locationManager = CLLocationManager()
    let initialLocation = CLLocationCoordinate2D(latitude: 48.704360, longitude: 44.509449)
    
    var points: [Point] = []
    var nearPoints: [Point] = []
    var locate: [CLLocation] = []

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            mapView.hidden = true
            tableView.hidden = false
        } else {
            mapView.hidden = false
            tableView.hidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSidebarMenu()
        setupModifiedTitle()
        getPointsFromJSON()
        
        mapView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: initialLocation, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        mapView.removeFromSuperview()
        
        points = []
        locate = []
        nearPoints = []
        
        super.viewDidDisappear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupSidebarMenu() {
        if revealViewController() != nil {
            revealViewController().rearViewRevealDisplacement = 0
            revealViewController().rearViewRevealOverdraw = 0
            revealViewController().rearViewRevealWidth = 275
            revealViewController().frontViewShadowRadius = 0
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
        }
    }
    
    private func setupModifiedTitle () {
        let segmentedControl = UISegmentedControl(items: ["Списком", "На карте"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.autoresizingMask = .FlexibleWidth
        segmentedControl.tintColor = .whiteColor()
        segmentedControl.addTarget(self, action: "segmentChanged:", forControlEvents: .ValueChanged)
        navigationItem.titleView = segmentedControl
    }
    
    // json
    private func getPointsFromJSON() {
        // добавить магазин
        points.append(Point(tradePoint: "WILDBERRIES", city: "", address: "", phone: "", latitude: 0, longitude: 0))
        nearPoints.append(points.first!)
        
        // торговые точки из файла
        if let path = NSBundle.mainBundle().pathForResource("points", ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
                let jsonResult = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers) as! NSDictionary
                
                if let points: [NSDictionary] = jsonResult["points"] as? [NSDictionary] {
                    for point: NSDictionary in points {
                        let address = point.valueForKey("address")
                        address!.dataUsingEncoding(NSUTF8StringEncoding)
                        if let uncodingAddress = address {
                            self.points.append(Point(tradePoint: "\(point.valueForKey("trade_point")!)", city: "\(point.valueForKey("city")!)", address: uncodingAddress as! String, phone: "\(point.valueForKey("phone")!)", latitude: point.valueForKey("coord_first_longitude") as! Double, longitude: point.valueForKey("coord_last_latitude") as! Double))
                        }
                    }
                }
            } catch {
                
            }
        }
    }
    
    // map
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        locate = locations
        addPinToMapView()
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is CustomAnnotation {
            var pin = mapView.dequeueReusableAnnotationViewWithIdentifier(customAnnotationViewIdentifier)
            
            if pin == nil {
                pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: customAnnotationViewIdentifier)
                pin?.canShowCallout = false
            } else {
                pin?.annotation = annotation
            }
            
            return pin
        } else if annotation is CalloutAnnotation {
            var pin = mapView.dequeueReusableAnnotationViewWithIdentifier(calloutAnnotationViewIdentifier)
            
            if pin == nil {
                pin = CalloutAnnotationView(annotation: annotation, reuseIdentifier: calloutAnnotationViewIdentifier)
                pin?.canShowCallout = false
            } else {
                pin?.annotation = annotation
            }
            
            return pin
        } else {
            return nil
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let annotation = view.annotation as? CustomAnnotation {
            let calloutAnnotation = CalloutAnnotation(annotation: annotation)
            mapView.addAnnotation(calloutAnnotation)
            
            dispatch_async(dispatch_get_main_queue()) {
                mapView.selectAnnotation(calloutAnnotation, animated: false)
            }
        }
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        if let annotation = view.annotation as? CalloutAnnotation {
            mapView.removeAnnotation(annotation)
        }
    }
    
    private func addPinToMapView() {
        if locate.isEmpty {
            nearPoints = points
            reloadTable()
        } else {
            if nearPoints.count > 1 {
                return
            }
            
            var isFind = false
            for point in points {
                if point.latitude != 0 && point.longitude != 0 {
                    let location = CLLocationCoordinate2DMake(point.latitude, point.longitude)
                    
                    if locate.last?.distanceFromLocation(CLLocation(latitude: point.latitude, longitude: point.longitude)) < 100000 {
                        let annotation = CustomAnnotation()
                        isFind = true
                        annotation.coordinate = location
                        annotation.title = point.tradePoint + "\nАдрес: " + point.address
                        mapView.addAnnotation(annotation)
                        nearPoints.append(point)
                    }
                }
            }
            
            reloadTable()
            
            if !isFind {
                nearPoints = points
                reloadTable()
                
                for point in nearPoints {
                    if point.latitude != 0 && point.longitude != 0 {
                        let location = CLLocationCoordinate2DMake(point.latitude, point.longitude)
                        let annotation = CustomAnnotation()
                        annotation.coordinate = location
                        annotation.title = point.tradePoint + "\nАдрес: " + point.address
                        mapView.addAnnotation(annotation)
                    }
                }
            }
        }
    }

    // table
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearPoints.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if nearPoints[indexPath.row].tradePoint == "WILDBERRIES" {
            let cell = tableView.dequeueReusableCellWithIdentifier("wildBerriesCell", forIndexPath: indexPath) as! WildBerriesTableViewCell
            cell.textLabel?.text = nearPoints[indexPath.row].tradePoint
            cell.textLabel?.textColor = cell.button.backgroundColor
            cell.detailTextLabel?.text = "интернет-магазин"
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("pointsCell", forIndexPath: indexPath)
            cell.textLabel?.attributedText = nearPoints[indexPath.row].getFormattedString()
            return cell
        }
    }
    
    func reloadTable() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
