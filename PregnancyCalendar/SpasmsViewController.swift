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

// НЕ РАБОТАЕТ НА СТАРЫХ ВЕРСИЯХ < 8.0
extension NSDate {
    internal func toFormattedTimeString() -> String {
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

// данные о схватке
class Spasm {
    var stop = ""
    var start = ""
    var duration = NSTimeInterval()
}

class SpasmsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let numberCellIdentifier = "NumberCellIdentifier"
    let contentCellIdentifier = "ContentCellIdentifier"
    let numberCollectionViewCell = "NumberCollectionViewCell"
    let contentCollectionViewCell = "ContentCollectionViewCell"
    
    var spasm = Spasm()
    var timer = NSTimer()
    var dict: [Spasm] = []
    var state = StopWatchState.Stop
    let progressLine = CAShapeLayer()
    
    // OUTLETS
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelSeconds: UILabel!
    @IBOutlet weak var buttonSpasm: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var watch: UIImageView!
    
    // ACTIONS
    @IBAction func buttonSpasms(sender: AnyObject) {
        self.state == .Stop ? self.spasmStart() : self.spasmStop()
    }
    @IBAction func buttonTrash(sender: AnyObject) {
        if self.dict.count > 0 {
            let alert = UIAlertController(title: "", message: "Вы уверены, что хотите удалить данные?", preferredStyle: .ActionSheet)
            let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel, handler: { (alert) in self.dismissViewControllerAnimated(true, completion: nil)} )
            let confirmAction = UIAlertAction(title: "Очистить", style: .Destructive, handler: { (alert) in self.confirmDelete() } )
            
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    func confirmDelete() {
        self.collectionView.setContentOffset(CGPointZero, animated: false) // для нормального очищения collectionview
        self.dict.removeAll()
        self.clearData()
        self.collectionView.reloadData()
    }
    
    // MAIN
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSidebarMenu()
        self.collectionView.backgroundColor = .clearColor()
        self.buttonSpasm.clipsToBounds = true
        self.buttonSpasm.layer.cornerRadius = 4
        self.collectionView.registerNib(UINib(nibName: self.numberCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: self.numberCellIdentifier)
        self.collectionView.registerNib(UINib(nibName: self.contentCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: self.contentCellIdentifier)
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
    func animWatch(){
        // set up some values to use in the curve
        let ovalStartAngle = CGFloat(270.001 * M_PI/180)
        let ovalEndAngle = CGFloat(270.0009 * M_PI/180)
        let ovalRect = CGRectMake(20, 25, 100, 100)//(110, 605, 100, 100)
        
        // create the bezier path
        let ovalPath = UIBezierPath(arcCenter: CGPointMake(CGRectGetMidX(ovalRect), CGRectGetMidY(ovalRect)),
                                    radius: CGRectGetWidth(ovalRect) / 2,
                                    startAngle: ovalStartAngle,
                                    endAngle: ovalEndAngle, clockwise: true)
        

        progressLine.path = ovalPath.CGPath
        progressLine.strokeColor = StrawBerryColor.CGColor
        progressLine.fillColor = UIColor.clearColor().CGColor
        progressLine.lineWidth = 15.0
        

        progressLine.lineDashPattern = [4,20,4,20,4,20,4,20,4,20,4,20,4,20,4,20,4,20,4,20,4,25]
        
        // add the curve to the screen
        self.watch.layer.addSublayer(progressLine)
        
        // create a basic animation that animates the value 'strokeEnd'
        // from 0.0 to 1.0 over 3.0 seconds
        let animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        animateStrokeEnd.duration = 60.0
        animateStrokeEnd.fromValue = 0.0
        animateStrokeEnd.toValue = 1.0
        animateStrokeEnd.repeatCount = 2
        // add the animation
        progressLine.addAnimation(animateStrokeEnd, forKey: "animate stroke end animation")
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
        
        Spasms.setValue(self.spasm.stop, forKey: "stop")
        Spasms.setValue(self.spasm.start, forKey: "start")
        Spasms.setValue(self.spasm.duration, forKey: "duration")
        
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
                    self.dict.append(newSpasm)
                }
            }
        } catch {
            print(error as NSError)
        }
    }
    
    // SPASMS WATCH
    private func spasmStart() {
        self.spasm = Spasm() // создать новый объект
        self.state = .Watching // установить состояние работы секундомера
        self.buttonSpasm.setTitle("УФ, ЗАКОНЧИЛАСЬ", forState: .Normal) // поменять текст на кнопке
        
        self.label.text = "0" // начальное значение секундомера
        self.labelSeconds.text = "секунд"
        self.spasm.start = NSDate().toFormattedTimeString() // записать дату начала
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerUpdate", userInfo: NSDate(), repeats: true)
        animWatch()
        watch.highlighted = true
    }
    private func spasmStop() {
        self.state = .Stop // состояние ожидания работы
        self.spasm.stop = NSDate().toFormattedTimeString() // записать дату конца
        self.spasm.duration = -(self.timer.userInfo as! NSDate).timeIntervalSinceNow // записать продолжительность
        
        // сохранить данные о схватке
        self.dict.append(self.spasm)
        self.saveData(self.spasm)
        self.collectionView.reloadData()
        self.scrollToBottom()
        
        // остановить таймер
        self.timer.invalidate()
        self.label.text = ""
        self.labelSeconds.text = ""
        
        // поменять текст на кнопке
        self.buttonSpasm.setTitle("ОЙ, СХВАТКА", forState: .Normal)
        progressLine.removeFromSuperlayer()
        watch.highlighted = false
    }
    func timerUpdate() {
        let elapsed = -(self.timer.userInfo as! NSDate).timeIntervalSinceNow
        let isStopTime = Int(elapsed + 0.1)
        self.label.text = String(format: "%.0f", elapsed)
        self.labelSeconds.text = self.getSecondsWord(isStopTime)
        
        // остановка таймера в случае, если его забыли -_-
        /*if isStopTime == 119 {
            self.state = .Stop
            self.timer.invalidate()
            self.label.text = ""
            self.labelSeconds.text = ""
            self.buttonSpasm.setTitle("ОЙ, СХВАТКА", forState: .Normal)
            
            let alert = UIAlertController(title: "Таймер был остановлен", message: "", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "ОК", style: .Default, handler: { (alert) in self.dismissViewControllerAnimated(true, completion: nil)} )
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }*/
    }
    func scrollToBottom() {
        let item = self.collectionView(self.collectionView!, numberOfItemsInSection: 5) - 1
        let lastItemIndex = NSIndexPath(forItem: item, inSection: self.dict.count)
        self.collectionView.scrollToItemAtIndexPath(lastItemIndex, atScrollPosition: .Bottom, animated: true)
    }
    func getSecondsWord(elapsed: Int) -> String {
        if elapsed > 111 && elapsed < 115 {
            return "секунд"
        } else if elapsed > 10 && elapsed < 15 {
            return "секунд"
        } else if elapsed % 10 == 1 {
            return "секунда"
        } else if elapsed % 10 == 2 || elapsed % 10 == 3 || elapsed % 10 == 4 {
            return "секунды"
        } else {
            return "секунд"
        }
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
                numberCell.numberLabel.font = .boldSystemFontOfSize(8)
                numberCell.backgroundColor = .lightGrayColor()
                return numberCell
            } else if indexPath.row == 1 {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.contentLabel.text = "НАЧАЛО"
                contentCell.contentLabel.font = .boldSystemFontOfSize(8)
                contentCell.backgroundColor = .lightGrayColor()
                return contentCell
            } else if indexPath.row == 2 {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.contentLabel.text = "ДЛИТЕЛЬНОСТЬ"
                contentCell.contentLabel.font = .boldSystemFontOfSize(8)
                contentCell.backgroundColor = .lightGrayColor()
                return contentCell
            } else if indexPath.row == 3 {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.contentLabel.text = "КОНЕЦ"
                contentCell.contentLabel.font = .boldSystemFontOfSize(8)
                contentCell.backgroundColor = .lightGrayColor()
                return contentCell
            } else {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.contentLabel.text = "ПРОМЕЖУТОК"
                contentCell.contentLabel.font = .boldSystemFontOfSize(8)
                contentCell.backgroundColor = .lightGrayColor()
                return contentCell
            }
        } else {
            if indexPath.row == 0 {
                let numberCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(numberCellIdentifier, forIndexPath: indexPath) as! NumberCollectionViewCell
                numberCell.numberLabel.font = .systemFontOfSize(10)
                numberCell.numberLabel.text = String(indexPath.section)
                numberCell.backgroundColor = .clearColor()
                return numberCell
            } else if indexPath.row == 1 {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.contentLabel.font = .systemFontOfSize(10)
                contentCell.contentLabel.text = self.dict[indexPath.section - 1].start
                contentCell.backgroundColor = .clearColor()
                return contentCell
            } else if indexPath.row == 2 {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.contentLabel.font = .systemFontOfSize(10)
                contentCell.contentLabel.text = String(format: "%.0f", self.dict[indexPath.section - 1].duration) + " сек."
                contentCell.backgroundColor = .clearColor()
                return contentCell
            } else if indexPath.row == 3 {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.contentLabel.font = .systemFontOfSize(10)
                contentCell.contentLabel.text = self.dict[indexPath.section - 1].stop
                contentCell.backgroundColor = .clearColor()
                return contentCell
            } else {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.contentLabel.font = .systemFontOfSize(10)
                contentCell.contentLabel.text = "-"
                
                if indexPath.section > 1 {
                    let timeStartString = self.dict[indexPath.section - 1].start
                    let timeStopString = self.dict[indexPath.section - 2].stop
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "HH:mm:ss"
                    
                    let timeStart = dateFormatter.dateFromString(timeStartString)
                    let timeStop = dateFormatter.dateFromString(timeStopString)
                    let interval = timeStart?.timeIntervalSinceDate(timeStop!)
                    
                    if interval < 0 {
                        contentCell.contentLabel.text = "> 1 дня"
                    } else if interval < 60 {
                        contentCell.contentLabel.text = String(format: "%.0f", interval!) + " сек."
                    } else if interval < 3600 {
                        contentCell.contentLabel.text = String(format: "%.0f", interval! / 60) + " мин."
                    } else {
                        contentCell.contentLabel.text = String(format: "%.0f", interval! / 3600) + " час."
                    }
                }
                contentCell.backgroundColor = .clearColor()
                return contentCell
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}