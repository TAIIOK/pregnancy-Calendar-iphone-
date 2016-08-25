//
//  PhotoTableViewController.swift
//  PregnancyCalendar
//
//  Created by farestz on 16.03.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit

var choosedSegmentImages = true // true: photo, false: uzi

class PhotoTableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSidebarMenu()
        /*self.view.makeToastActivityWithMessage(message: "Пожалуйста, подождите.", addOverlay: true)
        dispatch_async(dispatch_get_main_queue(), {
            self.loadPhotos()
            self.table.reloadData()
            self.view.hideToastActivity()
            return
        })*/
        
        table.backgroundView = UIImageView(image: UIImage(named: "background.jpg"))
        table.backgroundColor = .clearColor()
        let btnBack = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = btnBack
    }
    
    private func setupSidebarMenu() {
        if self.revealViewController() != nil {
            self.revealViewController().rearViewRevealDisplacement = 0
            self.revealViewController().rearViewRevealOverdraw = 0
            self.revealViewController().rearViewRevealWidth = 275
            self.revealViewController().frontViewShadowRadius = 0
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Мои фото"
            cell.detailTextLabel!.text = "\(photos.count)"
            if photos.count > 0 {
                cell.imageView?.image = photos[0].image
            }
        case 1:
            cell.textLabel?.text = "УЗИ"
            cell.detailTextLabel!.text = "\(uzis.count)"
            if uzis.count > 0 {
                cell.imageView?.image = uzis[0].image
            }
        default:
            break
        }
       
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0{
            choosedSegmentImages = true
        }else{
            choosedSegmentImages = false
        }
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("photo") as? UINavigationController
        self.revealViewController().pushFrontViewController(controller, animated: true)
    }
    
    func loadPhotos(){
        photos.removeAll()
        uzis.removeAll()
        var table = Table("Photo")
        let date = Expression<String>("Date")
        let image = Expression<Blob>("Image")
        let type = Expression<Int64>("Type")
        let text = Expression<String>("Text")
        
        for i in try! db.prepare(table.select(date,image,type,text)) {
            let a = i[image] as! Blob
            let c = NSData(bytes: a.bytes, length: a.bytes.count)
            let b = i[date]
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
            photos.append(Photo(image: UIImage(data: c)!, date: dateFormatter.dateFromString(b)!, text: i[text]))
        }
        
        table = Table("Uzi")
        for i in try! db.prepare(table.select(date,image,type,text)) {
            let a = i[image] as! Blob
            let c = NSData(bytes: a.bytes, length: a.bytes.count)
            let b = i[date]
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
            uzis.append(Photo(image: UIImage(data: c)!, date: dateFormatter.dateFromString(b)!, text: i[text]))
        }
    }
}
