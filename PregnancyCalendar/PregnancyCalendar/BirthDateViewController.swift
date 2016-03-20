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
    
    //Лабели
    @IBOutlet weak var conceptionDateLabel: UILabel!
    @IBOutlet weak var lastMenstrualPeriod: UILabel!
    @IBOutlet weak var setManually: UILabel!
    
    var currentButton = 0
    
    
    // функции календаря
    //функция отмены
    func epCalendarPicker(_: EPCalendarPicker, didCancel error : NSError) {
        
        
    }
    //функция одиночных дат
    func epCalendarPicker(_: EPCalendarPicker, didSelectDate date : NSDate) {
       
        print("ss")
        
        switch currentButton{
        
           case  0: conceptionDateLabel.text = "\(date)";
           lastMenstrualPeriod.text = "не выбрано";
           setManually.text = "не выбрано";
            break
            case  1: lastMenstrualPeriod.text = "\(date)";
             setManually.text = "не выбрано";
            conceptionDateLabel.text = "не выбрано";
            break
           case 2: setManually.text = "\(date)";
           conceptionDateLabel.text = "не выбрано";
           lastMenstrualPeriod.text = "не выбрано";
            break
        default: break
        
        }
        //txtViewDetail.text = "User selected date: \n\(date)"
        
    }
    //функция множественных дат
    func epCalendarPicker(_: EPCalendarPicker, didSelectMultipleDate dates : [NSDate]) {
        switch currentButton{
            
        case  0: conceptionDateLabel.text = "\(dates)";
        lastMenstrualPeriod.text = "не выбрано";
        setManually.text = "не выбрано";
            break
        case  1: lastMenstrualPeriod.text = "\(dates)";
        setManually.text = "не выбрано";
        conceptionDateLabel.text = "не выбрано";
            break
        case 2: setManually.text = "\(dates)";
        conceptionDateLabel.text = "не выбрано";
        lastMenstrualPeriod.text = "не выбрано";
            break
        default: break
            
        }
    }
    
    
    //Кнопки
    @IBAction func setManually(sender: AnyObject) {
       currentButton = 2
        let calendarPicker = EPCalendarPicker(startYear: 2015, endYear: 2017, multiSelection: false, selectedDates: [],window:false)
        calendarPicker.calendarDelegate = self
        calendarPicker.startDate = NSDate()
        calendarPicker.hightlightsToday = true
        calendarPicker.showsTodaysButton = true
        calendarPicker.hideDaysFromOtherMonth = false
        calendarPicker.tintColor = UIColor.orangeColor()
        
        calendarPicker.dayDisabledTintColor = UIColor.grayColor()
        
        
        let navigationController = UINavigationController(rootViewController: calendarPicker)
        self.presentViewController(navigationController, animated: true, completion: nil)
        
    }
    @IBAction func lastMenstrualPeriod(sender: AnyObject) {
        currentButton = 1
        let calendarPicker = EPCalendarPicker(startYear: 2015, endYear: 2017, multiSelection: false, selectedDates: [],window:false)
        calendarPicker.calendarDelegate = self
        calendarPicker.startDate = NSDate()
        calendarPicker.hightlightsToday = true
        calendarPicker.showsTodaysButton = true
        calendarPicker.hideDaysFromOtherMonth = false
        calendarPicker.tintColor = UIColor.orangeColor()
        
        calendarPicker.dayDisabledTintColor = UIColor.grayColor()
        
        
        let navigationController = UINavigationController(rootViewController: calendarPicker)
        self.presentViewController(navigationController, animated: true, completion: nil)
        
    }
    @IBAction func Conceptiondate(sender: AnyObject) {
        currentButton = 0
        let calendarPicker = EPCalendarPicker(startYear: 2015, endYear: 2017, multiSelection: false, selectedDates: [],window:false)
        calendarPicker.calendarDelegate = self
        calendarPicker.startDate = NSDate()
        calendarPicker.hightlightsToday = true
        calendarPicker.showsTodaysButton = true
        calendarPicker.hideDaysFromOtherMonth = false
        calendarPicker.tintColor = UIColor.orangeColor()
        
        calendarPicker.dayDisabledTintColor = UIColor.grayColor()
        
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
    