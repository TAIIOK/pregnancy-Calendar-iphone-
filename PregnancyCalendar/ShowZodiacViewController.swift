//
//  ShowZodiacViewController.swift
//  rodicalc
//
//  Created by deck on 04.04.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit

class Zodiac: NSObject {
    var name: String
    var element: String
    var about: String
    init(name: String, element: String, about: String) {
        self.name = name
        self.element = element
        self.about = about
        super.init()
    }
}


class ShowZodiacViewController: UIViewController {

    @IBOutlet weak var birthDate: UILabel!
    @IBOutlet weak var zodiacName: UILabel!
    @IBOutlet weak var zodiacElement: UILabel!
    @IBOutlet weak var zodiacAbout: UITextView!
    @IBOutlet weak var zodiacIcon: UIImageView!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var zodiacs = [Zodiac]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSidebarMenu()
        WorkWithJSON()
        var date = BirthDate//selectedDay.date.convertedDate()!
        if dateType == 0{
            date = addDaystoGivenDate(date, NumberOfDaysToAdd: 7*38)
        }
        else if dateType == 1{
            date = addDaystoGivenDate(date, NumberOfDaysToAdd: 7*40)
        }
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        var month = ""
        switch components.month {
        case 1:
            month = "ЯНВАРЯ"
            break
        case 2:
            month = "ФЕВРАЛЯ"
            break
        case 3:
            month = "МАРТА"
            break
        case 4:
            month = "АПРЕЛЯ"
            break
        case 5:
            month = "МАЯ"
            break
        case 6:
            month = "ИЮНЯ"
            break
        case 7:
            month = "ИЮЛЯ"
            break
        case 8:
            month =  "АВГУСТА"
            break
        case 9:
            month =  "СЕНТЯБРЯ"
            break
        case 10:
            month =  "ОКТЯБРЯ"
            break
        case 11:
            month = "НОЯБРЯ"
            break
        case 12:
            month = "ДЕКАБРЯ"
            break
        default:
            break
        }

        birthDate.text = "\(components.day) \(month) \(components.year) ГОДА"
        let zodiac = searchZodiac(date)
        zodiacName.text = zodiacs[zodiac].name
        zodiacElement.text = zodiacs[zodiac].element
        zodiacAbout.text = zodiacs[zodiac].about
        zodiacIcon.image = UIImage(named: "\(zodiac)z.jpg")
        let btnBack = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = btnBack

    }
    @IBAction func editDate(sender: UIBarButtonItem) {
        Back = true
        self.pushFrontViewController("Birthdate")
    }
    private func pushFrontViewController(identifer: String) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier(identifer)
        //self.revealViewController().pushFrontViewController(controller, animated: true)
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    private func setupSidebarMenu() {
        if self.revealViewController() != nil {
            self.revealViewController().rearViewRevealDisplacement = 0
            self.revealViewController().rearViewRevealOverdraw = 0
            self.revealViewController().rearViewRevealWidth = 275
            self.revealViewController().frontViewShadowRadius = 0
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = "revealToggle:"
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
    
    func searchZodiac(date: NSDate) -> Int{
        
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        
        let year =  components.year
        let month = components.month
        let day = components.day
        
        if((month==3 && day>=21) || (month==4 && day<=19)){
        return 0;
        }
        if((month==4 && day>=20) || (month==5 && day<=21)){
            return 1;
        }
        if((month==5 && day>=22) || (month==6 && day<=21)){
            return 2;
        }
        if((month==6 && day>=22) || (month==7 && day<=22)){
            return 3;
        }
        if((month==7 && day>=23) || (month==8 && day<=22)){
            return 4;
        }
        if((month==8 && day>=23) || (month==9 && day<=22)){
            return 5;
        }
        if((month==9 && day>=23) || (month==10 && day<=22)){
            return 6;
        }
        if((month==10 && day>=23) || (month==11 && day<=22)){
            return 7;
        }
        if((month==11 && day>=23) || (month==12 && day<=22)){
            return 8;
        }
        if((month==12 && day>=22) || (month==1 && day<=20)){
            return 9;
        }
        if((month==1 && day>=21) || (month==2 && day<=18)){
            return 10;
        }
        if((month==2 && day>=19) || (month==3 && day<=20)){
            return 11;
        }
        
        
        
        return 1;
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnEditDate(sender: AnyObject) {
        //Back = true
        //self.navigationController?.navigationBar.backItem?.backBarButtonItem?.enabled = true
        //let date = self.storyboard?.instantiateViewControllerWithIdentifier("BirthDate")
        //self.navigationController?.pushViewController(date!, animated: true)
        /*(if #available(iOS 8.0, *) {
            self.splitViewController?.showDetailViewController(date!, sender: self)
        } else {
            // Fallback on earlier versions
        }*/
    }

    func WorkWithJSON(){
        if let path = NSBundle.mainBundle().pathForResource("zodiacs", ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                do {
                    let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    if let zodiac : [NSDictionary] = jsonResult["Знаки"] as? [NSDictionary] {
                        for Zodiacs: NSDictionary in zodiac {
                            var name = Zodiacs.valueForKey("Знак")
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
}
