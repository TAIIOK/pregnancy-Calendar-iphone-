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

class CalendarForExportViewController: UIViewController {

    var shouldShowDaysOut = true
    var animationFinished = true
    var multiselecting = false
    
    var days_week = [Weeek]()

    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presentedDateUpdated(CVDate(date: NSDate()))
        // Do any additional setup after loading the view.
    }



    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calendarView.backgroundColor = StrawBerryColor
        menuView.backgroundColor = StrawBerryColor
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
        // calendarView.changeMode(.WeekView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        if selectionDateType == 0{
            getDays()
        }else{
            //getWeek()
        }
    }
    
    func getDays()
    {
        selectedExportDays.removeAll()
        let controller = calendarView.contentController as! CVCalendarMonthContentViewController
        let temp =  controller.getSelectedDates()
        var days = [NSDate]()
        for element in temp {
            days.append(addDaystoGivenDate(element.date.convertedDate()!, NumberOfDaysToAdd: 1))
            if selectionDateType == 0 {
                selectedExportDays.append(element.date.convertedDate()!)}
        }
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
        
        let controller = calendarView.contentController as! CVCalendarMonthContentViewController
        let temp =  controller.getSelectedDates()
        var i = 0
        for ( i = 0; i < 7 ; i += 1){
            daysforsel.append(DaysInWeek(State: 0, day: self.addDaystoGivenDate(NewDate, NumberOfDaysToAdd: i)))
            days.append(self.addDaystoGivenDate(NewDate, NumberOfDaysToAdd: i))
        }
        days_week.append(Weeek(week: week, days: daysforsel))
        selectedExportWeek.append(ExportWeek(week: week, days: days))
        for i in daysforsel{
            var select = true
            for element in temp {
                if element.date.convertedDate()! == i.day{
                    select = false
                }
            }
            if select{
                calendarView.toggleViewWithDate(i.day)
            }else{
                for k in days_week{
                    if k.week == week{
                        for j in k.days{
                            if j.day == i.day{
                                j.State = 1
                            }
                        }
                    }
                }
            }
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
}




extension CalendarForExportViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    

    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .Monday
    }
    
    // MARK: Optional methods
    
    func shouldShowWeekdaysOut() -> Bool {
        return shouldShowDaysOut
    }
    func shouldAutoSelectDayOnMonthChange() -> Bool
    {
        return false
    }
    
    
    func shouldAnimateResizing() -> Bool {
        return true // Default value is true
        
    }
    
    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
        if selectionDateType == 0{
            print("\(dayView.date.commonDescription) is selected!")
            calendarView.coordinator.selection = true
            selectedExportCalendarDay = dayView
            getDays()
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ExportNav")
            self.splitViewController?.viewControllers[0] = vc!

        }else{
            let curweek = Int((300 - BirthDate.daysFrom(dayView.date.convertedDate()!))/7)
            var state = 0
            for week in days_week{
                if week.week == curweek{
                    for day in week.days{
                        if day.day == dayView.date.convertedDate()!{
                            if day.State == 0{
                                day.State = 1
                                state = 1
                            }else if day.State == 1{
                                setstate2(curweek, date: dayView.date.convertedDate()!)
                                state = 2
                            }else{
                                state = day.State
                            }
                        }
                    }
                }
            }
            let controller = calendarView.contentController as! CVCalendarMonthContentViewController
            let temp =  controller.getSelectedDates()
            
            if state == 0{
                print("\(dayView.date.commonDescription) is selected!")
                calendarView.coordinator.selection = true
                selectedExportCalendarDay = dayView
                getWeek()
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ExportNav")
                self.splitViewController?.viewControllers[0] = vc!
            }else if state == 2{
                
                setstate3(dayView.date.convertedDate()!, week: curweek)
            }
            remove(curweek)
        }
    }
    
    func setstate2(week: Int, date: NSDate){
        for weeek in days_week{
            if weeek.week == week{
                for day in weeek.days{
                    day.State = 3
                    //if day.day != date{
                        //calendarView.toggleViewWithDate(day.day)}
                }
            }
        }

    }
    func setstate3(date: NSDate, week: Int){
        for weeek in days_week{
            if weeek.week == week{
                for day in weeek.days{
                    if day.day == date{
                        day.State = 3
                    }
                }
            }
        }
        for weeek in days_week{
            if weeek.week == week{
                weeek.days.last?.State = 3
                //calendarView.toggleViewWithDate((weeek.days.last?.day)!)
            }
        }
    }

    
    func remove(week: Int){
        var i = 0
        var state = true
        var ind = -1
        for weeek in days_week{
            if weeek.week == week{
                for day in weeek.days{
                    if day.State != 3{
                        state = false
                        break
                    }
                }
                ind = i
            }
            i += 1
        }
        if state {
            print("DELETE!!!")
            if ind != -1{
                var index = -1
                i = 0
                for j in selectedExportWeek{
                    if j.week == week{
                        index = i
                    }
                    i += 1
                }
                if index != -1{
                    print("remove week")
                    selectedExportWeek.removeAtIndex(index)
                }
                
                let controller = calendarView.contentController as! CVCalendarMonthContentViewController
                var mas = controller.getSelectedDates()
                var days = [DayView]()
                for i in mas{
                    for j in days_week{
                        if j.week == week{
                            for k in j.days{
                                if k.day == i.date.convertedDate()!{
                                    days.append(i)
                                }
                            }
                        }
                    }
                }
                controller.deselectDayViews(days)
                days_week.removeAtIndex(ind)
            }
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ExportNav")
            self.splitViewController?.viewControllers[0] = vc!
        }
    }

    
    
    
    func swipedetected(){
        
        
        
    }
    
    func presentedDateUpdated(date: CVDate) {
        
        if self.title != date.globalDescription && self.animationFinished {
            let updatedMonthLabel = UILabel()
            // updatedMonthLabel.textColor = monthLabel.textColor
            //updatedMonthLabel.font = monthLabel.font
            updatedMonthLabel.textAlignment = .Center
            updatedMonthLabel.text = date.globalDescription
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            
            
            
            switch date.month {
            case 1:
                self.navigationController?.parentViewController?.title = "Январь \(date.year)"
                self.title = "Январь \(date.year)"
                break
            case 2:
                self.navigationController?.parentViewController?.title = "Февраль \(date.year)"
                self.title = "Февраль \(date.year)"
                break
            case 3:
                self.navigationController?.parentViewController?.title = "Март \(date.year)"
                self.title = "Март \(date.year)"
                break
            case 4:
                self.navigationController?.parentViewController?.title = "Апрель \(date.year)"
                self.title = "Апрель \(date.year)"
                break
            case 5:
                self.navigationController?.parentViewController?.title = "Май \(date.year)"
                self.title = "Май \(date.year)"
                break
            case 6:
                self.navigationController?.parentViewController?.title = "Июнь \(date.year)"
                self.title = "Июнь \(date.year)"
                break
            case 7:
                self.navigationController?.parentViewController?.title = "Июль \(date.year)"
                self.title = "Июль \(date.year)"
                break
            case 8:
                self.navigationController?.parentViewController?.title = "Август \(date.year)"
                self.title = "Август \(date.year)"
                break
            case 9:
                self.navigationController?.parentViewController?.title = "Сентябрь \(date.year)"
                self.title = "Сентябрь \(date.year)"
                break
            case 10:
                self.navigationController?.parentViewController?.title = "Октябрь \(date.year)"
                self.title = "Октябрь \(date.year)"
                break
            case 11:
                self.navigationController?.parentViewController?.title = "Ноябрь \(date.year)"
                self.title = "Ноябрь \(date.year)"
                break
            case 12:
                self.navigationController?.parentViewController?.title = "Декабрь \(date.year)"
                self.title = "Декабрь \(date.year)"
                break
            default:
                break
            }
        }
    }
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        let day = dayView.date.day
        let res = ImageFromCalendar.ShowCalendarImages(dayView.date.convertedDate()!)
        if (res.0 || res.1 || res.2)
        {
            return true
        }
        
        
        return false
    }
    
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
        
        var numberOfDots = 0
        
        var colors = [UIColor]()
        
        let res = ImageFromCalendar.ShowCalendarImages(dayView.date.convertedDate()!)
        if (res.0 )
        {
            numberOfDots += 1
            colors.append(UIColor.redColor())
        }
        if (res.1 )
        {
            numberOfDots += 1
            colors.append(UIColor.greenColor())
        }
        if (res.2 )
        {
            numberOfDots += 1
            colors.append(UIColor.blueColor())
        }
        
        return colors
        
    }
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        return false
    }
    
    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        return 13
    }
    
    
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .Short
    }
    
    func selectionViewPath() -> ((CGRect) -> (UIBezierPath)) {
        return { UIBezierPath(rect: CGRectMake(0, 0, $0.width, $0.height)) }
    }
    
    func shouldShowCustomSingleSelection() -> Bool {
        return false
    }
    
    func preliminaryView(viewOnDayView dayView: DayView) -> UIView {
        let circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Circle)
        circleView.fillColor = .colorFromCode(0xCCCCCC)
        return circleView
    }
    
    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        
        if (dayView.isCurrentDay) {
            return true
        }
        return false
    }
    
    func supplementaryView(viewOnDayView dayView: DayView) -> UIView {
        let π = M_PI
        
        let ringSpacing: CGFloat = 3.0
        let ringInsetWidth: CGFloat = 1.0
        let ringVerticalOffset: CGFloat = 1.0
        var ringLayer: CAShapeLayer!
        let ringLineWidth: CGFloat = 4.0
        let ringLineColour: UIColor = .blueColor()
        
        let newView = UIView(frame: dayView.bounds)
        
        let diameter: CGFloat = (newView.bounds.width) - ringSpacing
        let radius: CGFloat = diameter / 2.0
        
        let rect = CGRectMake(newView.frame.midX-radius, newView.frame.midY-radius-ringVerticalOffset, diameter, diameter)
        
        ringLayer = CAShapeLayer()
        newView.layer.addSublayer(ringLayer)
        
        ringLayer.fillColor = nil
        ringLayer.lineWidth = ringLineWidth
        ringLayer.strokeColor = ringLineColour.CGColor
        
        let ringLineWidthInset: CGFloat = CGFloat(ringLineWidth/2.0) + ringInsetWidth
        let ringRect: CGRect = CGRectInset(rect, ringLineWidthInset, ringLineWidthInset)
        let centrePoint: CGPoint = CGPointMake(ringRect.midX, ringRect.midY)
        let startAngle: CGFloat = CGFloat(-π/2.0)
        let endAngle: CGFloat = CGFloat(π * 2.0) + startAngle
        let ringPath: UIBezierPath = UIBezierPath(arcCenter: centrePoint, radius: ringRect.width/2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        ringLayer.path = ringPath.CGPath
        ringLayer.frame = newView.layer.bounds
        
        return newView
    }
    
    func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if (Int(arc4random_uniform(3)) == 1) {
            return false
        }
        
        return false
    }
}


