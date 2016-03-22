//
//  EPCalendarPicker.swift
//  EPCalendar
//
//  Created by Roman Efimov on 20/02/16.
//  Copyright © 2016 Roman Efimov. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

@objc public protocol EPCalendarPickerDelegate{
    
    optional    func epCalendarPicker(_: EPCalendarPicker, didCancel error : NSError)
    optional    func epCalendarPicker(_: EPCalendarPicker, didSelectDate date : NSDate)
    optional    func epCalendarPicker(_: EPCalendarPicker, didSelectMultipleDate dates : [NSDate])
    
    
}


public class EPCalendarPicker: UICollectionViewController {

   

    public  var arrEvents = [NSDate]()
    public var aboutEvents = [NSDate:String]()
    
    public var currentMonth :Int
    public var arrSelectedDates = [NSDate]()
    public var arrSelectedIndexPath = [NSDate:NSIndexPath]()
    
    public var calendarDelegate : EPCalendarPickerDelegate?
    public var multiSelectEnabled: Bool = false
    public var showsTodaysButton: Bool = true


    public var dayDisabledTintColor: UIColor
    public var weekdayTintColor: UIColor
    public var weekendTintColor: UIColor
    public var todayTintColor: UIColor
    public var dateSelectionColor: UIColor
    public var monthTitleColor: UIColor
    
    public var startDate: NSDate?
    public var hightlightsToday: Bool = true
    public var tintColor: UIColor
    public var barTintColor: UIColor
    public var hideDaysFromOtherMonth: Bool = false
    public var backgroundImage: UIImage?
    public var backgroundColor: UIColor?

    
    private(set) public var startYear: Int
    private(set) public var endYear: Int
    private(set) public var window: Bool

    
   
    override public func viewDidLoad() {
        super.viewDidLoad()

        /*
        // setup Navigationbar
         if (window){
        self.navigationController?.navigationBar.tintColor = self.tintColor
        self.navigationController?.navigationBar.barTintColor = self.barTintColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:self.tintColor]
        }
         */
        if(!window){
        inititlizeBarButtons()
        }
        // setup collectionview
        self.collectionView?.delegate = self
        self.collectionView?.backgroundColor = UIColor.clearColor()
        self.collectionView?.showsHorizontalScrollIndicator = false
        self.collectionView?.showsVerticalScrollIndicator = false
        self.collectionView?.dataSource = self
        

        

        // Register cell classes
        self.collectionView!.registerNib(UINib(nibName: "EPCalendarCell1", bundle: NSBundle(forClass: EPCalendarPicker.self )), forCellWithReuseIdentifier: reuseIdentifier)
        
        self.collectionView!.registerNib(UINib(nibName: "EPCalendarHeaderView", bundle: NSBundle(forClass: EPCalendarPicker.self )), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
        
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.scrollToToday()
        }
        
        if backgroundImage != nil {
            self.collectionView!.backgroundView =  UIImageView(image: backgroundImage)
        } else if backgroundColor != nil {
            self.collectionView?.backgroundColor = backgroundColor
        } else {
            self.collectionView?.backgroundColor = UIColor.whiteColor()
        }
        // Do any additional setup after loading the view.
    }

    //инициализация кнопок в баре
    func inititlizeBarButtons(){
        

        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "onTouchCancelButton")
        self.navigationItem.leftBarButtonItem = cancelButton

        var arrayBarButtons  = [UIBarButtonItem]()
        
