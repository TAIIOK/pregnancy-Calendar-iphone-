//
//  CalendarForExportViewController.swift
//  Календарь беременности
//
//  Created by deck on 23.05.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit

var selectedExportCalendarDay:DayView!
var curMonth = -1

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
    var needupdate = false
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
        self.performSegueWithIdentifier("exportupd", sender: self)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        //selectingDateInCurMonth()
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
        
        let week = Int((calculateDay(selectedExportCalendarDay.date.convertedDate()!))/7)
        /*for i in selectedExportWeek{
         if i.week == week{
         return
         }
         }*/
        let calendar = NSCalendar.currentCalendar()
        var MinDateWeek = NSDate()
        
        var components = calendar.components([.Day , .Month , .Year], fromDate: selectedExportCalendarDay.date.convertedDate()!)
        var NewDate = calendar.dateFromComponents(components)!
        
        var NewWeek = week
        while  week == NewWeek{
            NewWeek = Int((calculateDay(NewDate))/7)
            let NewWeek_ = Double((calculateDay(NewDate)))
            if week == NewWeek{
                MinDateWeek = NewDate
            }
            NewDate = addDaystoGivenDate(NewDate, NumberOfDaysToAdd: -1)
        }
        
        components = calendar.components([.Day , .Month , .Year], fromDate: MinDateWeek)
        components.hour = 00
        components.minute = 00
        components.second = 00
        NewDate = calendar.dateFromComponents(components)!
        
        var daysforsel = [DaysInWeek]()
        var days = [NSDate]()
        
        let controller = calendarView.contentController as! CVCalendarMonthContentViewController
        let temp =  controller.getSelectedDates()
        for (var i = 0; i < 7 ; i += 1){
            days.append(self.addDaystoGivenDate(NewDate, NumberOfDaysToAdd: i))
        }
        var contains = false
        var index = -1
        for var i = 0; i < selectedExportWeek.count; i += 1{
            if selectedExportWeek[i].week == week{
                contains = true
                index = i
            }
        }
        let ExpWeek = ExportWeek(week: week, days: days)
        if contains && index != -1{
            print("remove")
            deselectDays(days)
            selectedExportWeek.removeAtIndex(index)
        }else{
            print("append")
            selectDays(days)
            selectedExportWeek.append(ExpWeek)
        }
    }
    
    func selectDays(days: [NSDate]){
        let controller = calendarView.contentController as! CVCalendarMonthContentViewController
        let a = controller.getSelectedDates()
        for day in days{
            var select = true
            for i in a {
                if i.date.convertedDate()! == day{
                    select = false
                }
            }
            if select {
                if curMonth == CVDate(date: day).month{
                    self.calendarView.selectDate(day)
                }
            }
        }
    }
    
    func deselectDays(days: [NSDate]){
        let controller = calendarView.contentController as! CVCalendarMonthContentViewController
        let a = controller.getSelectedDates()
        var b = [DayView]()
        for i in a{
            for day in days{
                if day == i.date.convertedDate()!{
                    b.append(i)
                }
            }
        }
        controller.deselectDayViews(b)
    }
    
    func selectingDateInCurMonth(){
        if curMonth == -1{
            return
        }
        let controller = calendarView.contentController as! CVCalendarMonthContentViewController
        let a = controller.getSelectedDates()
        var b = [DayView]()
        for i in a{
            b.append(i)
        }
        controller.deselectDayViews(b)
        for i in selectedExportWeek{
            selectDays(i.days)
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
            //let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ExportNav")
            //self.splitViewController?.viewControllers[0] = vc!
            
        }else{
            print("\(dayView.date.commonDescription) date in week is selected!")
            calendarView.coordinator.selection = true
            selectedExportCalendarDay = dayView
            curMonth = selectedExportCalendarDay.date.month
            getWeek()
            //let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ExportNav")
            //self.splitViewController?.viewControllers[0] = vc!
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
        curMonth = components.month
        selectingDateInCurMonth()
        print("Showing Month: \(components.month)")
    }
    
    
    func didShowPreviousMonthView(date: NSDate)
    {
        //        let calendar = NSCalendar.currentCalendar()
        //        let calendarManager = calendarView.manager
        let components = Manager.componentsForDate(date) // from today
        curMonth = components.month
        selectingDateInCurMonth()
        print("Showing Month: \(components.month)")
        let controller = calendarView.contentController as! CVCalendarMonthContentViewController
        print(controller.getSelectedDates())
    }
    
}

