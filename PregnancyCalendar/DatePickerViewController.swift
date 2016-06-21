//
//  DatePickerViewController.swift
//  Календарь беременности
//
//  Created by deck on 13.05.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {

    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var datePicker: UIDatePicker!

    @IBOutlet weak var title_: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title_.titleView?.tintColor = .blackColor()
        navbar.barTintColor = .whiteColor()
        navbar.tintColor = .blackColor()
        datePicker.date = curDate
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Cancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func getDate(sender: UIDatePicker) {
        let Date = sender.date
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: Date)
        components.hour = 00
        components.minute = 00
        components.second = 00
        let newDate = calendar.dateFromComponents(components)
        curDate = newDate!
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
