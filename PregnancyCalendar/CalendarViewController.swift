//
//  CalendarTableViewController.swift
//  rodicalc
//
//  Created by deck on 25.02.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit
import CoreData

var selectedCalendarDay: DayView!
class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, EPCalendarPickerDelegate {

    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var tbl: UITableView!
    @IBOutlet weak var calendarView: CVCalendarView!
    var shouldShowDaysOut = true
    var animationFinished = true
    var BirthDate = NSDate()
    var day: Int = 0
    /*let calendarPicker = EPCalendarPicker(startYear: currentyear - 1  , endYear: currentyear + 10, multiSelection: false, selectedDates: [],window: true , scroll: false , scrollDate: NSDate())
    // функции календаря
    //функция отмены
    func epCalendarPicker(_: EPCalendarPicker, didCancel error : NSError) {
        
        
    }
    //функция одиночных дат
    func epCalendarPicker(_: EPCalendarPicker, didSelectDate date : NSDate) {
        
        print (date)
        selectedCalendarDate = date
        tbl.reloadData()
        //txtViewDetail.text = "User selected date: \n\(date)"
    }
    //функция множественных дат
    func epCalendarPicker(_: EPCalendarPicker, didSelectMultipleDate dates : [NSDate]) {
        
        print (dates)
    }*/

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDate()
        self.presentedDateUpdated(CVDate(date: NSDate()))
        self.setupSidebarMenu()
        //self.setupCalendar()
        let img  = UIImage(named: "menu")
        let btn = UIBarButtonItem(image: img , style: UIBarButtonItemStyle.Bordered, target: self.revealViewController(), action: "revealToggle:")
        self.navigationItem.leftBarButtonItem = btn
        let btnBack = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = btnBack
        tbl.delegate = self
        tbl.dataSource = self
        tbl.backgroundColor = .clearColor()
        
    }
    /*private func setupCalendar() {
        
        
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
        
    }*/
    private func setupSidebarMenu() {
        if self.revealViewController() != nil {
            self.revealViewController().rearViewRevealDisplacement = 0
            self.revealViewController().rearViewRevealOverdraw = 0
            self.revealViewController().rearViewRevealWidth = 275
            self.revealViewController().frontViewShadowRadius = 0
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
    }
    @IBAction func UpdateCalendar(segue:UIStoryboardSegue) {
        print("update calendar table")
        phincalc = false
        tbl.reloadData()
        let controller = self.calendarView.contentController as! CVCalendarMonthContentViewController
        controller.refreshPresentedMonth()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    func  tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("calendarCell", forIndexPath: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Заметки"
            let count = returnCount(0)
            var txt = ""
            if count%10 == 1{
                txt = "заметка"
            }else if count%10 == 2 || count%10 == 3 || count%10 == 4 {
                txt = "заметки"
            }else{
                txt = "заметок"
            }
            
            if count > 10 && count < 15{
                txt = "заметок"
            }
            cell.detailTextLabel?.text = "\(count) \(txt)"
            break
        case 1:
            cell.textLabel?.text = "Фотографии"
            let count = returnCount(1)
            var txt = ""
            if count%10 == 1{
                txt = "фотография"
            }else if count%10 == 2 || count%10 == 3 || count%10 == 4 {
                txt = "фотографии"
            }else{
                txt = "фотографий"
            }
            
            if count > 10 && count < 15{
                txt = "фотографий"
            }
            cell.detailTextLabel?.text = "\(count) \(txt)"
            break
        case 2:
            cell.textLabel?.text = "Уведомления"
            var count = 0
            if dateType != -1{
                count = returnCount(2)
            }
            var txt = ""
            if count%10 == 1{
                txt = "уведомление"
            }else if count%10 == 2 || count%10 == 3 || count%10 == 4 {
                txt = "уведомления"
            }else{
                txt = "уведомлений"
            }
            
            if count > 10 && count < 15{
                txt = "уведомлений"
            }
            cell.detailTextLabel?.text = "\(count) \(txt)"
            break
        default:
            break
        }
        
        cell.backgroundColor = .clearColor()
        cell.textLabel?.textColor = StrawBerryColor
        cell.detailTextLabel?.textColor = StrawBerryColor
        
        return cell


    }
    
 
    func returnCount(number: Int) -> Int{
        var count = 0
        var Select = NSDate()
        if(selectedCalendarDay != nil)
        {
            Select = selectedCalendarDay.date.convertedDate()!
        }
        
        
        switch number {
        case 0: //заметки
            var table = Table("TextNote")
            let Date = Expression<String>("Date")
            if(selectedCalendarDay == nil)
            {count += try db.scalar(table.filter(Date == "\(Select)").count)}
            else{
                count += try db.scalar(table.filter(Date == "\(Select)").count)
            }
            table = Table("WeightNote")
            count += try db.scalar(table.filter(Date == "\(Select)").count)
            
            table = Table("DoctorVisit")
            let calendar = NSCalendar.currentCalendar()
            var components = calendar.components([.Day , .Month , .Year], fromDate: Select)
            
            for i in try! db.prepare(table.select(Date)) {
                let b = i[Date]
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
                let componentsCurrent = calendar.components([.Day , .Month , .Year], fromDate: dateFormatter.dateFromString(b)!)
                if components.day == componentsCurrent.day && components.month == componentsCurrent.month && components.year == componentsCurrent.year {
                    count += 1
                }
            }
            
            table = Table("Food")
            count += try db.scalar(table.filter(Date == "\(Select)").count)
            
            table = Table("MedicineTake")
            let start = Expression<String>("Start")
            let end = Expression<String>("End")
            
            components = calendar.components([.Day , .Month , .Year], fromDate: Select)
            components.hour = 00
            components.minute = 00
            components.second = 00
            let newcurDate = calendar.dateFromComponents(components)
            
            for i in try! db.prepare(table.select(start,end)) {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
                let componentsS = calendar.components([.Day , .Month , .Year], fromDate: dateFormatter.dateFromString(i[start])!)
                let componentsE = calendar.components([.Day , .Month , .Year], fromDate: dateFormatter.dateFromString(i[end])!)
                componentsS.hour = 00
                componentsS.minute = 00
                componentsS.second = 00
                let newDateS = calendar.dateFromComponents(componentsS)
                componentsE.hour = 00
                componentsE.minute = 00
                componentsE.second = 00
                let newDateE = calendar.dateFromComponents(componentsE)
                let a = newcurDate?.compare(newDateS!)
                let b = newcurDate?.compare(newDateE!)
                if (a == NSComparisonResult.OrderedDescending || a == NSComparisonResult.OrderedSame) && (b == NSComparisonResult.OrderedAscending || b == NSComparisonResult.OrderedSame) {
                    count += 1
                }
            }
            
            table = Table("DesireList")
            count += try db.scalar(table.count)
            
            break
        case 1: //фото
            var table = Table("Photo")
            let Date = Expression<String>("Date")
            count += try db.scalar(table.filter(Date == "\(Select)").count)
            
            table = Table("Uzi")
            count += try db.scalar(table.filter(Date == "\(Select)").count)
            break
        case 2: //уведомления
            day = calculateDay(Select)
            let table = Table("Notification")
            let Day = Expression<Int64>("Day")
            count = try db.scalar(table.filter(Day == Int64(day)).count)
            break
        default:
            break
        }
        return count
    }
    
    private func getCustomBackgroundView() -> UIView{
        let BackgroundView = UIView()
        BackgroundView.backgroundColor = UIColor.whiteColor()
        return BackgroundView
    }
        
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell!.selectedBackgroundView=getCustomBackgroundView()
        cell!.textLabel?.highlightedTextColor = StrawBerryColor
        cell!.detailTextLabel?.highlightedTextColor = StrawBerryColor
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            //cell.textLabel?.text = "Заметки"
            selectedNoteDay = selectedCalendarDay!
            let notes = self.storyboard?.instantiateViewControllerWithIdentifier("NotesNavigationController")
            self.revealViewController().pushFrontViewController(notes!, animated: true)
            break
        case 1:
            //cell.textLabel?.text = "Фотографии"
            selectedCalendarDayPhoto = selectedCalendarDay!
            phincalc = true
            let photo = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoFromCalendarNavigation")
            self.navigationController?.pushViewController(photo!, animated: true)
            //self.revealViewController()?.pushFrontViewController(photo!, animated: true)
            break
        case 2:
            //cell.textLabel?.text = "Уведомления"
            selectedExperienceDay = selectedCalendarDay!
            fromCalendar = true
            phincalc = true
            let experience = self.storyboard?.instantiateViewControllerWithIdentifier("ExperienceNavigationController")
            self.revealViewController().pushFrontViewController(experience!, animated: true)
            break
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calendarView.backgroundColor = StrawBerryColor
        menuView.backgroundColor = StrawBerryColor
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
        
        // calendarView.changeMode(.WeekView)
    }
    
    func loadDate(){
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entityForName("BirthDate", inManagedObjectContext:managedContext)
        
        fetchRequest.entity = entityDescription
        do {
            let result = try managedContext.executeFetchRequest(fetchRequest)
            
            if (result.count > 0) {
                for i in result {
                    let date = i as! NSManagedObject
                    let dte = date.valueForKey("date") as! NSDate
                    dateType = date.valueForKey("type") as! Int
                    BirthDate = dte
                    if dateType == 0{
                        BirthDate = addDaystoGivenDate(BirthDate, NumberOfDaysToAdd: 7*38)
                    }
                    else if dateType == 1{
                        BirthDate = addDaystoGivenDate(BirthDate, NumberOfDaysToAdd: 7*40)
                    }
                }
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
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

extension CalendarViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
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
    
    func shouldAnimateResizing() -> Bool {
        return true // Default value is true
    }
    
    func shouldAutoSelectDayOnMonthChange() -> Bool
    {
        return true
    }
    
    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("\(dayView.date.commonDescription) is selected!")
        selectedCalendarDay = dayView
        tbl.reloadData()
    }
    
    func swipedetected(){
        /*print("great work")
         arrSelectedDates.removeAll()
         arrSelectedDates.append(selectedDay.date.convertedDate()!)
         
         
         let calendarPicker = EPCalendarPicker(startYear: currentyear - 1 , endYear: currentyear + 10, multiSelection: false, selectedDates: arrSelectedDates,window: false , scroll: true , scrollDate: selectedDay.date.convertedDate()!)
         calendarPicker.calendarDelegate = self
         calendarPicker.startDate = NSDate()
         //calendarPicker.hightlightsToday = true
         //calendarPicker.showsTodaysButton = true
         
         calendarPicker.backgroundColor = StrawBerryColor
         calendarPicker.monthTitleColor = UIColor.whiteColor()
         calendarPicker.weekdayTintColor = UIColor.lightGrayColor()
         calendarPicker.weekendTintColor = UIColor.lightGrayColor()
         
         
         let navigationController = UINavigationController(rootViewController: calendarPicker)
         
         self.presentViewController(navigationController, animated: true, completion: nil)*/
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

extension CalendarViewController: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
}

// MARK: - IB Actions

extension CalendarViewController {
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

extension CalendarViewController {
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

