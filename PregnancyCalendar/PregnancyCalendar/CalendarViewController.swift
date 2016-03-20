//
//  CalendarViewController.swift
//  PregnancyCalendar
//
//  Created by Roman Efimov on 20.03.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import Foundation
import UIKit


class CalendarViewController: UIViewController, EPCalendarPickerDelegate {
    
  
    
    @IBOutlet weak var menuButton: UIBarButtonItem!

    
    @IBOutlet weak var testview: UIView!

    
    
    // функции календаря
    //функция отмены
    func epCalendarPicker(_: EPCalendarPicker, didCancel error : NSError) {
        
        
    }
    //функция одиночных дат
    func epCalendarPicker(_: EPCalendarPicker, didSelectDate date : NSDate) {
        

        //txtViewDetail.text = "User selected date: \n\(date)"
        
    }
    //функция множественных дат
    func epCalendarPicker(_: EPCalendarPicker, didSelectMultipleDate dates : [NSDate]) {

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSidebarMenu()
        self.setupCalendar()
    }
    
    private func setupCalendar(){
    
        let calendarPicker = EPCalendarPicker(startYear: 2015, endYear: 2017, multiSelection: false, selectedDates: [],window: true)
        calendarPicker.calendarDelegate = self
        calendarPicker.startDate = NSDate()
        calendarPicker.hightlightsToday = true
        calendarPicker.showsTodaysButton = true
        calendarPicker.hideDaysFromOtherMonth = false
        calendarPicker.tintColor = UIColor.orangeColor()
        
        calendarPicker.dayDisabledTintColor = UIColor.grayColor()
        
        
        let navigationController = UINavigationController(rootViewController: calendarPicker)
        
        testview.clipsToBounds = true
        
        testview.addSubview(navigationController.view)
        self.addChildViewController(navigationController)
        navigationController.didMoveToParentViewController(self)
        
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
    