        /*
        if multiSelectEnabled {
            let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "onTouchDoneButton")
            arrayBarButtons.append(doneButton)
        }
        */
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "onTouchDoneButton")
        arrayBarButtons.append(doneButton)
        
        /*
        let addeventButton = UIBarButtonItem(title: "Add Event", style: UIBarButtonItemStyle.Plain, target: self, action:"onAddEventTouch")
        arrayBarButtons.append(addeventButton)
        addeventButton.tintColor = todayTintColor
        
        
        let showeventButton = UIBarButtonItem(title: "Show Event", style: UIBarButtonItemStyle.Plain, target: self, action:"onShowEventTouch")
        arrayBarButtons.append(showeventButton)
        showeventButton.tintColor = todayTintColor
        */
        
        self.navigationItem.rightBarButtonItems = arrayBarButtons
        
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //инициализаторы для базового календаря
    public convenience init(){
        self.init(startYear: EPDefaults.startYear, endYear: EPDefaults.endYear, multiSelection: EPDefaults.multiSelection, selectedDates: nil , window:false);
    }
    
    public convenience init(startYear: Int, endYear: Int, window: Bool) {
        self.init(startYear:startYear, endYear:endYear, multiSelection: EPDefaults.multiSelection, selectedDates: nil, window: window)
    }
    
    public convenience init(multiSelection: Bool,window:Bool) {
        self.init(startYear: EPDefaults.startYear, endYear: EPDefaults.endYear, multiSelection: multiSelection, selectedDates: nil,window :window)
    }
    
    public convenience init(startYear: Int, endYear: Int, multiSelection: Bool,window: Bool) {
        self.init(startYear: EPDefaults.startYear, endYear: EPDefaults.endYear, multiSelection: multiSelection, selectedDates: nil,window :window)
    }

    //базовая инициализация
    public init(startYear: Int, endYear: Int, multiSelection: Bool, selectedDates: [NSDate]?, window: Bool) {
        
        self.startYear = startYear
        self.endYear = endYear
        
        self.multiSelectEnabled = multiSelection
        
        //Text color initializations
        self.tintColor = EPDefaults.tintColor
        self.barTintColor = EPDefaults.barTintColor
        self.dayDisabledTintColor = EPDefaults.dayDisabledTintColor
        self.tintColor = EPDefaults.tintColor
        self.weekdayTintColor = EPDefaults.weekdayTintColor
        self.weekendTintColor = EPDefaults.weekendTintColor
        self.dateSelectionColor = EPDefaults.dateSelectionColor
        self.monthTitleColor = EPDefaults.monthTitleColor
        self.todayTintColor = EPDefaults.todayTintColor

        self.currentMonth = -1
        self.window = window
        //Layout creation
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.headerReferenceSize = EPDefaults.headerSize
        if let _ = selectedDates  {
            self.arrSelectedDates.appendContentsOf(selectedDates!)
        }

        
        super.init(collectionViewLayout: layout)
        
    }
    

    //обработка ошибки инициализации
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UICollectionViewDataSource


    
    //длина календаря
    override public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if startYear > endYear {
            return 0
        }
        
        let numberOfMonths = 12 * (endYear - startYear) + 12
        return numberOfMonths
    }

    func checkCurrentYear(year: Int) -> Bool{
        if year % 4 == 0 {
            if year % 100 == 0 {
                if year % 400 == 0 {
                    return true
                } else {
                    return false
                }
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    
    
    //Подсчет дней в месяце
    override public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        let startDate = NSDate(year: startYear, month: 1, day: 1)
        let firstDayOfMonth = startDate.dateByAddingMonths(section)
        
        let addingPrefixDaysWithMonthDays = ( firstDayOfMonth.numberOfDaysInMonth() + firstDayOfMonth.weekday() - NSCalendar.currentCalendar().firstWeekday )
        

        let addingSuffixDays = (addingPrefixDaysWithMonthDays)%7
        var totalNumber  = addingPrefixDaysWithMonthDays
        

        if(addingSuffixDays != 0)
        {
            totalNumber = totalNumber + ( 7 - addingSuffixDays)
        }
        
        if(firstDayOfMonth.weekday() == 1){
        totalNumber += 7
        }
        

        return totalNumber
        
    }

    //обработка дней в месяце
    override public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EPCalendarCell1
        
        let calendarStartDate = NSDate(year:startYear, month: 1, day: 1)
        let firstDayOfThisMonth = calendarStartDate.dateByAddingMonths(indexPath.section)
       
     
        var prefixDays = ( firstDayOfThisMonth.weekday() - NSCalendar.currentCalendar().firstWeekday)
       
        if(prefixDays == -1) // It can take a value of -1 only when the week starts on Monday
        {
            prefixDays += 7
        }

        if indexPath.row >= prefixDays {
            cell.isCellSelectable = true
            let currentDate = firstDayOfThisMonth.dateByAddingDays(indexPath.row-prefixDays)
            let nextMonthFirstDay = firstDayOfThisMonth.dateByAddingDays(firstDayOfThisMonth.numberOfDaysInMonth()-1)
         
            cell.currentDate = currentDate
            cell.lblDay.text = "\(currentDate.day())"

            if arrSelectedDates.filter({ $0.isDateSameDay(currentDate)
            }).count > 0 {

                    cell.selectedForLabelColor(dateSelectionColor)
        
                
                    arrSelectedIndexPath.updateValue(indexPath,forKey: cell.currentDate)
            
            }
            else{
                cell.deSelectedForLabelColor(weekdayTintColor)
               
                if cell.currentDate.isSaturday() || cell.currentDate.isSunday() {
                    cell.lblDay.textColor = weekendTintColor
                }
                
                if (currentDate > nextMonthFirstDay) {
                    cell.isCellSelectable = false
                    cell.lblDay.textColor = EPColors.LightGrayColor
                    if hideDaysFromOtherMonth {
                        cell.lblDay.textColor = UIColor.clearColor()
                    } else {
                        cell.lblDay.textColor = self.dayDisabledTintColor
                    }
                    
                }
                if currentDate.isToday() {
                    currentMonth = currentDate.month()
                    cell.setTodayCellColor(todayTintColor)
                }
                
                
                if(arrEvents.contains(currentDate))
                {
                    cell.setEventCellColor(UIColor.redColor())
                    cell.showEvents()
                }
                
                else
                {
                    cell.isCellFirstEvent = false
                }
               
            }
            
        }
        else {
            cell.deSelectedForLabelColor(weekdayTintColor)
            cell.isCellSelectable = false
            let previousDay = firstDayOfThisMonth.dateByAddingDays(-( prefixDays - indexPath.row))
            cell.currentDate = previousDay
            cell.lblDay.text = "\(previousDay.day())"
            cell.lblDay.textColor = EPColors.LightGrayColor
          //  cell.lblDay.layer.backgroundColor = UIColor.whiteColor().CGColor
            if hideDaysFromOtherMonth {
                cell.lblDay.textColor = UIColor.clearColor()
            } else {
                cell.lblDay.textColor = self.dayDisabledTintColor
            }
            
        }
        
     
    
        return cell
    }


    //инициализация размера календаря(Таблицы)
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        
        let rect = UIScreen.mainScreen().bounds
        let screenWidth = rect.size.width - 7
        return CGSizeMake(screenWidth/7, screenWidth/7);
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(5, 0, 5, 0); //top,left,bottom,right
    }
    
    
    func checkTitleName(){
        
        switch currentMonth {
        case 1:
            self.navigationController?.parentViewController?.title = "Январь"
            self.title = "Январь"
            break
        case 2:
            self.navigationController?.parentViewController?.title = "Февраль"
            self.title = "Февраль"
            break
        case 3:
            self.navigationController?.parentViewController?.title = "Март"
            self.title = "Март"
            break
        case 4:
            self.navigationController?.parentViewController?.title = "Апрель"
            self.title = "Апрель"
            break
        case 5:
            self.navigationController?.parentViewController?.title = "Май"
            self.title = "Май"
            break
        case 6:
            self.navigationController?.parentViewController?.title = "Июнь"
            self.title = "Июнь"
            break
        case 7:
            self.navigationController?.parentViewController?.title = "Июль"
            self.title = "Июль"
            break
        case 8:
            self.navigationController?.parentViewController?.title = "Август"
            self.title = "Август"
            break
        case 9:
            self.navigationController?.parentViewController?.title = "Сентябрь"
            self.title = "Сентябрь"
            break
        case 10:
            self.navigationController?.parentViewController?.title = "Октябрь"
            self.title = "Октябрь"
            break
        case 11:
            self.navigationController?.parentViewController?.title = "Ноябрь"
            self.title = "Ноябрь"
            break
        case 12:
            self.navigationController?.parentViewController?.title = "Декабрь"
            self.title = "Декабрь"
            break
        default:
            break
        }
        
        
    }
    //вставка названия месяца
    override public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        
        if kind == UICollectionElementKindSectionHeader {
            
            let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as! EPCalendarHeaderView
            
            let startDate = NSDate(year: startYear, month: 1, day: 1)
            let firstDayOfMonth = startDate.dateByAddingMonths(indexPath.section)
            
            
            if(firstDayOfMonth.month() > currentMonth ){
                

                if (firstDayOfMonth.month() == 12  && currentMonth == 1){
                currentMonth = firstDayOfMonth.month()
                }
                else{
                if(firstDayOfMonth.month() - currentMonth == 10)
                {
                    currentMonth = 12
                }
                else{
                currentMonth = firstDayOfMonth.month() - 1
                }
                }
            }
            else {
                if (firstDayOfMonth.month() == 1 && currentMonth == 11)
                {
                    currentMonth = 12
                }
                else if (firstDayOfMonth.month() == 2  && currentMonth == 12){
                    currentMonth = firstDayOfMonth.month() - 1
                }
                else{
                currentMonth = firstDayOfMonth.month()
                }
            }
            
            
            
            checkTitleName()
            
            header.backgroundColor = StrawBerryColor
            header.lblTitle.text = firstDayOfMonth.monthNameFull()
            header.lblTitle.textColor = monthTitleColor
            header.updateWeekdaysLabelColor(weekdayTintColor)
            header.updateWeekendLabelColor(weekendTintColor)
            return header;
        }
       
        return UICollectionReusableView()
        
    }
 
    //настройка выбора дней
    override public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        

        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! EPCalendarCell1
    
        
        if window {
            calendarDelegate?.epCalendarPicker!(self, didSelectDate: cell.currentDate)
            cell.selectedForLabelColor(dateSelectionColor)
          //  dismissViewControllerAnimated(true, completion: nil)
           // return
        }
        
       
        if cell.isCellSelectable!
        {
            if  !arrSelectedDates.isEmpty && !multiSelectEnabled {
                
                if !arrSelectedIndexPath.isEmpty{
                let cell1 = collectionView.cellForItemAtIndexPath(arrSelectedIndexPath[arrSelectedDates[0]]!) as? EPCalendarCell1
                
                    if cell1 != nil
                    {
                    
                        if cell1!.currentDate.isSaturday() || cell1!.currentDate.isSunday() {
                            cell1!.deSelectedForLabelColor(weekendTintColor)
                        }
                        else {
                            cell1!.deSelectedForLabelColor(weekdayTintColor)
                        }
                        if cell1!.currentDate.isToday() {
                            cell1!.setTodayCellColor(todayTintColor)
                        }
                        if(arrEvents.contains(cell1!.currentDate))
                        {
                            cell1!.setEventCellColor(UIColor.redColor())
                            cell1?.showEvents()
                        }
                        
                    }
                    arrSelectedDates.removeAll()
                }
            }
          
            if   (multiSelectEnabled || arrSelectedDates.isEmpty) && arrSelectedDates.filter(
                { $0.isDateSameDay(cell.currentDate)
            }).count == 0
            {
             
                
                
                arrSelectedDates.append(cell.currentDate)
                arrSelectedIndexPath.updateValue(indexPath,forKey: cell.currentDate)
                cell.selectedForLabelColor(dateSelectionColor)
                
                if cell.currentDate.isToday()
                {
                    cell.setTodayCellColor(dateSelectionColor)
                }
            }
            else
            {
                arrSelectedDates = arrSelectedDates.filter(){
                    return  !($0.isDateSameDay(cell.currentDate))
                }
                if cell.currentDate.isSaturday() || cell.currentDate.isSunday() {
                    cell.deSelectedForLabelColor(weekendTintColor)
                }
                else {
                    cell.deSelectedForLabelColor(weekdayTintColor)
                }
                if cell.currentDate.isToday() {
                    cell.setTodayCellColor(todayTintColor)
                }
            }
            
            
        }
        
        
        
    }
    
    //MARK: Действия кнопок
    
    internal func onTouchCancelButton() {
       //TODO: Create a cancel delegate
        calendarDelegate?.epCalendarPicker!(self, didCancel: NSError(domain: "EPCalendarPickerErrorDomain", code: 2, userInfo: [ NSLocalizedDescriptionKey: "User Canceled Selection"]))
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    internal func onTouchDoneButton() {
        //gathers all the selected dates and pass it to the delegate

        
            calendarDelegate?.epCalendarPicker!(self, didSelectDate: arrSelectedDates[0])
            dismissViewControllerAnimated(true, completion: nil)
        
        if multiSelectEnabled {
        calendarDelegate?.epCalendarPicker!(self, didSelectMultipleDate: arrSelectedDates)
        dismissViewControllerAnimated(true, completion: nil)
        }
    }


    internal func onAddEventTouch() {
        
        let alertView = UIAlertController(title: "You need to print event name", message: "Please enter your event name! ", preferredStyle: .Alert)
    
        alertView.addTextFieldWithConfigurationHandler({ textField -> Void in
            textField.placeholder = "Event name"
            })
        
        alertView.addAction(UIAlertAction(title: "Done", style: .Default, handler: { (alertAction) -> Void in
           self.createEvent(((alertView.textFields?[0])! as UITextField).text!)
        }))
        alertView.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
        
    }
    
    //MARK: Работа с Event
    
    //создание события
    public func createEvent(eventname :String){
        
       self.aboutEvents.updateValue(eventname,forKey: arrSelectedDates[0])
       self.arrEvents.append(arrSelectedDates[0])
                let cell1 = collectionView!.cellForItemAtIndexPath(arrSelectedIndexPath[arrSelectedDates[0]]!) as! EPCalendarCell1
        cell1.isCellFirstEvent =  true
         cell1.isCellSecondEvent = false
         cell1.isCellThirdEvent = false
        
   
       
    }
    //показ события
    internal func onShowEventTouch() {
     

     let alertView = UIAlertController(title: "Your event", message: aboutEvents[arrSelectedDates[0]] , preferredStyle: .Alert)
        
        alertView.addAction(UIAlertAction(title: "Done", style: .Default, handler: { (alertAction) -> Void in
        }))

        presentViewController(alertView, animated: true, completion: nil)
        
    }
    //промотка до текущего дня
    public func scrollToToday () {
        let today = NSDate()
        scrollToMonthForDate(today)
    }
    //промотка до текущего месяца
    public func scrollToMonthForDate (date: NSDate) {

        let month = date.month()
        let year = date.year()
        let section = ((year - startYear) * 12) + month
        let indexPath = NSIndexPath(forRow:1, inSection: section-1)
        
        self.collectionView?.scrollToIndexpathByShowingHeader(indexPath)
    }
    

    
    
}
