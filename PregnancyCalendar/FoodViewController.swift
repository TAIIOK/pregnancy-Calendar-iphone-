//
//  FoodViewController.swift
//  Календарь беременности
//
//  Created by deck on 29.04.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit

class FoodViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
    var isKeyboard = false
    
    func keyboardWillShow(notification: NSNotification) {
        if !isKeyboard{
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height*0.8
            isKeyboard = true
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if isKeyboard{
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height*0.8
            isKeyboard = false
            }
        }
    }

    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var FoodTable: UITableView!
    @IBOutlet weak var PreferencesTable: UITableView!
    @IBOutlet weak var RestrictionsTable: UITableView!
    
    @IBOutlet weak var otherView: UIView!
    @IBOutlet weak var foodVIew: UIView!
    @IBOutlet weak var restrictionslbl: UILabel!
    @IBOutlet weak var preferenceslbl: UILabel!
    @IBOutlet weak var foodlbl: UILabel!
    var shouldShowDaysOut = true
    var animationFinished = true
    
    var Food = [String]()
    var Preferences = [String]()
    var Restrictions = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        //self.title = CVDate(date: NSDate()).globalDescription
        if selectedNoteDay != nil {
            self.calendarView.toggleViewWithDate(selectedNoteDay.date.convertedDate()!)
        }else{
            let date = NSDate()
            self.calendarView.toggleViewWithDate(date)
        }
        self.presentedDateUpdated(CVDate(date: NSDate()))
        foodlbl.textColor = NotesColor[NoteType]
        preferenceslbl.textColor = NotesColor[0]
        restrictionslbl.textColor = NotesColor[6]
        FoodTable.delegate = self
        FoodTable.dataSource = self
        FoodTable.backgroundColor = .clearColor()
        PreferencesTable.delegate = self
        PreferencesTable.dataSource = self
        PreferencesTable.backgroundColor = .clearColor()
        RestrictionsTable.delegate = self
        RestrictionsTable.dataSource = self
        RestrictionsTable.backgroundColor = .clearColor()
        loadData()
        if Food.count == 0 {
            Food.append("")
        }
        if Preferences.count == 0 {
            Preferences.append("")
        }
        if Restrictions.count == 0 {
            Restrictions.append("")
        }
    }
    @IBAction func changeSegment(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            foodlbl.hidden = false
            FoodTable.hidden = false
            foodVIew.hidden = false
            otherView.hidden = true
            preferenceslbl.hidden = true
            restrictionslbl.hidden = true
            PreferencesTable.hidden = true
            RestrictionsTable.hidden = true
        }else{
            foodlbl.hidden = true
            FoodTable.hidden = true
            foodVIew.hidden = true
            otherView.hidden = false
            preferenceslbl.hidden = false
            restrictionslbl.hidden = false
            PreferencesTable.hidden = false
            RestrictionsTable.hidden = false
        }
        
    }

    
    func loadData(){
        Food.removeAll()
        var table = Table("Food")
        var text = Expression<String>("Text")
        let date = Expression<String>("Date")
        for i in try! db.prepare(table.filter(date == "\(selectedNoteDay.date.convertedDate()!)")) {
            Food.append(i[text])
        }

        Preferences.removeAll()
        table = Table("Preferences")
        text = Expression<String>("Text")

        for i in try! db.prepare(table) {
            Preferences.append(i[text])
        }
        
        Restrictions.removeAll()
        table = Table("Restrictions")
        text = Expression<String>("Text")
        for i in try! db.prepare(table) {
            Restrictions.append(i[text])
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if tableView == FoodTable{
            return Food.count+1
        }else if tableView == PreferencesTable{
            return Preferences.count+1
        }else{
            return Restrictions.count+1
        }
    }
    
    func  tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == FoodTable{
            let cell = tableView.dequeueReusableCellWithIdentifier("FoodCell", forIndexPath: indexPath) as! FoodTableViewCell
            if indexPath.row == Food.count{
                cell.textField.hidden = true
            }else{
                cell.textField.hidden = false
                cell.textField.text = Food[indexPath.row]}
            cell.backgroundColor = .clearColor()
            cell.textField.layer.borderWidth = 0.5
            cell.textField.layer.borderColor = StrawBerryColor.CGColor
            cell.textField.delegate = self
            return cell
        }else if tableView == PreferencesTable{
            let cell = tableView.dequeueReusableCellWithIdentifier("PreferencesCell", forIndexPath: indexPath) as! PreferencesTableViewCell
            if indexPath.row == Preferences.count{
                cell.textField.hidden = true
            }else{
                cell.textField.hidden = false
                cell.textField.text = Preferences[indexPath.row]}
            cell.backgroundColor = .clearColor()
            cell.textField.layer.borderWidth = 0.5
            cell.textField.layer.borderColor = StrawBerryColor.CGColor
            cell.textField.delegate = self
            return cell

        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("RestrictionsCell", forIndexPath: indexPath) as! RestrictionsTableViewCell
            if indexPath.row == Restrictions.count{
                cell.textField.hidden = true
            }else{
                cell.textField.hidden = false
                cell.textField.text = Restrictions[indexPath.row]}
            cell.backgroundColor = .clearColor()
            cell.textField.layer.borderWidth = 0.5
            cell.textField.layer.borderColor = StrawBerryColor.CGColor
            cell.textField.delegate = self
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func textViewDidChange(textView: UITextView) {
        fromTableFoodInArray()
        fromTablePreferencesInArray()
        fromTableRestrictionsInArray()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == FoodTable{
            if indexPath.row == Food.count{
                fromTableFoodInArray()
                Food.append("")
                self.FoodTable.reloadData()
                fromTablePreferencesInArray()
                fromTableRestrictionsInArray()
            }
        }else if tableView == PreferencesTable{
            if indexPath.row == Preferences.count{
                fromTablePreferencesInArray()
                Preferences.append("")
                self.PreferencesTable.reloadData()
                fromTableFoodInArray()
                fromTableRestrictionsInArray()
            }
        }else{
            if indexPath.row == Restrictions.count{
                fromTableRestrictionsInArray()
                Restrictions.append("")
                self.RestrictionsTable.reloadData()
                fromTableFoodInArray()
                fromTablePreferencesInArray()
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        //saveNote()
        self.performSegueWithIdentifier("UpdateSectionTable", sender: self)
    }
    
    @IBAction func btnSave(sender: UIButton) {
        saveNote()
        self.view.makeToast(message: "Cохранено!", duration: 2.0, position:HRToastPositionCenter)
        let controller = calendarView.contentController as! CVCalendarWeekContentViewController
        controller.reloadWeekViews()
    }
    
    func saveNote(){
        fromTableFoodInArray()
        var table = Table("Food")
        let text = Expression<String>("Text")
        let date = Expression<String>("Date")
        
        var count = try! db.scalar(table.filter(date == "\(selectedNoteDay.date.convertedDate()!)").count)
        if count > 0{
            try! db.run(table.filter(date == "\(selectedNoteDay.date.convertedDate()!)").delete())
        }
        for  i in Food{
            if i.characters.count > 0{
                try! db.run(table.insert(text <- "\(i)", date <- "\(selectedNoteDay.date.convertedDate()!)"))}
        }
        
        fromTablePreferencesInArray()
        table = Table("Preferences")
        count = try! db.scalar(table.count)
        if count > 0{
            try! db.run(table.delete())
        }
        for  i in Preferences{
            if i.characters.count > 0{
                try! db.run(table.insert(text <- "\(i)"))}
        }
        
        fromTableRestrictionsInArray()
        table = Table("Restrictions")
        count = try! db.scalar(table.count)
        if count > 0{
            try! db.run(table.delete())
        }
        for  i in Restrictions{
            if i.characters.count > 0{
                try! db.run(table.insert(text <- "\(i)"))}
        }
    }
    
    func fromTableFoodInArray(){
        let int = self.FoodTable.numberOfRowsInSection(0)-1
        for var i = NSIndexPath(forRow: 0, inSection: 0); i.row < int; i = NSIndexPath(forRow: i.row+1, inSection: 0){
            let cell = self.FoodTable.cellForRowAtIndexPath(i) as! FoodTableViewCell
            Food[i.row] = cell.textField.text!
        }
    }
    
    func fromTablePreferencesInArray(){
        let int = self.PreferencesTable.numberOfRowsInSection(0)-1
        for var i = NSIndexPath(forRow: 0, inSection: 0); i.row < int; i = NSIndexPath(forRow: i.row+1, inSection: 0){
            let cell = self.PreferencesTable.cellForRowAtIndexPath(i) as! PreferencesTableViewCell
            Preferences[i.row] = cell.textField.text!
        }
    }
    
    func fromTableRestrictionsInArray(){
        let int = self.RestrictionsTable.numberOfRowsInSection(0)-1
        for var i = NSIndexPath(forRow: 0, inSection: 0); i.row < int; i = NSIndexPath(forRow: i.row+1, inSection: 0){
            let cell = self.RestrictionsTable.cellForRowAtIndexPath(i) as! RestrictionsTableViewCell
            Restrictions[i.row] = cell.textField.text!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let date = selectedNoteDay.date
        let controller = calendarView.contentController as! CVCalendarWeekContentViewController
        controller.selectDayViewWithDay(date.day, inWeekView: controller.getPresentedWeek()!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calendarView.backgroundColor = StrawBerryColor
        menuView.backgroundColor = StrawBerryColor
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
        // calendarView.changeMode(.WeekView)
    }
}

extension FoodViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
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
    
    func shouldAutoSelectDayOnMonthChange() -> Bool
    {
        return false
    }
    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("\(dayView.date.commonDescription) is selected!")
        //saveNote()
        selectedNoteDay = dayView
        loadData()
        if Food.count == 0 {
            Food.append("")
        }
        if Preferences.count == 0 {
            Preferences.append("")
        }
        if Restrictions.count == 0 {
            Restrictions.append("")
        }
        FoodTable.reloadData()
        PreferencesTable.reloadData()
        RestrictionsTable.reloadData()
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

extension FoodViewController: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
}

// MARK: - IB Actions

extension FoodViewController {
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

extension FoodViewController {
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
