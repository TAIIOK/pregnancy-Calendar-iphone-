//
//  Notifications.swift
//  Календарь беременности
//
//  Created by Roman Efimov on 31.05.16.
//  Copyright © 2016 deck. All rights reserved.
//

import Foundation

let lolnotifies = ["92","204","241","260","22","57","71","85","120","134","155","165","169","217", "239", "261", "267"]
let urlnotifies = ["http://www.aist-k.com/forum/?PAGE_NAME=message&FID=54&TID=1947&TITLE_SEO=1947&MID=18262#message18262",
                   "http://www.aist-k.com/forum/?PAGE_NAME=message&FID=39&TID=1221&TITLE_SEO=1221&MID=12419#message12419",
                   "http://www.aist-k.com/forum/?PAGE_NAME=read&FID=38&TID=603&TITLE_SEO=603&PAGEN_1=2",
                   "http://www.aist-k.com/forum/?PAGE_NAME=message&FID=39&TID=1221&TITLE_SEO=1221&MID=12419#message12419",
                   "http://www.aist-k.com/forum/?PAGE_NAME=message&FID=42&TID=659&TITLE_SEO=659&MID=5299#message5299",
                   "http://www.aist-k.com/forum/?PAGE_NAME=message&FID=42&TID=659&TITLE_SEO=659&MID=5299#message5299",
                   "http://www.aist-k.com/forum/?PAGE_NAME=message&FID=42&TID=659&TITLE_SEO=659&MID=5299#message5299",
                   "http://www.mama-fest.com/issledovaniya_akusherov_ginekologov/",
                   "http://www.aist-k.com/forum/?PAGE_NAME=message&FID=31&TID=4325&TITLE_SEO=4325&MID=42669#message42669",
                   "http://www.mama-fest.com/issledovaniya_akusherov_ginekologov/",
                   "http://www.aist-k.com/forum/?PAGE_NAME=message&FID=54&TID=2457&TITLE_SEO=2457&MID=22350#message22350",
                   "http://www.aist-k.com/forum/?PAGE_NAME=message&FID=54&TID=2457&TITLE_SEO=2457&MID=22350#message22350",
                   "http://www.mama-fest.com/issledovaniya_akusherov_ginekologov/",
                   "http://www.mama-fest.com/issledovaniya_akusherov_ginekologov/",
                   "http://www.mama-fest.com/issledovaniya_akusherov_ginekologov/",
                   "http://www.aist-k.com/forum/?PAGE_NAME=message&FID=39&TID=1221&TITLE_SEO=1221&MID=12419#message1241961",
                   "http://www.aist-k.com/forum/?PAGE_NAME=read&FID=8&TID=3686&TITLE_SEO=3686"]
var notifications = [notification]()

/*func WorkWithJSON(){
    if notifications.count == 0{
        if let path = NSBundle.mainBundle().pathForResource("notifi", ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                do {
                    let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    if let Man : [NSDictionary] = jsonResult["reminder"] as? [NSDictionary] {
                        for mans: NSDictionary in Man {
                            let day = mans.valueForKey("день")
                            day!.dataUsingEncoding(NSUTF8StringEncoding)
                            if let d = day {
                                notifications.append(notifi(day: d as! String, generalInformation: "\(mans.valueForKey("Общая информация")!)", healthMother: "\(mans.valueForKey("Здоровье мамы")!)", healthBaby: "\(mans.valueForKey("Здоровье малыша")!)", food: "\(mans.valueForKey("питание")!)", important: "\(mans.valueForKey("Это важно!")!)", HidenAdvertisment: "\(mans.valueForKey("Скрытая реклама")!)", advertisment: "\(mans.valueForKey("реклама ФЭСТ")!)", reflectionsPregnant: "\(mans.valueForKey("размышления беременной")!)"))
                            }
                        }
                    }
                } catch {}
            } catch {}
        }
    }
}*/

func addDaystoGivenDate(baseDate: NSDate, NumberOfDaysToAdd: Int) -> NSDate
{
    let dateComponents = NSDateComponents()
    let CurrentCalendar = NSCalendar.currentCalendar()
    let CalendarOption = NSCalendarOptions()
    
    dateComponents.day = NumberOfDaysToAdd
    let newDate = CurrentCalendar.dateByAddingComponents(dateComponents, toDate: baseDate, options: CalendarOption)
    return newDate!
}

func calculateDay(date: NSDate) -> Int{
    var newBirthDate = BirthDate
    if dateType == 0{
        newBirthDate = addDaystoGivenDate(BirthDate, NumberOfDaysToAdd: 7*38)
    }
    else if dateType == 1{
        newBirthDate  = addDaystoGivenDate(BirthDate, NumberOfDaysToAdd: 7*40)
    }
    
    let num = (addDaystoGivenDate(newBirthDate, NumberOfDaysToAdd: -(40*7)))
    
    return  date.daysFrom(num)
}

