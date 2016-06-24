//
//  MenuTableViewController.swift
//  PregnancyCalendar
//
//  Created by farestz on 25.02.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    let menus = ["","ДАТА РОДОВ", "СПРАВОЧНИК ИМЕН", "СЧЕТЧИК СХВАТОК", "ГРАФИК НАБОРА ВЕСА", "ФОТОАЛЬБОМ", "ВИДЕОТЕКА", "ЗАМЕТКИ", "ФОРУМ", "ПОЛЕЗНЫЙ ОПЫТ", "КАЛЕНДАРЬ", "КУПИТЬ БЕЛЬЕ ФЭСТ", "ЭКСПОРТ"]
    let imgs = ["","Gantt Chart-50", "Resume-50", "Alarm Clock-50", "Line Chart-50", "Compact Camera-50", "Video Call-50", "Note-Memo-01-256", "Chat-64", "Diamond-50", "Calendar-50", "Shopping Bag-50", "Share-50"]
    
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.backgroundView = UIImageView(image: UIImage(named: "background_left.png"))
        table.backgroundColor = .clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func pushFrontViewController(identifer: String) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier(identifer) as? UINavigationController
        self.revealViewController().pushFrontViewController(controller, animated: true)
    }
    
    private func getCustomizeBackgroundView() -> UIView {
        let backgroundView = UIView()
        backgroundView.backgroundColor = StrawBerryColor
        return backgroundView
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menus.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row) {
        case 1:
            self.pushFrontViewController("BirthdateNavigationController")
            break
        case 2:
            self.pushFrontViewController("NamesNavController")
            break
        case 3:
            self.pushFrontViewController("SpasmsNavigationController")
            break
        case 4:
            self.pushFrontViewController("WeightGraphNavigationController")
            break
        case 5:
            self.pushFrontViewController("PhotoNavigationController")
            break
        case 6:
            self.pushFrontViewController("VideoNavigationController")
            break
        case 7:
            self.pushFrontViewController("NotesNavigationController")
            break
        case 8:
            self.pushFrontViewController("ForumNavigationController")
            break
        case 9:
            self.pushFrontViewController("ExperienceNavigationController")
            break
        case 10:
            self.pushFrontViewController("CalendarViewController")
            break
        case 11:
            self.pushFrontViewController("BuyNavigationController")
        case 12:
            self.pushFrontViewController("ExportNav")
            break
        default:
            break
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 80
        }else{
            return 40
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("menuLogoCell", forIndexPath: indexPath)
            cell.backgroundView?.backgroundColor = .clearColor()
            cell.selectedBackgroundView?.backgroundColor = .clearColor()
            return cell
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier("menuCell", forIndexPath: indexPath) as! MenuTableViewCell
            cell.label?.text = self.menus[indexPath.row]
            cell.label?.textColor = StrawBerryColor
            cell.label?.highlightedTextColor = .whiteColor()
            cell.label?.backgroundColor = .clearColor()
            cell.img?.image = UIImage(named: "\(imgs[indexPath.row]) (1)")
            cell.img?.highlightedImage = UIImage(named: "\(imgs[indexPath.row])")
            cell.backgroundView?.backgroundColor = .clearColor()
            cell.selectedBackgroundView = self.getCustomizeBackgroundView()
            return cell
        }
    }
}