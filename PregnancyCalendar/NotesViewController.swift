//
//  NotesTableViewController.swift
//  rodicalc
//
//  Created by deck on 25.02.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit

import SwiftyVK

var selectedNoteDay:DayView!
var DayForView = NSDate()
var NoteType = Int()
var notes = ["Мое самочувствие","Как ведет себя малыш","Посещения врачей","Мой вес","Принимаемые лекарства","Приятное воспоминание дня","Важные события","Моё меню на сегодня","Мой \"лист желаний\""]


class NotesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var tbl: UITableView!
    var shouldShowDaysOut = true
    var animationFinished = true
    //var db = try! Connection()
    var texts = ["","","","","","","","",""]
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbl.delegate = self
        tbl.dataSource = self
        tbl.backgroundColor = .clearColor()
        print(DayForView)
        self.presentedDateUpdated(CVDate(date: NSDate()))
        let btnBack = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = btnBack
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.loadNotes()})
        tbl.reloadData()
    }
    
    @IBAction func UpdateSectionTable(segue:UIStoryboardSegue) {
        print("update notes table")
        loadNotes()
        tbl.reloadData()
    }
    
    
    func returnTableText(tableName: String, type: Int, date: NSDate) -> String{
        let table = Table(tableName)
        var str = ""
        
        if tableName == "TextNote"{
            let Type = Expression<Int64>("Type")
            let Date = Expression<String>("Date")
            let text = Expression<String>("NoteText")

            for tmp in try! db.prepare(table.select(text).filter(Date == "\(date)" && Type == Int64(type))){
                str = tmp[text]}
                
        }else if tableName == "WeightNote"{
            let table = Table("WeightNote")
            let Date = Expression<String>("Date")
            let WeightKg = Expression<Int64>("WeightKg")
            let WeightGr = Expression<Int64>("WeightGr")
   
            for tmp in try! db.prepare(table.select(WeightKg, WeightGr).filter(Date == "\(date)")){
                str = "\(tmp[WeightKg]) кг \(tmp[WeightGr]) г"
            }
        }else if tableName == "DoctorVisit"{
           let table = Table("DoctorVisit")
            let Date = Expression<String>("Date")
            let name = Expression<String>("Name")
            let calendar = NSCalendar.currentCalendar()
            
            let components = calendar.components([.Day , .Month , .Year], fromDate: date)
            for i in try! db.prepare(table.select(Date,name)) {
                let b = i[Date]
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
                let componentsCurrent = calendar.components([.Day , .Month , .Year], fromDate: dateFormatter.dateFromString(b)!)
                if components.day == componentsCurrent.day && components.month == componentsCurrent.month && components.year == componentsCurrent.year {
                    if(str.characters.count>0)
                    {
                        str.appendContentsOf(",")
                    }
                    str.appendContentsOf(i[name])
                }
            }
        }else if tableName == "MedicineTake"{
            let table = Table("MedicineTake")
            let name = Expression<String>("Name")
            let start = Expression<String>("Start")
            let end = Expression<String>("End")
            var count = 0
            
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Day , .Month , .Year], fromDate: date)
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
            if count > 0 {
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
                str = "\(count) \(txt)"
            }
        }
        return str
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return   notes.count
    }
    
    func  tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NoteCell", forIndexPath: indexPath)
        cell.textLabel?.text = notes[indexPath.row]
        //cell.detailTextLabel?.text = "нет заметок"
        var text = String()

        dispatch_async(dispatch_get_main_queue(), {
        switch indexPath.row {
        case 0: //мое самочувствие - тестовая
            
            text = self.texts[0]
            
            if  text  != "" {
                cell.detailTextLabel?.text?.appendContentsOf("Мое самочувствие ")
                cell.detailTextLabel?.text = String(text)
            }else{
                cell.detailTextLabel?.text = "Нет заметок"
            }
            break
        case 1: //как ведет сеья малыш - текстовая
            text = self.texts[1]
            if  text  != "" {
                cell.detailTextLabel?.text?.appendContentsOf("Как ведет себя малыш ")
                cell.detailTextLabel?.text = String(text)
            }else{
                cell.detailTextLabel?.text = "Нет заметок"
            }
            break
        case 2: //посещение врачей - список с напоминаниеями
            text = self.texts[2]
            if  text  != "" {
                cell.detailTextLabel?.text = String(text)
            }else{
                cell.detailTextLabel?.text = "Нет заметок"
            }
            break
        case 3: //мой вес - текстовая
            text = self.texts[3]
            if  text  != "" {
                cell.detailTextLabel?.text = String(text)
            }else{
                cell.detailTextLabel?.text = "Нет заметок"
            }
            break
        case 4: //принимаемые лекарства - список с напоминаниями
            text = self.texts[4]
            if  text  != "" {
                cell.detailTextLabel?.text = String(text)
            }else{
                cell.detailTextLabel?.text = "Нет заметок"
            }
            break
        case 5: //приятное воспоминание дня - тестовая
            text = self.texts[5]
            if  text  != "" {
                cell.detailTextLabel?.text = String(text)
            }else{
                cell.detailTextLabel?.text = "Нет заметок"
            }
            break
        case 6: //важные события - текстовая
            text = self.texts[6]
            if  text  != "" {
                cell.detailTextLabel?.text = String(text)
            }else{
                cell.detailTextLabel?.text = "Нет заметок"
            }
            break
        case 7: //мое меню на сегодня - несколько списков
            let count: Int = Int(self.texts[7])!
            if count > 0 {
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
            }else{
                cell.detailTextLabel?.text = "Нет заметок"
            }
            break
        case 8: //мой "лист желаний" - список - не превязаны ко дню
            let count: Int = Int(self.texts[8])!
            if count > 0 {
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
            }else{
                cell.detailTextLabel?.text = "Нет заметок"
            }
            break
            default: break
        }
        cell.backgroundColor = .clearColor()
        cell.selectedBackgroundView?.backgroundColor = .clearColor()
            }
        )
        return cell

    }
    
    func loadNotes(){
        var date = NSDate()
        if selectedNoteDay != nil{
            date = selectedNoteDay.date.convertedDate()!
        }
        texts[0] = returnTableText("TextNote", type: 0, date: date)
        texts[1] = returnTableText("TextNote", type: 1, date: date)
        texts[2] = returnTableText("DoctorVisit", type: 2, date: date)
        texts[3] = returnTableText("WeightNote", type: 3, date: date)
        texts[4] = returnTableText("MedicineTake", type: 4, date: date)
        texts[5] = returnTableText("TextNote", type: 5, date: date)
        texts[6] = returnTableText("TextNote", type: 6, date: date)
        texts[7] = String(returnFoodCount(date))
        texts[8] = String(returnDesireCount())
    }
    
    func returnDesireCount()->Int{
        let table = Table("DesireList")
        return try! db.scalar(table.count)
    }
    
    func returnFoodCount(date: NSDate)->Int{
        let table = Table("Food")
        let Date = Expression<String>("Date")
        return try! db.scalar(table.filter(Date == "\(date)").count)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NoteType = indexPath.row
        switch indexPath.row {
        case 0:
            let destinationViewController = self.storyboard?.instantiateViewControllerWithIdentifier("textNote")
            self.navigationController?.pushViewController(destinationViewController!, animated: true)
            break
        case 1:
            let destinationViewController = self.storyboard?.instantiateViewControllerWithIdentifier("textNote")
            self.navigationController?.pushViewController(destinationViewController!, animated: true)
            break
        case 2:
            let destinationViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Doctor")
            self.navigationController?.pushViewController(destinationViewController!, animated: true)
            
            break
        case 3:
            let destinationViewController = self.storyboard?.instantiateViewControllerWithIdentifier("WeightNote")
            self.navigationController?.pushViewController(destinationViewController!, animated: true)
            break
        case 4:
            let destinationViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Drugs")
            self.navigationController?.pushViewController(destinationViewController!, animated: true)
            break
        case 5:
            let destinationViewController = self.storyboard?.instantiateViewControllerWithIdentifier("textNote")
            self.navigationController?.pushViewController(destinationViewController!, animated: true)
            break
        case 6:
            let destinationViewController = self.storyboard?.instantiateViewControllerWithIdentifier("textNote")
            self.navigationController?.pushViewController(destinationViewController!, animated: true)
            break
        case 7:
            let destinationViewController = self.storyboard?.instantiateViewControllerWithIdentifier("FoodNote")
            self.navigationController?.pushViewController(destinationViewController!, animated: true)
            break
        case 8:
            let destinationViewController = self.storyboard?.instantiateViewControllerWithIdentifier("desireNote")
            self.navigationController?.pushViewController(destinationViewController!, animated: true)
            break

        default: break
        }
    }
    
    private func getCustomBackgroundView() -> UIView{
        let BackgroundView = UIView()
        BackgroundView.backgroundColor = UIColor.clearColor()
        return BackgroundView
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell!.selectedBackgroundView=getCustomBackgroundView()
        //cell!.textLabel?.highlightedTextColor = StrawBerryColor
        //cell!.detailTextLabel?.highlightedTextColor = StrawBerryColor
        //cell?.selectedBackgroundView?.backgroundColor = .clearColor()
        return indexPath
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if(selectedNoteDay != nil){
            let  date = selectedNoteDay.date
            let controller = calendarView.contentController as! CVCalendarMonthContentViewController
            controller.selectDayViewWithDay(date.day, inMonthView: controller.presentedMonthView)
        }else{
            let  date = CVDate(date: NSDate())
            let controller = calendarView.contentController as! CVCalendarMonthContentViewController
            controller.selectDayViewWithDay(date.day, inMonthView: controller.presentedMonthView)
        }

    }
    
    override func viewWillDisappear(animated: Bool) {
        DayForView = NSDate()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        calendarView.backgroundColor = StrawBerryColor
        menuView.backgroundColor = StrawBerryColor
        
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
        
        
        // calendarView.changeMode(.WeekView)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension NotesViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
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
        print("\(dayView.date.commonDescription) is selected!")
        selectedNoteDay = dayView
        loadNotes()
        tbl.reloadData()
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

extension NotesViewController: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
}

// MARK: - IB Actions

extension NotesViewController {
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

extension NotesViewController {
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
