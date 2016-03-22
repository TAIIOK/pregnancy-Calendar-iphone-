//
//  BirthDateViewController.swift
//  PregnancyCalendar
//
//  Created by farestz on 25.02.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit

class BirthDateViewController: UIViewController, EPCalendarPickerDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var conceptionDateLabel: UILabel!
    @IBOutlet weak var lastMenstrualPeriod: UILabel!
    @IBOutlet weak var setManually: UILabel!
    
    var currentButton = 0
    var arrSelectedDates = [NSDate]()
    
    // КАЛЕНДАРЬ
    func epCalendarPicker(_: EPCalendarPicker, didCancel error : NSError) {
        
        
    }
    func epCalendarPicker(_: EPCalendarPicker, didSelectDate date : NSDate) {
        self.arrSelectedDates.removeAll()
        self.arrSelectedDates.append(date)
        
        switch self.currentButton {
        case 0:
            self.conceptionDateLabel.text = "\(addDaystoGivenDate(date,NumberOfDaysToAdd: +1))"
            self.lastMenstrualPeriod.text = "не выбрано"
            self.setManually.text = "не выбрано"
            break
        case 1:
            self.lastMenstrualPeriod.text = "\(addDaystoGivenDate(date,NumberOfDaysToAdd: +1))"
            self.setManually.text = "не выбрано"
            self.conceptionDateLabel.text = "не выбрано"
            break
        case 2:
            self.setManually.text = "\(addDaystoGivenDate(date,NumberOfDaysToAdd: +1))"
            self.conceptionDateLabel.text = "не выбрано"
            self.lastMenstrualPeriod.text = "не выбрано"
            break
        default:
            break
        }
        
        //txtViewDetail.text = "User selected date: \n\(date)"
    }
    func epCalendarPicker(_: EPCalendarPicker, didSelectMultipleDate dates : [NSDate]) {
        self.arrSelectedDates = dates
        
        switch self.currentButton {
        case 0:
            self.conceptionDateLabel.text = "\(addDaystoGivenDates(dates,NumberOfDaysToAdd: +1))";
            self.lastMenstrualPeriod.text = "не выбрано"
            self.setManually.text = "не выбрано"
            break
        case 1:
            self.lastMenstrualPeriod.text = "\(addDaystoGivenDates(dates,NumberOfDaysToAdd: +1))";
            self.setManually.text = "не выбрано";
            self.conceptionDateLabel.text = "не выбрано";
            break
        case 2:
            self.setManually.text = "\(addDaystoGivenDates(dates,NumberOfDaysToAdd: +1))";
            self.conceptionDateLabel.text = "не выбрано";
            self.lastMenstrualPeriod.text = "не выбрано";
            break
        default:
            break
        }
    }
    
    // ДАТЫ
    @IBAction func setManually(sender: AnyObject) {
        self.currentButton = 2
        
        let calendarPicker = EPCalendarPicker(startYear: currentyear-1, endYear: currentyear + 10, multiSelection: false, selectedDates: arrSelectedDates, window: false)
        calendarPicker.calendarDelegate = self
        calendarPicker.startDate = NSDate()
        //calendarPicker.hightlightsToday = true
        //calendarPicker.showsTodaysButton = true
        calendarPicker.hideDaysFromOtherMonth = false
        
        calendarPicker.backgroundColor = StrawBerryColor
        calendarPicker.dayDisabledTintColor = StrawBerryColor
        calendarPicker.monthTitleColor = UIColor.whiteColor()
        calendarPicker.weekdayTintColor = UIColor.lightGrayColor()
        calendarPicker.weekendTintColor = UIColor.lightGrayColor()
        
        let navigationController = UINavigationController(rootViewController: calendarPicker)
        self.presentViewController(navigationController, animated: true, completion: nil)
        
    }
    @IBAction func lastMenstrualPeriod(sender: AnyObject) {
        self.currentButton = 1
        
        let calendarPicker = EPCalendarPicker(startYear: currentyear-1, endYear: currentyear + 10, multiSelection: false, selectedDates: arrSelectedDates, window: false)
        calendarPicker.calendarDelegate = self
        calendarPicker.startDate = NSDate()
        //calendarPicker.hightlightsToday = true
        //calendarPicker.showsTodaysButton = true
        calendarPicker.hideDaysFromOtherMonth = false
        
        calendarPicker.backgroundColor = StrawBerryColor
        calendarPicker.dayDisabledTintColor = StrawBerryColor
        calendarPicker.monthTitleColor = UIColor.whiteColor()
        calendarPicker.weekdayTintColor = UIColor.lightGrayColor()
        calendarPicker.weekendTintColor = UIColor.lightGrayColor()
        
        let navigationController = UINavigationController(rootViewController: calendarPicker)
        self.presentViewController(navigationController, animated: true, completion: nil)
        
    }
    @IBAction func Conceptiondate(sender: AnyObject) {
        self.currentButton = 0
        
        let calendarPicker = EPCalendarPicker(startYear: currentyear-1, endYear: currentyear + 10, multiSelection: false, selectedDates: arrSelectedDates, window: false)
        calendarPicker.calendarDelegate = self
        calendarPicker.startDate = NSDate()
        //calendarPicker.hightlightsToday = true
        //calendarPicker.showsTodaysButton = true
        calendarPicker.hideDaysFromOtherMonth = false
        
        calendarPicker.backgroundColor = StrawBerryColor
        calendarPicker.dayDisabledTintColor = StrawBerryColor
        calendarPicker.monthTitleColor = UIColor.whiteColor()
        calendarPicker.weekdayTintColor = UIColor.lightGrayColor()
        calendarPicker.weekendTintColor = UIColor.lightGrayColor()
        
        let navigationController = UINavigationController(rootViewController: calendarPicker)
        self.presentViewController(navigationController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSidebarMenu()
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

    
    func addDaystoGivenDate(baseDate: NSDate, NumberOfDaysToAdd: Int) -> NSDate
    {
        let dateComponents = NSDateComponents()
        let CurrentCalendar = NSCalendar.currentCalendar()
        let CalendarOption = NSCalendarOptions()
        
        dateComponents.day = NumberOfDaysToAdd
        
        let newDate = CurrentCalendar.dateByAddingComponents(dateComponents, toDate: baseDate, options: CalendarOption)
        return newDate!
    }
    
    func addDaystoGivenDates(baseDate: [NSDate], NumberOfDaysToAdd: Int) -> [NSDate]
    {
        var newDates = baseDate
        newDates.removeAll()
        let dateComponents = NSDateComponents()
        let CurrentCalendar = NSCalendar.currentCalendar()
        let CalendarOption = NSCalendarOptions()
        for (var i = 0; i<baseDate.count ; i += 1)
        {
        dateComponents.day = NumberOfDaysToAdd
        
        let newDate = CurrentCalendar.dateByAddingComponents(dateComponents, toDate: baseDate[i], options: CalendarOption)
        newDates.insert(newDate!, atIndex: i)
        }
        return newDates
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
    