func loadNotifi() {
    print("-----------do-------")
    allnotif()
    cancelAllLocalNotification()
    UIApplication.sharedApplication().applicationIconBadgeNumber = 1
    UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    //UIApplication.sharedApplication().cancelAllLocalNotifications()
    
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Day , .Month , .Year], fromDate: BirthDate)
    
    var newBirthDate = BirthDate
    if dateType == 0{
        newBirthDate = addDaystoGivenDate(BirthDate, NumberOfDaysToAdd: 7*38)
    }
    else if dateType == 1{
        newBirthDate  = addDaystoGivenDate(BirthDate, NumberOfDaysToAdd: 7*40)
    }
    
    let num = (addDaystoGivenDate(newBirthDate, NumberOfDaysToAdd: -(40*7)))
    

    let app: UIApplication = UIApplication.sharedApplication()

  
   
    var Notificalendar = NSDate()

    notifications.removeAll()
    let table = Table("Notification")
    let Day = Expression<Int64>("Day")
    let Category = Expression<Int64>("CategoryId")
    let Text = Expression<String>("Text")
    for tmp in try! db.prepare(table.select(Day, Category, Text)){
        notifications.append(notification(day: Int(tmp[Day]), text: tmp[Text], category: Int(tmp[Category]-1)))
    }
    
    var day = NSDate().daysFrom(num)
    if day < 0{
        day = 0
    }

    if day == 0 || day > 1{
        var notification = ""
        var titles = ""
        notification = notifications[0].text
        titles = notifiCategory[notifications[0].category]
        
        let components = calendar.components([.Day , .Month , .Year], fromDate: Notificalendar)
        
        let localNotification = UILocalNotification()
        if components.hour > 12{
            localNotification.fireDate = NSDate(timeIntervalSinceNow: 30) // время получения уведомления
        }
        else {
            components.hour = 12
            components.minute = 0
            Notificalendar = calendar.dateFromComponents(components)!
            localNotification.fireDate = Notificalendar // время получения уведомления
        }
        
        localNotification.alertBody = notification
        
        let infoDict :  Dictionary<String,String!> = ["objectId" : "-2"]
        localNotification.userInfo = infoDict
        localNotification.alertAction = "View"
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    for (var i = day; i <=  300; i += 1){
        var notification = [String]()
        var titles = [Int]()
        for k in notifications{
            if k.day == i{
                notification.append(k.text)
                titles.append(k.category)
            }
        }
        notification.append("\(i)")

        let components = calendar.components([.Day , .Month , .Year], fromDate: Notificalendar)
        
        for (var j = 0 ; j < notification.count-1 ; j += 1){
            let localNotification = UILocalNotification()
            //localNotification.category = "adolf"
            if (components.hour > 12 && i == NSDate().daysFrom(num)){
                localNotification.fireDate = NSDate(timeIntervalSinceNow: 60 + Double(j) * 60) // время получения уведомления
            }
            else {
                components.hour = 12
                components.minute = j
                Notificalendar = calendar.dateFromComponents(components)!
                localNotification.fireDate = Notificalendar // время получения уведомления
            }
            if(notification[j].isEmpty || notification[j].characters.count < 4)
            {
                continue
            }

            
            localNotification.alertBody = notification[j]

            if(lolnotifies.contains(notification[notification.count-1]) && (titles[j] == 5 || titles[j] == 6))
            {
                let infoDict :  Dictionary<String,String!> = ["objectId" : notification[notification.count-1]]
                // var infoDict = ["objectId" : notification[8]]
                localNotification.userInfo = infoDict
            }else{
                let infoDict :  Dictionary<String,String!> = ["objectId" : "-1"]
                localNotification.userInfo = infoDict
            }
            print(localNotification.userInfo)
            localNotification.alertAction = "View"
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
        notification.removeAll()
        titles.removeAll()
        Notificalendar = addDaystoGivenDate(Notificalendar,NumberOfDaysToAdd: 1)
    }
    print("-----------posle-------")
    allnotif()
}

func allnotif(){
    var count = 0
    guard
        let app: UIApplication = UIApplication.sharedApplication(),
        let notifications = app.scheduledLocalNotifications else { return }
    for notification in notifications {
        count += 1
        //print(notification.userInfo as? [String: String],notification.alertBody!)
    }
    print("count = \(count)")
}


func cancelAllLocalNotification(){
    let list = ["-2","-1","36","44","52","57","59","64","71","77","78","80","85","92","98","106","112","115","138","141","149","162","176","197","200","204","205","209","215","228","241","244","253","260","22","50","61","99","102","106","113","120","127","134","148","151","155","165","169","183","190","194","210","217","224","226","232","239","252","261","265","267"]
    
    guard
        let app: UIApplication = UIApplication.sharedApplication(),
        let notifications = app.scheduledLocalNotifications else { return }
    for notification in notifications {
        
        if
            let userInfo = notification.userInfo,
            let uid: [String: String] = userInfo as? [String: String] where list.contains(uid["objectId"]!)
        {
            app.cancelLocalNotification(notification)
            //print("Deleted local notification for '\(uid["objectId"]!)'")
        }
    }
    print("All local notification deleted")
}


func cancelLocalNotification(uniqueId: String){

    guard
        let app: UIApplication = UIApplication.sharedApplication(),
        let notifications = app.scheduledLocalNotifications else { return }
    for notification in notifications {

        if
            let userInfo = notification.userInfo,
            let uid: [String: String] = userInfo as? [String: String] where uid["objectId"] == uniqueId {
            app.cancelLocalNotification(notification)
            print("Deleted local notification for '\(uniqueId)'")
        }
       

    }
}

func scheduleNotification(notifiDate :NSDate, notificationTitle:String, objectId:String) {
    
    let localNotification = UILocalNotification()
    localNotification.fireDate = notifiDate
    localNotification.alertBody = notificationTitle
    localNotification.timeZone = NSTimeZone.defaultTimeZone()
    localNotification.applicationIconBadgeNumber = 1
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.alertAction = "View"
    let infoDict :  Dictionary<String,String!> = ["objectId" : objectId]
    localNotification.userInfo = infoDict
    
    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
}
