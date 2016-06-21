//
//  TimeListController.swift
//  Календарь беременности
//
//  Created by deck on 12.05.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit

class TimeListController: UIViewController{

    

    
    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var navbar: UINavigationBar!
    
    let firstComponent = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]
 
    let secondComponent = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //picker.delegate = self
        //picker.dataSource = self
        navbar.barTintColor = .whiteColor()
        navbar.tintColor = .blackColor()
        //setupPickerViewValues()
        // Do any additional setup after loading the view.
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: NSDate())
        components.hour = hour
        components.minute = minute
        components.second = 00
        let newDate = calendar.dateFromComponents(components)
        picker.setDate(newDate!, animated: false)
    }


    
    @IBAction func getTime(sender: UIDatePicker) {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour , .Minute , .Second], fromDate: sender.date)
        hour = components.hour
        minute = components.minute
    }
    /*
     private func setupPickerViewValues() {
     picker.selectRow(minute, inComponent: 1, animated: true)
     picker.selectRow(hour, inComponent: 0, animated: true)
     }
    // MARK: - UIPickerView
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return firstComponent1.count
        } else {
            return secondComponent1.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(firstComponent1[row])"
        } else {
            return "\(secondComponent1[row])"
        }
    }
    
    private func getHourFromPicker() -> Int {
        return firstComponent[picker.selectedRowInComponent(0)]
    }
    
    private func getMinuteFromPicker() -> Int {
        return secondComponent[picker.selectedRowInComponent(1)]
    }
     
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        hour = getHourFromPicker()
        minute = getMinuteFromPicker()
     } */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    override func viewDidDisappear(animated: Bool) {
        //print("did")
        //print(hour,minute)
        //hour = getHourFromPicker()
        //minute = getMinuteFromPicker()
    }
   
    @IBAction func Cancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
