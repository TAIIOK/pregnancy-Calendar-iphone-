//
//  SpasmsViewController.swift
//  PregnancyCalendar
//
//  Created by farestz on 25.02.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit
import CoreData

enum StopWatchState {
    case Watching
    case Stop
}

extension NSDate {
    func toFormattedTimeString() -> String {
        let today = NSDate()
        let gregorian = NSCalendar.currentCalendar()
        
        let hour = gregorian.component(.Hour, fromDate: today)
        let hourStr = (hour < 10 ? "0" : "") + String(hour) + ":"
        
        let minute = gregorian.component(.Minute, fromDate: today)
        let minuteStr = (minute < 10 ? "0" : "") + String(minute) + ":"
        
        let second = gregorian.component(.Second, fromDate: today)
        let secondStr = (second < 10 ? "0" : "") + String(second)
        
        return hourStr + minuteStr + secondStr
    }
}

class Spasm {
    var start = ""
    var duration = NSTimeInterval()
    var stop = ""
}

class SpasmsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let numberCellIdentifier = "NumberCellIdentifier"
    let contentCellIdentifier = "ContentCellIdentifier"
    
    var timer = NSTimer()
    var spasm = Spasm()
    var state = StopWatchState.Stop
    var dict: [Spasm] = []
    
    // OUTLETS
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var buttonSpasm: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // ACTIONS
    @IBAction func buttonSpasms(sender: AnyObject) {
        if self.state == .Stop {
            self.buttonSpasm.setTitle("УФ, ЗАКОНЧИЛАСЬ", forState: .Normal)
            self.state = .Watching
            self.spasmStart()
        } else {
            self.buttonSpasm.setTitle("ОЙ, СХВАТКА", forState: .Normal)
            self.state = .Stop
            self.spasmStop()
        }
    }
    @IBAction func buttonTrash(sender: AnyObject) {
        if dict.count > 0 {
            let alert = UIAlertController(title: "", message: "Вы действительно хотите очистить счетчик схваток?", preferredStyle: .ActionSheet)
            let cancelAction = UIAlertAction(title: "Отменить", style: .Cancel, handler: { (alert) in self.dismissViewControllerAnimated(true, completion: nil)} )
            let confirmAction = UIAlertAction(title: "Очистить", style: .Destructive, handler: { (alert) in self.confirmDelete() } )
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    func confirmDelete() {
        self.collectionView.setContentOffset(CGPointZero, animated: false)
        self.dict.removeAll()
        self.clearData()
        self.collectionView.reloadData()
    }
    
    // MAIN
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSidebarMenu()
        self.collectionView.registerNib(UINib(nibName: "NumberCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: numberCellIdentifier)
        self.collectionView.registerNib(UINib(nibName: "ContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: contentCellIdentifier)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
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
    
    // COREDATA
    private func clearData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Spasms", inManagedObjectContext: managedContext)
        fetchRequest.entity = entityDescription
        
        do {
            let result = try managedContext.executeFetchRequest(fetchRequest)
            
            for i in result {
                managedContext.deleteObject(i as! NSManagedObject)
            }
            
            do {
                try managedContext.save()
            } catch {
                print(error as NSError)
            }
        } catch {
            print(error as NSError)
        }
    }
    private func saveData(spasm: Spasm) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("Spasms", inManagedObjectContext: managedContext)
        let Spasms = NSManagedObject(entity: entityDescription!, insertIntoManagedObjectContext: managedContext)
        
        Spasms.setValue(spasm.start, forKey: "start")
        Spasms.setValue(spasm.stop, forKey: "stop")
        Spasms.setValue(spasm.duration, forKey: "duration")
        
        do {
            try Spasms.managedObjectContext?.save()
        } catch {
            print(error as NSError)
        }
    }
    private func loadData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Spasms", inManagedObjectContext: managedContext)
        fetchRequest.entity = entityDescription
        
        do {
            let result = try managedContext.executeFetchRequest(fetchRequest)
            if result.count > 0 {
                for i in result {
                    let Spasms = i as! NSManagedObject
                    let newSpasm = Spasm()
                    newSpasm.start = Spasms.valueForKey("start") as! String
                    newSpasm.stop = Spasms.valueForKey("stop") as! String
                    newSpasm.duration = Spasms.valueForKey("duration") as! NSTimeInterval
                    dict.append(newSpasm)
                }
            }
        } catch {
            print(error as NSError)
        }
    }
    
    // SPASMS WATCH
    private func spasmStart() {
        self.label.text = "0"
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerUpdate", userInfo: NSDate(), repeats: true)
        self.spasm = Spasm()
        self.spasm.start = NSDate().toFormattedTimeString()
    }
    private func spasmStop() {
        self.spasm.stop = NSDate().toFormattedTimeString()
        self.spasm.duration = -(self.timer.userInfo as! NSDate).timeIntervalSinceNow
        self.dict.append(spasm)
        self.collectionView.reloadData()
        self.scrollToBottom()
        self.timer.invalidate()
        self.label.text = ""
        self.saveData(self.spasm)
    }
    func timerUpdate() {
        let elapsed = -(self.timer.userInfo as! NSDate).timeIntervalSinceNow
        self.label.text = String(format: "%.0f", elapsed) + "\nсекунд"
    }
    func scrollToBottom() {
        let item = self.collectionView(self.collectionView!, numberOfItemsInSection: 5) - 1
        let lastItemIndex = NSIndexPath(forItem: item, inSection: self.dict.count)
        self.collectionView.scrollToItemAtIndexPath(lastItemIndex, atScrollPosition: .Bottom, animated: true)
    }
    
    // COLLECTION VIEW
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.dict.count + 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let numberCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(numberCellIdentifier, forIndexPath: indexPath) as! NumberCollectionViewCell
                numberCell.numberLabel.text = "№"
                numberCell.numberLabel.font = .boldSystemFontOfSize(12)
                return numberCell
            } else if indexPath.row == 1 {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.contentLabel.text = "НАЧАЛО"
                contentCell.contentLabel.font = .boldSystemFontOfSize(12)
                return contentCell
            } else if indexPath.row == 2 {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.contentLabel.text = "ДЛИТЕЛЬНОСТЬ"
                contentCell.contentLabel.font = .boldSystemFontOfSize(12)
                return contentCell
            } else if indexPath.row == 3 {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.contentLabel.text = "КОНЕЦ"
                contentCell.contentLabel.font = .boldSystemFontOfSize(12)
                return contentCell
            } else {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.contentLabel.text = "ПРОМЕЖУТОК"
                contentCell.contentLabel.font = .boldSystemFontOfSize(12)
                return contentCell
            }
        } else {
            if indexPath.row == 0 {
                let numberCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(numberCellIdentifier, forIndexPath: indexPath) as! NumberCollectionViewCell
                numberCell.numberLabel.font = .systemFontOfSize(13)
                numberCell.numberLabel.text = String(indexPath.section)
                return numberCell
            } else if indexPath.row == 1 {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.contentLabel.font = .systemFontOfSize(13)
                contentCell.contentLabel.text = self.dict[indexPath.section - 1].start
                return contentCell
            } else if indexPath.row == 2 {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.contentLabel.font = .systemFontOfSize(13)
                contentCell.contentLabel.text = String(format: "%.0f", self.dict[indexPath.section - 1].duration) + " сек."
                return contentCell
            } else if indexPath.row == 3 {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.contentLabel.font = .systemFontOfSize(13)
                contentCell.contentLabel.text = self.dict[indexPath.section - 1].stop
                return contentCell
            } else {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.contentLabel.font = .systemFontOfSize(13)
                contentCell.contentLabel.text = "-"
                
                if indexPath.section > 1 {
                    let timeStartString = self.dict[indexPath.section - 1].start
                    let timeStopString = self.dict[indexPath.section - 2].stop
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "HH:mm:ss"
                    
                    let timeStart = dateFormatter.dateFromString(timeStartString)
                    let timeStop = dateFormatter.dateFromString(timeStopString)
                    let interval = timeStart?.timeIntervalSinceDate(timeStop!)
                    
                    if interval < 60 {
                        contentCell.contentLabel.text = String(format: "%.0f", interval!) + " сек."
                    } else if interval < 3600 {
                        contentCell.contentLabel.text = String(format: "%.0f", interval! / 60) + " мин."
                    } else {
                        contentCell.contentLabel.text = String(format: "%.0f", interval! / 3600) + " час."
                    }
                }
                
                return contentCell
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}