// MARK: - CVCalendarViewAppearanceDelegate

extension CalendarForExportViewController: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
}

// MARK: - IB Actions

extension CalendarForExportViewController {
    @IBAction func switchChanged(sender: UISwitch) {
        if sender.on {
            calendarView.changeDaysOutShowingState(false)
            shouldShowDaysOut = true
        } else {
            calendarView.changeDaysOutShowingState(true)
            shouldShowDaysOut = false
        }
    }
    
    @IBAction func todayMonthView() {
        calendarView.toggleCurrentDayView()
    }
    
    /// Switch to WeekView mode.
    @IBAction func toWeekView(sender: AnyObject) {
        calendarView.changeMode(.WeekView)
    }
    
    /// Switch to MonthView mode.
    @IBAction func toMonthView(sender: AnyObject) {
        calendarView.changeMode(.MonthView)
    }
    
    @IBAction func loadPrevious(sender: AnyObject) {
        calendarView.loadPreviousView()
    }
    
    
    @IBAction func loadNext(sender: AnyObject) {
        calendarView.loadNextView()
    }
}

// MARK: - Convenience API Demo

extension CalendarForExportViewController {
    func toggleMonthViewWithMonthOffset(offset: Int) {
        let calendar = NSCalendar.currentCalendar()
        //        let calendarManager = calendarView.manager
        let components = Manager.componentsForDate(NSDate()) // from today
        
        components.month += offset
        
        let resultDate = calendar.dateFromComponents(components)!
        self.calendarView.toggleViewWithDate(resultDate)
    }
    
    func didShowNextMonthView(date: NSDate)
    {
        //        let calendar = NSCalendar.currentCalendar()
        //        let calendarManager = calendarView.manager
        let components = Manager.componentsForDate(date) // from today
        
        print("Showing Month: \(components.month)")
    }
    
    
    func didShowPreviousMonthView(date: NSDate)
    {
        //        let calendar = NSCalendar.currentCalendar()
        //        let calendarManager = calendarView.manager
        let components = Manager.componentsForDate(date) // from today
        
        print("Showing Month: \(components.month)")
    }
    
}
