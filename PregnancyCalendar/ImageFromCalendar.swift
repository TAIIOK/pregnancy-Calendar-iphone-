//
//  ImageFromCalendar.swift
//  Календарь беременности
//
//  Created by deck on 18.05.16.
//  Copyright © 2016 deck. All rights reserved.
//

import Foundation


var bells = [NSDate]()
var calendars = [NSDate]()
var cameras = [NSDate]()

func fillbells(){
    var table = Table("DoctorVisit")
    let Date = Expression<String>("Date")
    let isRemind = Expression<Bool>("isRemind")
    let calendar = NSCalendar.currentCalendar()
    
    for i in try! db.prepare(table.select(Date, isRemind)) {
        let b = i[Date]
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        let componentsCurrent = calendar.components([.Day , .Month , .Year], fromDate: dateFormatter.dateFromString(b)!)
        if i[isRemind] == true{
            let components = calendar.components([.Day , .Month , .Year], fromDate: dateFormatter.dateFromString(b)!)
            components.hour = 00
            components.minute = 00
            components.second = 00
            let newDate = calendar.dateFromComponents(components)
            bells.append(newDate!)
        }
    }
    
    table = Table("MedicineTake")
    let name = Expression<String>("Name")
    let start = Expression<String>("Start")
    let end = Expression<String>("End")
    
    
    for i in try! db.prepare(table.select(start,end, isRemind)) {
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
        
        var date = newDateS
        
        while (date?.compare(newDateE!) == NSComparisonResult.OrderedAscending || date?.compare(newDateE!) == NSComparisonResult.OrderedSame) && i[isRemind] == true{
            bells.append(date!)
            date = addDaystoGivenDate(date!, NumberOfDaysToAdd: 1)
        }
    }
}

func fillcalendar(){

    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
    var table = Table("TextNote")
    let Date = Expression<String>("Date")
    //count += try db.scalar(table.filter(Date == "\(date)").count)
    for i in try! db.prepare(table.select(Date)) {
        let b = i[Date]
        calendars.append(dateFormatter.dateFromString(b)!)
    }
    
    table = Table("WeightNote")
    //count += try db.scalar(table.filter(Date == "\(date)").count)
    for i in try! db.prepare(table.select(Date)) {
        let b = i[Date]
        calendars.append(dateFormatter.dateFromString(b)!)
    }
    table = Table("DoctorVisit")
    let calendar = NSCalendar.currentCalendar()
    
    for i in try! db.prepare(table.select(Date)) {
        let b = i[Date]
        let components = calendar.components([.Day , .Month , .Year], fromDate: dateFormatter.dateFromString(b)!)
        components.hour = 00
        components.minute = 00
        components.second = 00
        let newDate = calendar.dateFromComponents(components)
        calendars.append(newDate!)
    }
    
    table = Table("Food")
    for i in try! db.prepare(table.select(Date)) {
        let b = i[Date]
        calendars.append(dateFormatter.dateFromString(b)!)
    }
    
    table = Table("MedicineTake")
    let start = Expression<String>("Start")
    let end = Expression<String>("End")
    
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
        
        var date = newDateS
        
        while (date?.compare(newDateE!) == NSComparisonResult.OrderedAscending || date?.compare(newDateE!) == NSComparisonResult.OrderedSame){
            calendars.append(date!)
            date = addDaystoGivenDate(date!, NumberOfDaysToAdd: 1)
        }
    }
}

func fillcamera(){
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
    var table = Table("Photo")
    let Date = Expression<String>("Date")
    //count += try db.scalar(table.filter(Date == "\(date)").count)
    for i in try! db.prepare(table.select(Date)) {
        let b = i[Date]
        cameras.append(dateFormatter.dateFromString(b)!)
    }
    
    table = Table("Uzi")
    for i in try! db.prepare(table.select(Date)) {
        let b = i[Date]
        cameras.append(dateFormatter.dateFromString(b)!)
    }
    //count += try db.scalar(table.filter(Date == "\(date)").count)
}

public class ImageFromCalendar {
    
    class func ShowCalendarImages(date: NSDate) -> (Bool, Bool, Bool) {
        var a = false
        var b = false
        var c = false
        //dispatch_async(dispatch_get_main_queue(), {
        a = bells.contains(date)
        b = calendars.contains(date)
        c = cameras.contains(date)
        //  })
        return (a, b, c)
    }

    /*class func ShowCalendarImages(date: NSDate) -> (Bool, Bool, Bool) {
        var a = false
        var b = false
        var c = false
        //dispatch_async(dispatch_get_main_queue(), {
        a = self.bell(date)
        b = self.calendar(date)
        c = self.camera(date)
          //  })
        return (a, b, c)
    }*/
    
    
    class func bell(date: NSDate) -> Bool {
        var showBell = false
        var table = Table("DoctorVisit")
        let Date = Expression<String>("Date")
        let isRemind = Expression<Bool>("isRemind")
        let calendar = NSCalendar.currentCalendar()
        var components = calendar.components([.Day , .Month , .Year], fromDate: date)
        
        for i in try! db.prepare(table.select(Date, isRemind)) {
            let b = i[Date]
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
            let componentsCurrent = calendar.components([.Day , .Month , .Year], fromDate: dateFormatter.dateFromString(b)!)
            if components.day == componentsCurrent.day && components.month == componentsCurrent.month && components.year == componentsCurrent.year && i[isRemind] == true{
                showBell = true
            }
        }

        table = Table("MedicineTake")
        let name = Expression<String>("Name")
        let start = Expression<String>("Start")
        let end = Expression<String>("End")
    
        components = calendar.components([.Day , .Month , .Year], fromDate: date)
        components.hour = 00
        components.minute = 00
        components.second = 00
        let newcurDate = calendar.dateFromComponents(components)
    
        for i in try! db.prepare(table.select(start,end, isRemind)) {
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
            if (a == NSComparisonResult.OrderedDescending || a == NSComparisonResult.OrderedSame) && (b == NSComparisonResult.OrderedAscending || b == NSComparisonResult.OrderedSame) && i[isRemind] == true{
                showBell = true
            }
        }
        return showBell
    }
    class func calendar(date: NSDate) -> Bool{
        var showCalendar = false
        var count = 0
        var table = Table("TextNote")
        let Date = Expression<String>("Date")
        count += try db.scalar(table.filter(Date == "\(date)").count)
        table = Table("WeightNote")
        count += try db.scalar(table.filter(Date == "\(date)").count)
        
        table = Table("DoctorVisit")
        let calendar = NSCalendar.currentCalendar()
        var components = calendar.components([.Day , .Month , .Year], fromDate: date)
        
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
        count += try db.scalar(table.filter(Date == "\(date)").count)
        
        table = Table("MedicineTake")
        let start = Expression<String>("Start")
        let end = Expression<String>("End")
        
        components = calendar.components([.Day , .Month , .Year], fromDate: date)
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
            showCalendar = true
        }
        
        return showCalendar
    }
    class func camera(date: NSDate) -> Bool{
        var showCamera = false
        var count = 0
        var table = Table("Photo")
        let Date = Expression<String>("Date")
        count += try db.scalar(table.filter(Date == "\(date)").count)
        
        table = Table("Uzi")
        count += try db.scalar(table.filter(Date == "\(date)").count)
        if count > 0 {
            showCamera = true
        }
        return showCamera
    }
}
