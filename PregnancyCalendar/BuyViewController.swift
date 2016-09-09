//
//  BuyTableViewController.swift
//  rodicalc
//
//  Created by deck on 25.02.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class Points: NSObject {
    var longitude: Double
    var city: String
    var address: String
    var phone: String
    var trade_point: String
    var latitude: Double
    var distance: CLLocationDistance = 0
    
    init(city: String, address: String, trade_point: String, phone: String, longitude: Double, latitude: Double) {
        self.city = city
        self.address = address
        self.trade_point = trade_point
        self.phone = phone
        self.longitude = longitude
        self.latitude = latitude
        super.init()
    }
}

var points: [Points] = []
var nearPoints: [Points] = []


class BuyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var initialLocation = CLLocationCoordinate2D(latitude: 48.704360,
                                                 longitude: 44.509449)
    
    var locate: [CLLocation] = []
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var tbl: UITableView!
    
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionLabel: UILabel!
    @IBOutlet weak var noConnectionImage: UIImageView!
    @IBOutlet weak var noConnectionButton: UIButton!
    
    @IBAction func OpenSite(sender: UIButton) {
        let string = "https://www.wildberries.ru/1.3266.ФЭСТ"
        
       // [NSURL URLWithString:[googlSearchString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        if let url = NSURL(string: string.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!){
            UIApplication.sharedApplication().openURL(url)
        }
    }
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        let status = Reach().connectionStatus()
        switch status {
        case .Unknown, .Offline:
            noConnectionView.backgroundColor = .clearColor()
            noConnectionImage.hidden = false
            noConnectionView.hidden = false
            map.hidden = true
            tbl.hidden = true
            noConnectionLabel.hidden=false
            noConnectionButton.hidden=false
            noConnectionButton.enabled=true
            print("Not connected")
            background.image = UIImage(named: "no_connection_background.png")
        default:
            if sender.selectedSegmentIndex == 0{
                map.hidden = true
                tbl.hidden = false
            }else{
                map.hidden = false
                tbl.hidden = true
            }
            tbl.delegate = self
            tbl.dataSource = self
            map.delegate = self
            background.image = UIImage(named: "background.png")
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadPoints:", name:"loadPoints", object: nil)
            // Ask for Authorisation from the User.
            if #available(iOS 8.0, *) {
                self.locationManager.requestAlwaysAuthorization() //8
                
                
                // For use in foreground
                self.locationManager.requestWhenInUseAuthorization() //8
                
                if CLLocationManager.locationServicesEnabled() {
                    locationManager.delegate = self
                    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    self.map.showsUserLocation = true
                    locationManager.startUpdatingLocation() //8
                    
                    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    let region = MKCoordinateRegion(center: initialLocation, span: span)
                    map.setRegion(region, animated: true)
                    
                    //setCenterOfMapToLocation(initialLocation)
                }
                
            } else {
                // Fallback on earlier versions
            }
            //addPinToMapView()
        }

    }
    
    @IBAction func reconnect(sender: UIButton) {
        check()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbl.backgroundColor = .clearColor()
        self.setupSidebarMenu()
        let img  = UIImage(named: "menu")
        let btn = UIBarButtonItem(image: img , style: UIBarButtonItemStyle.Bordered, target: self.revealViewController(), action: "revealToggle:")
        self.navigationItem.leftBarButtonItem = btn
        noConnectionButton.layer.borderWidth = 2
        noConnectionButton.layer.borderColor = StrawBerryColor.CGColor
        noConnectionButton.layer.cornerRadius = 4
        noConnectionLabel.textColor = UIColor.grayColor()
        check()
    }
    
    func check(){
        let status = Reach().connectionStatus()
        switch status {
        case .Unknown, .Offline:
            noConnectionView.backgroundColor = .clearColor()
            noConnectionImage.hidden = false
            noConnectionView.hidden = false
            map.hidden = true
            tbl.hidden = true
            noConnectionLabel.hidden=false
            noConnectionButton.hidden=false
            noConnectionButton.enabled=true
            print("Not connected")
            background.image = UIImage(named: "no_connection_background.png")
        default:
            map.hidden = true
            tbl.hidden = false
            tbl.delegate = self
            tbl.dataSource = self
            map.delegate = self
            background.image = UIImage(named: "background.png")
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadPoints:", name:"loadPoints", object: nil)
            // Ask for Authorisation from the User.
            if #available(iOS 8.0, *) {
                self.locationManager.requestAlwaysAuthorization() //8
                
                
                // For use in foreground
                self.locationManager.requestWhenInUseAuthorization() //8
                
                if CLLocationManager.locationServicesEnabled() {
                    locationManager.delegate = self
                    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    self.map.showsUserLocation = true
                    locationManager.startUpdatingLocation() //8
                    
                    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    let region = MKCoordinateRegion(center: initialLocation, span: span)
                    map.setRegion(region, animated: true)
                    
                    //setCenterOfMapToLocation(initialLocation)
                }
                
            } else {
                // Fallback on earlier versions
            }
            //addPinToMapView()
        }

    }
    
    private func setupSidebarMenu() {
        if self.revealViewController() != nil {
            self.revealViewController().rearViewRevealDisplacement = 0
            self.revealViewController().rearViewRevealOverdraw = 0
            self.revealViewController().rearViewRevealWidth = 275
            self.revealViewController().frontViewShadowRadius = 0
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
    }
    
    func loadPoints(notification: NSNotification){
        dispatch_async(dispatch_get_main_queue(), {
            self.tbl.reloadData()
            return
        })
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        locate = locations
        addPinToMapView()
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        self.map.setRegion(region, animated: true)
        self.map.showsUserLocation = true
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Errors: " + error.localizedDescription)
    }
    
    /* We have a pin on the map, now zoom into it and make that pin
     the center of the map */
    func setCenterOfMapToLocation(location: CLLocationCoordinate2D){
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
    }
    
    private func addPinToMapView() {
      
        if locate.isEmpty {
            
            nearPoints = points
            updateTable()
        } else {
            if nearPoints.count > 1 {
                return
            }
     
            var isFind = false
            for point in points {
                if point.latitude != 0 && point.longitude != 0 {
                    let location = CLLocationCoordinate2DMake(point.latitude, point.longitude)
                    
                    if locate.last?.distanceFromLocation(CLLocation(latitude: point.latitude, longitude: point.longitude)) < 100000 {
                        point.distance = (locate.last?.distanceFromLocation(CLLocation(latitude: point.latitude, longitude: point.longitude)))!
                        let annotation = CustomAnnotation()
                        isFind = true
                        annotation.coordinate = location
                        annotation.title = point.trade_point + "\nАдрес: " + "\(point.city) " + point.address
                        map.addAnnotation(annotation)
                        
                        nearPoints.append(point)
                        nearPoints = nearPoints.sort({ $0.distance < $1.distance })
                    }
                }
            }
            
            updateTable()
            
            if !isFind {
                nearPoints = points
                updateTable()
                
                for point in nearPoints {
                    if point.latitude != 0 && point.longitude != 0 {
                        let location = CLLocationCoordinate2DMake(point.latitude, point.longitude)
                        let annotation = CustomAnnotation()
                        annotation.coordinate = location
                        annotation.title = point.trade_point + "\nАдрес: " + "\(point.city) " + point.address
                        map.addAnnotation(annotation)
                    }
                }
            }
        }
    }


    func updateTable()
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tbl.reloadData()
        })
    }
    
    
    
    // define annotation view identifiers
    
    let calloutAnnotationViewIdentifier = "CalloutAnnotation"
    let customAnnotationViewIdentifier = "MyAnnotation"
    
    // If `CustomAnnotation`, show standard `MKPinAnnotationView`. If `CalloutAnnotation`, show `CalloutAnnotationView`.
    
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
        }
        
        return nil
    }
    
    // If user selects annotation view for `CustomAnnotation`, then show callout for it. Automatically select
    // that new callout annotation, too.
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let annotation = view.annotation as? CustomAnnotation {
            let calloutAnnotation = CalloutAnnotation(annotation: annotation)
            mapView.addAnnotation(calloutAnnotation)
      
            dispatch_async(dispatch_get_main_queue()) {
                mapView.selectAnnotation(calloutAnnotation, animated: false)
            }
        }
    }
    
    /// If user unselects callout annotation view, then remove it.
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        if let annotation = view.annotation as? CalloutAnnotation {
            mapView.removeAnnotation(annotation)
            
            //mapView.removeAnnotations(mapView.annotations)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
      //  map.removeAnnotations(map.annotations)
      //  map.removeOverlays(map.overlays)
      //  map.removeFromSuperview()
        nearPoints.removeAll()
        nearPoints.insert(Points(city: "",address: "",trade_point: "WILDBERRIES",phone: "",longitude: 0.0,latitude: 0.0), atIndex: 0)

    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return nearPoints.count
    }
    
    func  tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if nearPoints[indexPath.row].trade_point == "WILDBERRIES" {
            let cell = tableView.dequeueReusableCellWithIdentifier("WildCell", forIndexPath: indexPath) as! TableViewCell
            cell.textLabel?.text = "WILDBERRIES"
            cell.detailTextLabel?.text = "интернет-магазин"
            cell.backgroundColor = .clearColor()
            //cell.button.clipsToBounds = true
            //cell.button.layer.cornerRadius = 4
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("MagCell", forIndexPath: indexPath)
            var myMutableString = NSMutableAttributedString()
            var lenghtstring = nearPoints[indexPath.row].address.characters.count
            lenghtstring += nearPoints[indexPath.row].city.characters.count
            lenghtstring += 1
            
            
            
            myMutableString = NSMutableAttributedString(string: nearPoints[indexPath.row].trade_point + "\nАдрес: " + "\(nearPoints[indexPath.row].city)" + " " + nearPoints[indexPath.row].address, attributes: [NSFontAttributeName:UIFont(name: "Helvetica Neue", size: 14.0)!])
            myMutableString.addAttributes([NSFontAttributeName : UIFont.boldSystemFontOfSize(14)], range: NSRange(location: 0,length: nearPoints[indexPath.row].trade_point.characters.count))
            myMutableString.addAttribute(NSForegroundColorAttributeName, value: BiruzaColor1, range: NSRange(location:nearPoints[indexPath.row].trade_point.characters.count+8,length:lenghtstring ))
            cell.textLabel?.attributedText = myMutableString
            cell.backgroundColor = .clearColor()
            return cell
        }
    }
}
