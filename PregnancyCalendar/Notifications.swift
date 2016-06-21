//
//  Notifications.swift
//  Календарь беременности
//
//  Created by Roman Efimov on 31.05.16.
//  Copyright © 2016 deck. All rights reserved.
//

import Foundation

let lolnotifies = ["92","203","155","165","271","203","210","22","57","71","267","273","247","120"]
var notifications = [notifi]()

func WorkWithJSON(){
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

func loadNotifi() {
    
    cancelAllLocalNotification()
    
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


    WorkWithJSON()
   
    for (var i = NSDate().daysFrom(num) ; i <  notifications.count; i += 1){
        let notifiday = notifications[i]
        var notification = [String]()
        
        notification.append(notifiday.generalInformation)
        notification.append(notifiday.healthMother)
        notification.append(notifiday.healthBaby)
        notification.append(notifiday.food)
        notification.append(notifiday.important)
        notification.append(notifiday.HidenAdvertisment)
        notification.append(notifiday.advertisment)
        notification.append(notifiday.reflectionsPregnant)
        notification.append(notifiday.day)

        let components = calendar.components([.Day , .Month , .Year], fromDate: Notificalendar)
        
        for (var j = 0 ; j < 8 ; j += 1){
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
            

            if(lolnotifies.contains(notification[8]) && j == 5)
            {
                let infoDict :  Dictionary<String,String!> = ["objectId" : notification[8]]
           // var infoDict = ["objectId" : notification[8]]
            localNotification.userInfo = infoDict
            }
            else{
            let infoDict :  Dictionary<String,String!> = ["objectId" : "-1"]
            localNotification.userInfo = infoDict
            }
            localNotification.alertAction = "View"
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            localNotification.soundName = UILocalNotificationDefaultSoundName;
           // localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
        notification.removeAll()
       Notificalendar = addDaystoGivenDate(Notificalendar,NumberOfDaysToAdd: 1)
    }
}



func cancelAllLocalNotification(){
    
    let list = ["-1","92","203","155","165","271","203","210","22","57","71","267","273","247","120"]
    
    guard
        let app: UIApplication = UIApplication.sharedApplication(),
        let notifications = app.scheduledLocalNotifications else { return }
    for notification in notifications {
        
        if
            let userInfo = notification.userInfo,
            let uid: [String: String] = userInfo as? [String: String] where list.contains(uid["objectId"]!) {
            app.cancelLocalNotification(notification)
            print("Deleted local notification")
        }
        
        
    }
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
