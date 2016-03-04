//
//  MenuTableViewController.swift
//  PregnancyCalendar
//
//  Created by farestz on 25.02.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    let menus = ["ДАТА РОДОВ", "СПРАВОЧНИК ИМЕН", "СЧЕТЧИК СХВАТОК", "ГРАФИК НАБОРА ВЕСА", "ФОТОАЛЬБОМ", "ВИДЕОТЕКА", "ЗАМЕТКИ", "ФОРУМ", "ПОЛЕЗНЫЙ ОПЫТ", "КАЛЕНДАРЬ", "КУПИТЬ БЕЛЬЕ ФЭСТ", "ЭКСПОРТ"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        case 0:
            self.pushFrontViewController("BirthdateNavigationController")
            break
        case 1:
            self.pushFrontViewController("ListNavigationController")
            break
        case 2:
            self.pushFrontViewController("SpasmsNavigationController")
            break
        case 3:
            self.pushFrontViewController("WeightGraphNavigationController")
            break
        case 4:
            self.pushFrontViewController("PhotoNavigationController")
            break
        case 5:
            self.pushFrontViewController("VideoNavigationController")
            break
        case 6:
            self.pushFrontViewController("NotesNavigationController")
            break
        case 7:
            self.pushFrontViewController("ForumNavigationController")
            break
        case 8:
            break
        case 9:
            break
        case 10:
            break
        case 11:
            break
        default:
            break
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("menuCell", forIndexPath: indexPath)
        cell.textLabel?.text = self.menus[indexPath.row]
        cell.textLabel?.textColor = StrawBerryColor
        cell.textLabel?.highlightedTextColor = .whiteColor()
        //cell.imageView?.image = UIImage(named: "menu")
        cell.selectedBackgroundView = self.getCustomizeBackgroundView()
        return cell
    }
}