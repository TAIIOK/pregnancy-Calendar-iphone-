//
//  loadJson.swift
//  Календарь беременности
//
//  Created by Roman Efimov on 03.06.16.
//  Copyright © 2016 deck. All rights reserved.
//

import Foundation
import CoreData

func NamesJSON(){
    if let path = NSBundle.mainBundle().pathForResource("names", ofType: "json") {
        do {
            let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            do {
                let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                if let Man : [NSDictionary] = jsonResult["мужские"] as? [NSDictionary] {
                    for mans: NSDictionary in Man {
                        let name = mans.valueForKey("имя")
                        name!.dataUsingEncoding(NSUTF8StringEncoding)
                        if let d = name {
                            man.append(Names(name: d as! String, value: "\(mans.valueForKey("значение")!)", about: "\(mans.valueForKey("описание")!)"))
                            NSNotificationCenter.defaultCenter().postNotificationName("LoadNameTable", object: nil)                        }
                    }
                }
                if let Man : [NSDictionary] = jsonResult["женские"] as? [NSDictionary] {
                    for mans: NSDictionary in Man {
                        let name = mans.valueForKey("имя")
                        name!.dataUsingEncoding(NSUTF8StringEncoding)
                        if let d = name {
                            woman.append(Names(name: d as! String, value: "\(mans.valueForKey("значение")!)", about: "\(mans.valueForKey("описание")!)"))
                            NSNotificationCenter.defaultCenter().postNotificationName("LoadNameTable", object: nil)
                        }
                    }
                }
                
            } catch {}
        } catch {}
    }
}

func AddSect(names: [Names]) -> [(index: Int, length :Int, title: String)] {
    var sect: [(index: Int, length :Int, title: String)] = Array()
    var first = String()
    var second = String()
    var appended = [String]()
    for ( var i = 0; i < names.count; i += 1 ){
        
        let string = names[i].name.uppercaseString;
        let firstCharacter = string[string.startIndex]
        first = "\(firstCharacter)"
        
        if !appended.contains(first) && i+1 == names.count {
            let newSection = (index: i, length: 1, title: first)
            sect.append(newSection)
            appended.append(first)
        }
        
        for ( var j = i+1; j < names.count; j += 1 ){
            let s = names[j].name.uppercaseString;
            let fc = s[s.startIndex]
            second = "\(fc)"
            
            if !appended.contains(first) && first != second {
                let newSection = (index: i, length: j - i, title: first)
                sect.append(newSection)
                i = j-1
                j = names.count
                appended.append(first)
            }
            if !appended.contains(first) && first == second && j+1 == names.count {
                let newSection = (index: i, length: j - i + 1, title: first)
                sect.append(newSection)
                appended.append(first)
            }
        }
    }
    return sect
}

func loadPhotos(){
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
        photos.removeAll()
        uzis.removeAll()
        var table = Table("Photo")
        let date = Expression<String>("Date")
        let image = Expression<Blob>("Image")
        let type = Expression<Int64>("Type")
        let text = Expression<String>("Text")
        
        for i in try! db.prepare(table.select(date,image,type,text)) {
            let a = i[image]
            let c = NSData(bytes: a.bytes, length: a.bytes.count)
            let b = i[date]
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
            print(dateFormatter.dateFromString(b)!)
            photos.append(Photo(image: UIImage(data: c)!, date: dateFormatter.dateFromString(b)!, text: i[text]))
            NSNotificationCenter.defaultCenter().postNotificationName("LoadPhoto", object: nil)
        }
        
        table = Table("Uzi")
        for i in try! db.prepare(table.select(date,image,type,text)) {
            let a = i[image]
            let c = NSData(bytes: a.bytes, length: a.bytes.count)
            let b = i[date]
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
            uzis.append(Photo(image: UIImage(data: c)!, date: dateFormatter.dateFromString(b)!, text: i[text]))
            NSNotificationCenter.defaultCenter().postNotificationName("LoadPhoto", object: nil)
        }
    }
}

