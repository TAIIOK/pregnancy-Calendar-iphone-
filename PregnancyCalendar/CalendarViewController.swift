//
//  CalendarTableViewController.swift
//  rodicalc
//
//  Created by deck on 25.02.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit
import CoreData

var selectedCalendarDate = NSDate()
class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, EPCalendarPickerDelegate {

    @IBOutlet weak var calendar: UIView!
    @IBOutlet weak var testview: UIView!
    @IBOutlet weak var tbl: UITableView!
    var shouldShowDaysOut = true
    var animationFinished = true
    var BirthDate = NSDate()
    var day: Int = 0
    
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
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDate()
        self.setupSidebarMenu()
        self.setupCalendar()
        let img  = UIImage(named: "menu")
        let btn = UIBarButtonItem(image: img , style: UIBarButtonItemStyle.Bordered, target: self.revealViewController(), action: "revealToggle:")
        self.navigationItem.leftBarButtonItem = btn
        let btnBack = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = btnBack
        tbl.delegate = self
        tbl.dataSource = self
        tbl.backgroundColor = .clearColor()
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadNotification:", name:"loadNotification", object: nil)
    }
    
    func loadNotification(notification: NSNotification){
        dispatch_async(dispatch_get_main_queue(), {
            self.tbl.reloadData()
            return
        })
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
        tbl.reloadData()
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
       dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
    
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Заметки"
            let count = self.returnCount(0)
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
            let count = self.returnCount(1)
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
                count = self.returnCount(2)
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

   
                })
        return cell

    }
    
 
    func returnCount(number: Int) -> Int{
        var count = 0
        var Select = selectedCalendarDate

        switch number {
        case 0: //заметки
            var table = Table("TextNote")
            let Date = Expression<String>("Date")
            count += try db.scalar(table.filter(Date == "\(Select)").count)
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
            day = 300 - BirthDate.daysFrom(Select)
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
            fromCalendar = true
            let notes = self.storyboard?.instantiateViewControllerWithIdentifier("NotesNavigationController")
            self.revealViewController().pushFrontViewController(notes!, animated: true)
            break
        case 1:
            //cell.textLabel?.text = "Фотографии"
            let photo = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoFromCalendarNavigation1")
            //self.splitViewController?.showDetailViewController(photo!, sender: self)
            self.revealViewController()?.pushFrontViewController(photo!, animated: true)
            break
        case 2:
            //cell.textLabel?.text = "Уведомления"
            fromCalendar = true
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



