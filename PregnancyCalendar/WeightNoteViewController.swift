//
//  WeightNoteViewController.swift
//  Календарь беременности
//
//  Created by deck on 29.04.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit

class WeightNoteViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{

    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    //@IBOutlet var pickerView: UIPickerView!
    @IBOutlet var pickerViewTextField: UITextField!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var pickerViewTextFieldGramm: UITextField!
    @IBOutlet var pickerViewGramm: UIPickerView!
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var btnGR: UIButton!
    @IBOutlet weak var btnKG: UIButton!
    var firstComponent = [0, 1, 2]
    var secondComponent = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    var thirdComponent = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    
    var firstrun = true
    
    var shouldShowDaysOut = true
    var animationFinished = true
    
    var weightKg = 0
    var weightGramm = 0
    var type = 0 //0-kg 1 -gr

    var shouldAutoSelect = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //self.title = CVDate(date: NSDate()).globalDescription
        if selectedNoteDay != nil {
            self.calendarView.toggleViewWithDate(selectedNoteDay.date.convertedDate()!)
        }else{
            let date = NSDate()
            self.calendarView.toggleViewWithDate(date)
        }
        label.textColor = NotesColor[NoteType]
        shouldAutoSelect = false
        
        self.calendarView.delegate = self
        
        self.presentedDateUpdated(CVDate(date: NSDate()))
        loadWeight()
        setupWeightPickerView()
        setupWeightPickerViewToolbar()
        setupWeightPickerViewGramm()
        setupWeightPickerViewToolbarGramm()
    }

    
    func loadWeight(){
        let table = Table("WeightNote")
        let Date = Expression<String>("Date")
        let WeightKg = Expression<Int64>("WeightKg")
        let WeightGr = Expression<Int64>("WeightGr")
        for tmp in try! db.prepare(table.select(WeightKg, WeightGr).filter(Date == "\(selectedNoteDay.date.convertedDate()!)")){
            weightKg = Int(tmp[WeightKg])
            weightGramm = Int(tmp[WeightGr])
        }
        self.btnKG.setTitle("\(weightKg) кг", forState: UIControlState.Normal)
        self.btnGR.setTitle("\(weightGramm) г", forState: UIControlState.Normal)
    }
    
    @IBAction func setKg(sender: UIButton) {
        type = 0
        setupPickerViewValues()
        self.pickerViewTextField.becomeFirstResponder()
    }
    
    @IBAction func setGramm(sender: UIButton) {
        type = 1
        setupPickerViewValuesGramm()
        self.pickerViewTextFieldGramm.becomeFirstResponder()
    }
    
    private func setupWeightPickerView()  {
        self.pickerViewTextField = UITextField(frame: CGRectZero)
        self.view.addSubview(self.pickerViewTextField)
        self.pickerView = UIPickerView(frame: CGRectMake(0, 0, 0, 0))
        self.pickerView.showsSelectionIndicator = true
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerView.backgroundColor = .whiteColor()
        self.pickerViewTextField.inputView = pickerView
    }
    private func setupWeightPickerViewGramm()  {
        self.pickerViewTextFieldGramm = UITextField(frame: CGRectZero)
        self.view.addSubview(self.pickerViewTextFieldGramm)
        self.pickerViewGramm = UIPickerView(frame: CGRectMake(0, 0, 0, 0))
        self.pickerViewGramm.showsSelectionIndicator = true
        self.pickerViewGramm.delegate = self
        self.pickerViewGramm.dataSource = self
        self.pickerViewGramm.backgroundColor = .whiteColor()
        self.pickerViewTextFieldGramm.inputView = pickerViewGramm
    }
    
    private func setupPickerViewValues() {
        var rowIndex = 0
        if type == 0{
            rowIndex = weightKg
        }else {
            rowIndex = weightGramm
        }
        self.pickerView.selectRow(rowIndex % 10, inComponent: 2, animated: true)
        rowIndex /= 10
        self.pickerView.selectRow(rowIndex % 10, inComponent: 1, animated: true)
        rowIndex /= 10
        self.pickerView.selectRow(rowIndex % 10, inComponent: 0, animated: true)
    }
    private func setupPickerViewValuesGramm() {
        var rowIndex = 0
        if type == 0{
            rowIndex = weightKg
        }else {
            rowIndex = weightGramm
        }
        self.pickerViewGramm.selectRow(rowIndex % 10, inComponent: 2, animated: true)
        rowIndex /= 10
        self.pickerViewGramm.selectRow(rowIndex % 10, inComponent: 1, animated: true)
        rowIndex /= 10
        self.pickerViewGramm.selectRow(rowIndex % 10, inComponent: 0, animated: true)
    }
    
    private func setupWeightPickerViewToolbar() {
        let toolBar = UIToolbar(frame: CGRectMake(0, 0, 320, 40))
        toolBar.tintColor = StrawBerryColor
        toolBar.barTintColor = .whiteColor()
        let doneButton = UIBarButtonItem(title: "Готово", style: .Plain, target: self, action: Selector("doneButtonTouched"))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .Plain, target: self, action: Selector("cancelButtonTouched"))
        toolBar.setItems([cancelButton, flexSpace, doneButton], animated: true)
        self.pickerViewTextField.inputAccessoryView = toolBar
    }
    private func setupWeightPickerViewToolbarGramm() {
        let toolBar = UIToolbar(frame: CGRectMake(0, 0, 320, 40))
        toolBar.tintColor = StrawBerryColor
        toolBar.barTintColor = .whiteColor()
        let doneButton = UIBarButtonItem(title: "Готово", style: .Plain, target: self, action: Selector("doneButtonTouchedGramm"))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .Plain, target: self, action: Selector("cancelButtonTouchedGramm"))
        toolBar.setItems([cancelButton, flexSpace, doneButton], animated: true)
        self.pickerViewTextFieldGramm.inputAccessoryView = toolBar
    }
    
    private func getWeightFromPickerView() -> Int {
        return secondComponent[self.pickerView.selectedRowInComponent(0)]*100 + secondComponent[self.pickerView.selectedRowInComponent(1)]*10 + secondComponent[self.pickerView.selectedRowInComponent(2)]
    }
    
    private func getWeightFromPickerViewGramm() -> Int {
        return secondComponent[self.pickerViewGramm.selectedRowInComponent(0)]*100 + secondComponent[self.pickerViewGramm.selectedRowInComponent(1)]*10 + secondComponent[self.pickerViewGramm.selectedRowInComponent(2)]
    }
    
    // MARK: - UIPickerView
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 && type == 0{
            return firstComponent.count
        } else {
            return secondComponent.count
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 && type == 0{
            return "\(firstComponent[row])"
        } else {
            return "\(secondComponent[row])"
        }
    }
    
    func doneButtonTouched() {
        //self.pickerViewTextField.resignFirstResponder()
        dispatch_async(dispatch_get_main_queue(), {

        if self.type == 0{
            self.weightKg = self.getWeightFromPickerView()
            self.btnKG.setTitle("\(self.weightKg) кг", forState: UIControlState.Normal)
        }else{
            self.weightGramm = self.getWeightFromPickerView()
            self.btnGR.setTitle("\(self.weightGramm) г", forState: UIControlState.Normal)
        }
            
            }
        )
        //setupPickerViewValues()
        self.pickerViewTextField.resignFirstResponder()
    }
    
    func cancelButtonTouched() {
        self.pickerViewTextField.resignFirstResponder()
    }
    
    func doneButtonTouchedGramm() {
        //self.pickerViewTextField.resignFirstResponder()
        dispatch_async(dispatch_get_main_queue(), {
            
            if self.type == 0{
                self.weightKg = self.getWeightFromPickerViewGramm()
                self.btnKG.setTitle("\(self.weightKg) кг", forState: UIControlState.Normal)
            }else{
                self.weightGramm = self.getWeightFromPickerViewGramm()
                self.btnGR.setTitle("\(self.weightGramm) г", forState: UIControlState.Normal)
            }
            
            }
        )
        
        //setupPickerViewValues()
        self.pickerViewTextFieldGramm.resignFirstResponder()
    }
    
    func cancelButtonTouchedGramm() {
        self.pickerViewTextFieldGramm.resignFirstResponder()
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let date = selectedNoteDay.date
        let controller = calendarView.contentController as! CVCalendarWeekContentViewController
        controller.selectDayViewWithDay(date.day, inWeekView: controller.getPresentedWeek()!)
        self.calendarView.toggleViewWithDate(selectedNoteDay.date.convertedDate()!)
    }
    
    override func viewWillDisappear(animated: Bool) {
        //saveNote()
        self.performSegueWithIdentifier("UpdateSectionTable", sender: self)
    }
    @IBAction func btnSave(sender: UIButton) {
        saveNote()
        calendars.removeAll()
        fillcalendar()
        self.view.makeToast(message: "Cохранено!", duration: 2.0, position:HRToastPositionTop)
        let controller = self.calendarView.contentController as! CVCalendarWeekContentViewController
        controller.refreshPresentedMonth()
    }
    func saveNote(){
        let table = Table("WeightNote")
        let Date = Expression<String>("Date")
        let WeightKg = Expression<Int64>("WeightKg")
        let WeightGr = Expression<Int64>("WeightGr")
        
        let count = try! db.scalar(table.filter(Date == "\(selectedNoteDay.date.convertedDate()!)").count)
        print(weightKg, weightGramm)
        if weightKg > 0 || weightGramm > 0 {
            if count == 0 {
                try! db.run(table.insert(Date <- "\(selectedNoteDay.date.convertedDate()!)", WeightKg <- Int64(weightKg), WeightGr <- Int64(weightGramm)))
            }else{
                try! db.run(table.filter(Date == "\(selectedNoteDay.date.convertedDate()!)").update(Date <- "\(selectedNoteDay.date.convertedDate()!)", WeightKg <- Int64(weightKg), WeightGr <- Int64(weightGramm)))
            }
        }else{
            try! db.run(table.filter(Date == "\(selectedNoteDay.date.convertedDate()!)").delete())
        }
    }
}


extension WeightNoteViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
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
    
    func shouldAutoSelectDayOnWeekChange() -> Bool
    {
        return true
    }
    
    func shouldAnimateResizing() -> Bool {
        return true // Default value is true
    }
    
    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("\(dayView.date.commonDescription) is selected!")
        //saveNote()
        selectedNoteDay = dayView
        weightKg = 0
        weightGramm = 0
        loadWeight()
        setupWeightPickerView()
        setupWeightPickerViewToolbar()
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

extension WeightNoteViewController: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
}

// MARK: - IB Actions

extension WeightNoteViewController {
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

extension WeightNoteViewController {
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
