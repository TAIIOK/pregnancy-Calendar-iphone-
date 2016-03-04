//
//  SpasmsViewController.swift
//  PregnancyCalendar
//
//  Created by farestz on 25.02.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit

enum State {
    case Watching
    case Stop
}

extension NSDate {
    func toFormattedTimeString() -> String {
        let today = NSDate()
        let gregorian = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        let hour = gregorian.component(.Hour, fromDate: today)
        let minute = gregorian.component(.Minute, fromDate: today)
        let second = gregorian.component(.Second, fromDate: today)
        return "\(hour):\(minute):\(second)"
    }
}

class SpasmsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    let numberCellIdentifier = "NumberCellIdentifier"
    let contentCellIdentifier = "ContentCellIdentifier"
    var state: State = .Stop
    var timer = NSTimer()
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var buttonSpasm: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSidebarMenu()
        self.collectionView.registerNib(UINib(nibName: "NumberCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: numberCellIdentifier)
        self.collectionView.registerNib(UINib(nibName: "ContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: contentCellIdentifier)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func spasmStart() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerUpdate", userInfo: NSDate(), repeats: true)
    }
    
    private func spasmStop() {
        self.timer.invalidate()
        self.label.text = ""
        self.collectionView.reloadData()
    }
    
    func timerUpdate() {
        let elapsed = -(self.timer.userInfo as! NSDate).timeIntervalSinceNow
        self.label.text = String(format: "%.0f", elapsed)
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
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let numberCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(numberCellIdentifier, forIndexPath: indexPath) as! NumberCollectionViewCell
                numberCell.backgroundColor = .whiteColor()
                numberCell.numberLabel.font = .boldSystemFontOfSize(7)
                numberCell.numberLabel.text = "№"
                return numberCell
            } else if indexPath.row == 1 {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.backgroundColor = .whiteColor()
                contentCell.contentLabel.font = UIFont.boldSystemFontOfSize(7)
                contentCell.contentLabel.text = "НАЧАЛАСЬ"
                return contentCell
            } else if indexPath.row == 2 {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.backgroundColor = .whiteColor()
                contentCell.contentLabel.font = UIFont.boldSystemFontOfSize(7)
                contentCell.contentLabel.text = "ДЛИТЕЛЬНОСТЬ"
                return contentCell
            } else if indexPath.row == 3 {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.backgroundColor = .whiteColor()
                contentCell.contentLabel.font = UIFont.boldSystemFontOfSize(7)
                contentCell.contentLabel.text = "ЗАКОНЧИЛАСЬ"
                return contentCell
            } else {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.backgroundColor = .whiteColor()
                contentCell.contentLabel.font = UIFont.boldSystemFontOfSize(7)
                contentCell.contentLabel.text = "ПРОМЕЖУТОК"
                return contentCell
            }
        } else {
            if indexPath.row == 0 {
                let numberCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(numberCellIdentifier, forIndexPath: indexPath) as! NumberCollectionViewCell
                numberCell.backgroundColor = .whiteColor()
                numberCell.numberLabel.font = .systemFontOfSize(10)
                numberCell.numberLabel.text = String(indexPath.section)
                return numberCell
            } else if indexPath.row == 1 {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.backgroundColor = .whiteColor()
                contentCell.contentLabel.font = .systemFontOfSize(10)
                contentCell.contentLabel.text = "\(NSDate().toFormattedTimeString())"
                return contentCell
            } else {
                let contentCell = self.collectionView.dequeueReusableCellWithReuseIdentifier(contentCellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
                contentCell.backgroundColor = .whiteColor()
                contentCell.contentLabel.font = .systemFontOfSize(10)
                contentCell.contentLabel.text = "-"
                return contentCell
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}