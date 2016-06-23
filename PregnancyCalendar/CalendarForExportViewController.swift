//
//  CalendarForExportViewController.swift
//  Календарь беременности
//
//  Created by deck on 23.05.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit

var selectedExportCalendarDay:DayView!

class DaysInWeek: NSObject {
    var day: NSDate
    var State: Int
    init(State: Int, day: NSDate) {
        self.State = State
        self.day = day
        super.init()
    }
}

class Weeek: NSObject {
    var days: [DaysInWeek]
    var week: Int
    init(week: Int, days: [DaysInWeek]) {
        self.week = week
        self.days = days
        super.init()
    }
}

class CalendarForExportViewController: UIViewController, EPCalendarPickerDelegate {

    
    @IBOutlet weak var testview: UIView!
    @IBOutlet weak var calendar: UIView!
    var multiselecting = false
    
    var days_week = [Weeek]()
    var selectedExportDaysTemp = [NSDate]()
    // функции календаря
    //функция отмены
    func epCalendarPicker(_: EPCalendarPicker, didCancel error : NSError) {
        
        
    }
    //функция одиночных дат
    func epCalendarPicker(_: EPCalendarPicker, didSelectDate date : NSDate) {
        
        print (date)
        
        //txtViewDetail.text = "User selected date: \n\(date)"
        
    }
    //функция множественных дат
    func epCalendarPicker(_: EPCalendarPicker, didSelectMultipleDate dates : [NSDate]) {
        if selectionDateType == 0{
            selectedExportDaysTemp = dates}
    }
    private func setupCalendar() {
        
        let calendarPicker = EPCalendarPicker(startYear: currentyear - 1  , endYear: currentyear + 10, multiSelection: false, selectedDates: [],window: true , scroll: false , scrollDate: NSDate())
        calendarPicker.calendarDelegate = self
        calendarPicker.startDate = NSDate()
        calendarPicker.hightlightsToday = true
        calendarPicker.showsTodaysButton = true
        calendarPicker.tintColor = UIColor.orangeColor()
        calendarPicker.backgroundColor = StrawBerryColor
        calendarPicker.dayDisabledTintColor = UIColor.grayColor()
        calendarPicker.monthTitleColor = UIColor.whiteColor()
        calendarPicker.weekdayTintColor = UIColor.lightGrayColor()
        calendarPicker.weekendTintColor = UIColor.lightGrayColor()
        let navigationController = UINavigationController(rootViewController: calendarPicker)
        testview.clipsToBounds = true
        
        testview.addSubview(navigationController.view)
        self.addChildViewController(navigationController)
        navigationController.didMoveToParentViewController(self)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendar()
        let btn = UIBarButtonItem(title: "Готово", style: .Bordered, target: self.revealViewController(), action: "Done")
        self.navigationItem.rightBarButtonItem = btn
        // Do any additional setup after loading the view.
    }

    func Done(){
        if selectionDateType == 0{
            getDays()
        }else{
            //getWeek()
        }
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDays(){
        selectedExportDays.removeAll()
        selectedExportDays = selectedExportDaysTemp
    }
    
    func getWeek(){
        
        let week = Int((300 - BirthDate.daysFrom(selectedExportCalendarDay.date.convertedDate()!))/7)
        for i in selectedExportWeek{
            if i.week == week{
                return
            }
        }
        let calendar = NSCalendar.currentCalendar()
        var MinDateWeek = NSDate()
        
        var components = calendar.components([.Day , .Month , .Year], fromDate: selectedExportCalendarDay.date.convertedDate()!)
        var NewDate = calendar.dateFromComponents(components)!
        
        var NewWeek = week
        
        while  week == NewWeek{
            components = calendar.components([.Day , .Month , .Year], fromDate: NewDate)
            components.day -= 1
            NewDate = calendar.dateFromComponents(components)!
            NewWeek = Int((300 - BirthDate.daysFrom(NewDate))/7)
            if week == NewWeek{
                MinDateWeek = NewDate
            }
        }
        
        components = calendar.components([.Day , .Month , .Year], fromDate: MinDateWeek)
        components.hour = 00
        components.minute = 00
        components.second = 00
        NewDate = calendar.dateFromComponents(components)!

        //multiselecting = false
        
        var daysforsel = [DaysInWeek]()
        var days = [NSDate]()
        
        var i = 0
        for ( i = 0; i < 7 ; i += 1){
            daysforsel.append(DaysInWeek(State: 0, day: self.addDaystoGivenDate(NewDate, NumberOfDaysToAdd: i)))
            days.append(self.addDaystoGivenDate(NewDate, NumberOfDaysToAdd: i))
        }
        days_week.append(Weeek(week: week, days: daysforsel))
        selectedExportWeek.append(ExportWeek(week: week, days: days))
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
}
