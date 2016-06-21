//
//  NotifiListTableViewController.swift
//  Календарь беременности
//
//  Created by deck on 12.05.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit

class DrugsListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var table: UITableView!
   
    var firstStart = true
    override func viewDidLoad() {
        super.viewDidLoad()

        table.delegate = self
        table.dataSource = self
        navbar.barTintColor = .whiteColor()
        navbar.tintColor = .blackColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Interval.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("drugsCell", forIndexPath: indexPath) as! NotifiCell
        cell.textLbl.text = Interval[indexPath.row]
        
        if firstStart && indexPath.row == curRemindType{
            cell.setHighlighted(true, animated: false)
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            firstStart = false
        }
        cell.selectedBackgroundView?.backgroundColor = .whiteColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        changeRemindInCurRec = indexPath.row
    }
    
    @IBAction func Cancel(sender: UIBarButtonItem) {
         self.dismissViewControllerAnimated(true, completion: nil)
    }
}
