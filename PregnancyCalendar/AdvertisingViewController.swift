//
//  AdvertisingViewController.swift
//  Календарь беременности
//
//  Created by deck on 16.05.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit

var isAdvertitsing = false
var noteText = ["",""]
var selectedDay:DayView!
class AdvertisingViewController: UIViewController {
    

    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var label: UILabel!
    
    var shouldShowDaysOut = true
    var animationFinished = true
    //var db = try! Connection()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isAdvertitsing{
            textView.text = noteText[1]
            textView.textColor = BiruzaColor1
            textView.font = .systemFontOfSize(16)
            label.text = noteText[0]
            label.textColor = StrawBerryColor
            label.font = .systemFontOfSize(16)
        }

        var tmp = NSDate()
        if opennotifi{
            tmp = dateFromOpenNotifi
        }else if selectedExperienceDay != nil {
            tmp = selectedExperienceDay.date.convertedDate()!
        }
        self.presentedDateUpdated(CVDate(date: tmp))
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
        var tmp = NSDate()
        if opennotifi{
            opennotifi = false
            tmp = dateFromOpenNotifi
        }else if selectedExperienceDay != nil{
            tmp = selectedExperienceDay.date.convertedDate()!
        }
        var date = CVDate(date: tmp)
        let controller = calendarView.contentController as! CVCalendarWeekContentViewController
        controller.selectDayViewWithDay(date.day, inWeekView: controller.getPresentedWeek()!)
        self.calendarView.toggleViewWithDate(tmp)
    }
    
    func notifiFromDate(date: NSDate){
        let day = calculateDay(date)
        var cat = -1
        for i in 0..<notifiCategory.count{
            if notifiCategory[i] == noteText[0]{
                cat = i
            }
        }
        var find = false
        let table = Table("Notification")
        let Day = Expression<Int64>("Day")
        let Category = Expression<Int64>("CategoryId")
        let Text = Expression<String>("Text")
        for tmp in try! db.prepare(table.select(Category, Text).filter(Category == Int64(cat+1) && Day == Int64(day))){
            noteText[1] = tmp[Text]
            find = true
        }
        if find{
            textView.text = noteText[1]
            label.text = noteText[0]
        }else{
            textView.text = "Нет уведомления на этот день"
        }
        textView.textColor = BiruzaColor1
        textView.font = .systemFontOfSize(16)
        label.textColor = StrawBerryColor
        label.font = .systemFontOfSize(16)
    }

    override func viewDidDisappear(animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension AdvertisingViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .WeekView
    }
    
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .Monday
    }
    
    // MARK: Optional methods
    
    func shouldShowWeekdaysOut() -> Bool {
        return shouldShowDaysOut
    }
    
    func shouldAnimateResizing() -> Bool {
        return true // Default value is true
    }
    
    func shouldAutoSelectDayOnWeekChange() -> Bool
    {
        return true
    }
    
    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("\(dayView.date.commonDescription) is selected!")
        selectedExperienceDay = dayView
        notifiFromDate(selectedExperienceDay.date.convertedDate()!)
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

extension AdvertisingViewController: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
}

// MARK: - IB Actions

extension AdvertisingViewController {
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

extension AdvertisingViewController {
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
