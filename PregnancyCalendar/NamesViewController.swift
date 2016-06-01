//
//  NamesTableViewController.swift
//  rodicalc
//
//  Created by deck on 24.02.16.
//  Copyright © 2016 deck. All rights reserved.
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

class NamesTableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet var table: UITableView!
    @IBOutlet weak var changer: UISegmentedControl!
    
   
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        self.reloadTable(sender.selectedSegmentIndex == 1 ? false : true)
    }
    
    private func reloadTable(index: Bool) {
        choosedSegmentNames = index
        choosedName = NSIndexPath(forRow: 0, inSection: 0)
        self.table.reloadData()
        self.table.scrollToRowAtIndexPath(choosedName, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        table.backgroundView = UIImageView(image: UIImage(named: "background.jpg"))
        table.backgroundColor = .clearColor()
        WorkWithJSON();
        sections = AddSect(man)
        sectionsGirl = AddSect(woman)
        setupSidebarMenu()
        let btnBack = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = btnBack
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return choosedSegmentNames ? sections.count : sectionsGirl.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return choosedSegmentNames ? sections[section].length : sectionsGirl[section].length
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        choosedName = indexPath
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)        
        cell.textLabel?.text = choosedSegmentNames ? man[sections[indexPath.section].index + indexPath.row].name : woman[sectionsGirl[indexPath.section].index + indexPath.row].name
        cell.backgroundColor = .clearColor()
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var returnedView = UIView() //set these values as necessary
        returnedView.backgroundColor = StrawBerryColor
        
        var label = UILabel(frame: CGRectMake(18, 7, 18, 18))
        label.text = choosedSegmentNames ? sections[section].title : sectionsGirl[section].title
        label.textColor = UIColor.whiteColor()
        returnedView.addSubview(label)
        
        return returnedView
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return choosedSegmentNames ? sections[section].title : sectionsGirl[section].title
    }

    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return choosedSegmentNames ? sections.map { $0.title } : sectionsGirl.map {$0.title}
    }
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return index
    }
    
    override func viewDidAppear(animated: Bool) {
        choosedSegmentNames = true
    }
    
    func Update(){
        if choosedSegmentNames {
            changer.selectedSegmentIndex = 0
        } else{
            changer.selectedSegmentIndex = 1
        }
        self.table.reloadData()
        self.table.scrollToRowAtIndexPath(choosedName, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
    }
    
    func WorkWithJSON(){
        if let path = NSBundle.mainBundle().pathForResource("names", ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                do {
                    let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    if let Man : [NSDictionary] = jsonResult["мужские"] as? [NSDictionary] {
                        for mans: NSDictionary in Man {
                            var name = mans.valueForKey("имя")
                            name!.dataUsingEncoding(NSUTF8StringEncoding)
                            if let d = name {
                                man.append(Names(name: d as! String, value: "\(mans.valueForKey("значение")!)", about: "\(mans.valueForKey("описание")!)"))
                            }
                        }
                    }
                    if let Man : [NSDictionary] = jsonResult["женские"] as? [NSDictionary] {
                        for mans: NSDictionary in Man {
                            var name = mans.valueForKey("имя")
                            name!.dataUsingEncoding(NSUTF8StringEncoding)
                            if let d = name {
                                woman.append(Names(name: d as! String, value: "\(mans.valueForKey("значение")!)", about: "\(mans.valueForKey("описание")!)"))
                            }
                        }
                    }
                    
                } catch {}
            } catch {}
        }
    }
}