func NotificationJSON(){
    if not.count == 0{
        let table = Table("Notification")
        let Day = Expression<Int64>("Day")
        let Category = Expression<Int64>("CategoryId")
        let Text = Expression<String>("Text")
        for tmp in try! db.prepare(table.select(Day, Category, Text)){
            not.append(notification(day: Int(tmp[Day]), text: tmp[Text], category: Int(tmp[Category])-1))
            NSNotificationCenter.defaultCenter().postNotificationName("loadNotification", object: nil)
        }
        /*if let path = NSBundle.mainBundle().pathForResource("notifi", ofType: "json") {
         do {
         let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
         do {
         let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
         if let Man : [NSDictionary] = jsonResult["reminder"] as? [NSDictionary] {
         for mans: NSDictionary in Man {
         let day = mans.valueForKey("день")
         day!.dataUsingEncoding(NSUTF8StringEncoding)
         if let d = day {
         not.append(notifi(day: d as! String, generalInformation: "\(mans.valueForKey("Общая информация")!)", healthMother: "\(mans.valueForKey("Здоровье мамы")!)", healthBaby: "\(mans.valueForKey("Здоровье малыша")!)", food: "\(mans.valueForKey("питание")!)", important: "\(mans.valueForKey("Это важно!")!)", HidenAdvertisment: "\(mans.valueForKey("Скрытая реклама")!)", advertisment: "\(mans.valueForKey("реклама ФЭСТ")!)", reflectionsPregnant: "\(mans.valueForKey("размышления беременной")!)"))
         NSNotificationCenter.defaultCenter().postNotificationName("loadNotification", object: nil)
         }
         }
         }
         } catch {}
         } catch {}
         }*/
    }
}

func PointsJSON(){
    points.append(Points(city: "",address: "",trade_point: "WILDBERRIES",phone: "",longitude: 0.0,latitude: 0.0))
    nearPoints.append(Points(city: "",address: "",trade_point: "WILDBERRIES",phone: "",longitude: 0.0,latitude: 0.0))
    if let path = NSBundle.mainBundle().pathForResource("points", ofType: "json") {
        do {
            let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            do {
                let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                if let point : [NSDictionary] = jsonResult["points"] as? [NSDictionary] {
                    for Point: NSDictionary in point {
                        let address = Point.valueForKey("address")
                        address!.dataUsingEncoding(NSUTF8StringEncoding)
                        if let d = address {
                            
                            points.append(Points(city: "\(Point.valueForKey("city")!)",address: d as! String,trade_point: "\(Point.valueForKey("trade_point")!)",phone: "\(Point.valueForKey("phone")!)",longitude: (Point.valueForKey("coord_last_latitude") as? Double)! ,latitude:(Point.valueForKey("coord_first_longtitude") as? Double)!))
                            NSNotificationCenter.defaultCenter().postNotificationName("loadPoints", object: nil)
                            
                        }
                    }
                }
            } catch {}
        } catch {}
    }
}



func LoadZadiacJSON(){
    if let path = NSBundle.mainBundle().pathForResource("zodiacs", ofType: "json") {
        do {
            let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            do {
                let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                if let zodiac : [NSDictionary] = jsonResult["Знаки"] as? [NSDictionary] {
                    for Zodiacs: NSDictionary in zodiac {
                        let name = Zodiacs.valueForKey("Знак")
                        name!.dataUsingEncoding(NSUTF8StringEncoding)
                        if let d = name {
                            zodiacs.append(Zodiac(name: d as! String, element: "\(Zodiacs.valueForKey("Стихия")!)", about: "\(Zodiacs.valueForKey("Описание")!)"))
                        }
                    }
                }
            } catch {}
        } catch {}
    }
}

func loadBirthDate(){
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
                BirthDate = date.valueForKey("date") as! NSDate
                dateType = date.valueForKey("type") as! Int
            }
        }
    } catch {
        let fetchError = error as NSError
        print(fetchError)
    }
}

