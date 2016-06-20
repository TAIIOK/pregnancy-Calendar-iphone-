//
//  BirthDateViewController.swift
//  PregnancyCalendar
//
//  Created by farestz on 25.02.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit
import CoreData

var BirthDate = NSDate()
var dateType = -1
var dateTypeTemp = -1
var Back = false

class BirthDateViewController: UIViewController, EPCalendarPickerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var conceptionDateLabel: UILabel!
    @IBOutlet weak var lastMenstrualPeriod: UILabel!
    @IBOutlet weak var setManually: UILabel!
    
    @IBOutlet weak var tbl: UITableView!
    
    var DateisLoaded = false

    let txt = ["По дате зачатия","По дате последней менструации","По дате, указанной врачем"]
 

    // КАЛЕНДАРЬ
    func epCalendarPicker(_: EPCalendarPicker, didCancel error : NSError) {
        
        
    }
    
    func epCalendarPicker(_: EPCalendarPicker, didSelectDate date : NSDate) {

        BirthDate = date
        tbl.reloadData()
    }
    
    func epCalendarPicker(_: EPCalendarPicker, didSelectMultipleDate dates : [NSDate]) {    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbl.delegate = self
        tbl.dataSource = self
        tbl.backgroundColor = .clearColor()
        loadDate()
        
        if !Back && DateisLoaded{
            Cancel()
        }else{
            self.setupSidebarMenu()
            let img  = UIImage(named: "menu")
            let btn = UIBarButtonItem(image: img , style: UIBarButtonItemStyle.Bordered, target: self.revealViewController(), action: "revealToggle:")
            self.navigationItem.leftBarButtonItem = btn
        }
    }
    
    func Cancel(){
        let zodiac = self.storyboard?.instantiateViewControllerWithIdentifier("ShowZodiac")
        self.revealViewController().pushFrontViewController(zodiac, animated: true)
    }
    
    @IBAction func OK(sender: UIButton) {
        dateType = dateTypeTemp
        saveDate(BirthDate, type: dateType)
        let   alert =  UIAlertController(title: "", message: "Внимание! Обратите внимание, что рассчитанная дата родов является лишь приблизительной, так как течение беременности индивидуально для каждой женщины. По статистике, менее 10% детей рождаются точно в срок, остальные появляются на свет на несколько дней раньше или позже предполагаемой даты родов. Более точную информацию сможет дать наблюдающий Вас врач.", preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Закрыть", style: .Default, handler: { (_) in alert.dismissViewControllerAnimated(true, completion: nil)  } )
        
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return txt.count
    }
    
    func  tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DateCell", forIndexPath: indexPath) as! DateTableViewCell
        cell.textLabel?.text = txt[indexPath.row]
        
        if indexPath.row == dateTypeTemp {
            let date = BirthDate
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Day , .Month , .Year], fromDate: date)
            var string = ""
            if(components.month<10)
            {
                string = "0\(components.month)"
            }
            else
            {
                string = "\(components.month)"
            }
            
            var stringday = ""
            if(components.day<10)
            {
                stringday = "0\(components.day)"
            }
            else
            {
                stringday = "\(components.day)"
            }
            
            cell.detailTextLabel?.text = "\(stringday).\(string).\(components.year)"
            cell.setHighlighted(true, animated: false)
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        }
        else{
            cell.detailTextLabel?.text = "не выбрано"
        }
        cell.backgroundColor = .clearColor()
        cell.tintColor = UIColor.lightGrayColor()
        cell.detailTextLabel?.tintColor = UIColor.lightGrayColor()
        return cell
    }
    
    private func getCustomBackgroundView() -> UIView{
        let BackgroundView = UIView()
        BackgroundView.backgroundColor = UIColor.whiteColor()
        return BackgroundView
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dateTypeTemp = indexPath.row
        let calendarPicker = EPCalendarPicker(startYear: currentyear - 1  , endYear: currentyear + 10, multiSelection: false, selectedDates: [],window: false , scroll: false , scrollDate: NSDate())
        calendarPicker.calendarDelegate = self
        calendarPicker.startDate = NSDate()
        //calendarPicker.hightlightsToday = true
        //calendarPicker.showsTodaysButton = true
        
        calendarPicker.backgroundColor = StrawBerryColor
        calendarPicker.monthTitleColor = UIColor.whiteColor()
        calendarPicker.weekdayTintColor = UIColor.lightGrayColor()
        calendarPicker.weekendTintColor = UIColor.lightGrayColor()
        
        let navigationController = UINavigationController(rootViewController: calendarPicker)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! DateTableViewCell
        cell.selectedBackgroundView=getCustomBackgroundView()
        cell.textLabel?.highlightedTextColor = StrawBerryColor
        cell.detailTextLabel?.highlightedTextColor = StrawBerryColor
        return indexPath
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

    
    func addDaystoGivenDate(baseDate: NSDate, NumberOfDaysToAdd: Int) -> NSDate
    {
        let dateComponents = NSDateComponents()
        let CurrentCalendar = NSCalendar.currentCalendar()
        let CalendarOption = NSCalendarOptions()
        
        dateComponents.day = NumberOfDaysToAdd
        
        let newDate = CurrentCalendar.dateByAddingComponents(dateComponents, toDate: baseDate, options: CalendarOption)
        return newDate!
    }
    
    func addDaystoGivenDates(baseDate: [NSDate], NumberOfDaysToAdd: Int) -> [NSDate]
    {
        var newDates = baseDate
        newDates.removeAll()
        let dateComponents = NSDateComponents()
        let CurrentCalendar = NSCalendar.currentCalendar()
        let CalendarOption = NSCalendarOptions()
        for (var i = 0; i<baseDate.count ; i += 1)
        {
        dateComponents.day = NumberOfDaysToAdd
        
        let newDate = CurrentCalendar.dateByAddingComponents(dateComponents, toDate: baseDate[i], options: CalendarOption)
        newDates.insert(newDate!, atIndex: i)
        }
        return newDates
    }
    
    
    func saveDate(date: NSDate, type: Int){
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("BirthDate", inManagedObjectContext: managedContext)
        
        let BD = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        BD.setValue(date, forKey: "date")
        BD.setValue(type, forKey: "type")
        do {
            try BD.managedObjectContext?.save()
        } catch {
            print(error)
        }
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
                    dateTypeTemp = dateType
                    BirthDate = dte
                    DateisLoaded = true
                }
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        Back = false
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
    