//
//  ListTableViewController.swift
//  PregnancyCalendar
//
//  Created by farestz on 25.02.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit

var man = [Names]()
var woman = [Names]()

var choosedName = NSIndexPath() // index of name
var choosedSegmentNames = true // true: boys, false: girls

class Names: NSObject {
    var name: String
    var value: String
    var about: String
    init(name: String, value: String, about: String) {
        self.name = name
        self.value = value
        self.about = about
        super.init()
    }
}

var sections : [(index: Int, length :Int, title: String)] = Array()
var sectionsGirl : [(index: Int, length :Int, title: String)] = Array()

class ListTableViewController: UITableViewController {
    let boyNames = ["Александр", "Алексей", "Тимофей", "Юрий"]
    let girlNames = ["Дарья", "Света", "Софья"]
    
    var jsonResult: NSDictionary!
    var manIndexes: [String] = []
    var womanIndexes: [String] = []
    var choosedName = 0 // index of name
    var choosedSegment = true // true: boys, false: girls
    
    let lettersOfManIndexes = "А Б В Г Д Е И К Л М Н О П Р С Т Ю Я"
    let lettersOfWomanIndexes = "А В Г Д Е Ж З И К Л М Н О П С Т Ю"
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        self.reloadTable(sender.selectedSegmentIndex == 1 ? false : true)
    }
    
    private func reloadTable(index: Bool) {
        self.choosedSegment = index
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSidebarMenu()
        self.setupModifiedTitle()
        self.reloadTable(true)
        self.getNamesFromJSON()
        
        manIndexes = lettersOfManIndexes.componentsSeparatedByString(" ")
        womanIndexes = lettersOfWomanIndexes.componentsSeparatedByString(" ")
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    private func getNamesFromJSON() {
        if let path = NSBundle.mainBundle().pathForResource("names", ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
                jsonResult = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers) as! NSDictionary
                
                print(jsonResult.valueForKey("man")?.valueForKey("Анатолий"))
            } catch {
                print("хуевый файл")
            }
        }
    }
    
    private func setupModifiedTitle () {
        let segmentedControl = UISegmentedControl(items: ["Мальчики", "Девочки"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.autoresizingMask = .FlexibleWidth
        segmentedControl.tintColor = .whiteColor()
        segmentedControl.addTarget(self, action: "segmentChanged:", forControlEvents: .ValueChanged)
        self.navigationItem.titleView = segmentedControl
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.choosedSegment ? self.boyNames.count : self.girlNames.count
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let nameViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NameViewController") as? NameViewController
        nameViewController?.name = self.choosedSegment ? self.boyNames[indexPath.row] : self.girlNames[indexPath.row]
        self.navigationController?.pushViewController(nameViewController!, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = self.choosedSegment ? self.boyNames[indexPath.row] : self.girlNames[indexPath.row]
        return cell
    }
}
