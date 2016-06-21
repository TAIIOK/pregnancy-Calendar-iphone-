//
//  ImageFromCalendar.swift
//  Календарь беременности
//
//  Created by deck on 18.05.16.
//  Copyright © 2016 deck. All rights reserved.
//

import Foundation


public class ImageFromCalendar {
    
    class func ShowCalendarImages(date: NSDate) -> (Bool, Bool, Bool) {
        return (bell(date), calendar(date), camera(date))
    }
    
    
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
