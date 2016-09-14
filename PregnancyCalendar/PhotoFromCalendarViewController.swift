//
//  PhotoFromCalendarViewController.swift
//  Календарь беременности
//
//  Created by deck on 03.06.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit

class PhotoWithType: NSObject {
    var image: UIImage
    var date: NSDate
    var text: String
    var isMyPhoto: Bool
    var id: Int
    init(image: UIImage, date: NSDate, text: String, isMyPhoto: Bool, id: Int) {
        self.image = image
        self.date = date
        self.text = text
        self.isMyPhoto = isMyPhoto
        self.id = id
        super.init()
    }
}

var selectedCalendarDayPhoto:DayView!
var photoFromDate = [PhotoWithType]()
var phincalc = false
var fromPhotoCal = false
class PhotoFromCalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate {
    
    var picker = UIImagePickerController()
    
    
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    var shouldShowDaysOut = true
    var animationFinished = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = selectedCalendarDayPhoto.date.convertedDate()
        self.presentedDateUpdated(CVDate(date: date!))

        picker.delegate=self
        let a = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: #selector(PhotoFromCalendarViewController.openCamera))
        let b = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(PhotoFromCalendarViewController.addPhoto))
        let img = UIImage(named: "Arrowhead-Left-01-48")
        let btn = UIBarButtonItem(image: img , style: UIBarButtonItemStyle.Bordered, target: self, action: "Cancel")
        //self.navigationItem.setLeftBarButtonItem(btn, animated: false)
        a.tintColor = UIColor.whiteColor()
        b.tintColor = UIColor.whiteColor()
        self.navigationItem.setRightBarButtonItems([a,b], animated: true)
        loadPhoto(date!)
    }
    
    func Cancel(){
        let zodiac = self.storyboard?.instantiateViewControllerWithIdentifier("CalendarViewController")
        self.revealViewController().pushFrontViewController(zodiac, animated: true)
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.cameraCaptureMode = .Photo
            picker.modalPresentationStyle = .FormSheet
            presentViewController(picker, animated: true, completion: nil)
        }else{
            if #available(iOS 8.0, *) {
                let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .Alert)
                let ok = UIAlertAction(title: "OK", style:.Default, handler: nil)
                alert.addAction(ok)
                presentViewController(alert, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func addPhoto(){
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.modalPresentationStyle = .FormSheet
        //picker?.interfaceOrientation
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        var type = 0
        
        if (picker.sourceType == UIImagePickerControllerSourceType.Camera)
        {
            UIImageWriteToSavedPhotosAlbum(chosenImage, nil, nil, nil)
        }
        dismissViewControllerAnimated(true, completion: nil)
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: "Выберите в какую папку вы хотите добавить фотографию!", preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Мои фото", style: .Default) { action -> Void in
            //Do some stuff
            type = 0
            self.JustDoIT(chosenImage, type: type)
            let controller = self.calendarView.contentController as! CVCalendarWeekContentViewController
            controller.refreshPresentedMonth()
        }
        actionSheetController.addAction(cancelAction)
        //Create and an option action
        let nextAction: UIAlertAction = UIAlertAction(title: "Узи", style: .Default) { action -> Void in
            //Do some other stuff
            type = 1
            self.JustDoIT(chosenImage, type: type)
            let controller = self.calendarView.contentController as! CVCalendarWeekContentViewController
            controller.refreshPresentedMonth()
        }
        actionSheetController.addAction(nextAction)
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)

    }
    
    func JustDoIT(chosenImage: UIImage, type: Int){
        
        var isMyPhoto = true
        if type == 1{
            isMyPhoto = false
        }
        photoFromDate.append(PhotoWithType(image: chosenImage, date: selectedCalendarDayPhoto.date.convertedDate()!, text: "", isMyPhoto: isMyPhoto, id: 0))
        photoCollectionView.reloadData()
        if(type == 0){
            photos.append(Photo(image: chosenImage, date: selectedCalendarDayPhoto.date.convertedDate()!, text: ""))
        }else{
            photos.append(Photo(image: chosenImage, date: selectedCalendarDayPhoto.date.convertedDate()!, text: ""))
        }
        savePhotos(chosenImage,Type: type)
        cameras.removeAll()
        fillcamera()
    }
    
    func savePhotos(img: UIImage, Type: Int){
        let date = Expression<String>("Date")
        let image = Expression<Blob>("Image")
        let text = Expression<String>("Text")
        let imageData = NSData(data: UIImageJPEGRepresentation(img, 1.0)!)

        if(Type == 0){
            let table = Table("Photo")
            try! db.run(table.insert(date <- "\(selectedCalendarDayPhoto.date.convertedDate()!)", image <- Blob(bytes: imageData.datatypeValue.bytes), text <- ""))
        }else{
            let table = Table("Uzi")
            try! db.run(table.insert(date <- "\(selectedCalendarDayPhoto.date.convertedDate()!)", image <- Blob(bytes: imageData.datatypeValue.bytes), text <- ""))
        }
    }
    
    func loadPhoto(Date: NSDate){
        photoFromDate.removeAll()
        var table = Table("Photo")
        let date = Expression<String>("Date")
        let image = Expression<Blob>("Image")
        let type = Expression<Int64>("Type")
        let id = Expression<Int64>("_id")
        let text = Expression<String>("Text")
        
        for i in try! db.prepare(table.select(date,image,type,text, id).filter(date == "\(Date)")) {
            let a = i[image] 
            let c = NSData(bytes: a.bytes, length: a.bytes.count)
            let b = i[date]
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
            photoFromDate.append(PhotoWithType(image: UIImage(data: c)!, date: dateFormatter.dateFromString(b)!, text: i[text], isMyPhoto: true, id: Int(i[id])))
        }
        
        table = Table("Uzi")
        for i in try! db.prepare(table.select(date,image,type,text, id).filter(date == "\(Date)")) {
            let a = i[image] 
            let c = NSData(bytes: a.bytes, length: a.bytes.count)
            let b = i[date]
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
            photoFromDate.append(PhotoWithType(image: UIImage(data: c)!, date: dateFormatter.dateFromString(b)!, text: i[text], isMyPhoto: false, id: Int(i[id])))
        }
    }
    
    @IBAction func back(sender: UIBarButtonItem) {
        let calendar = self.storyboard?.instantiateViewControllerWithIdentifier("CalendarViewController")
        self.revealViewController()?.pushFrontViewController(calendar!, animated: true)
    }
    //collectionView
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  photoFromDate.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let PhotoCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCalendarCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        PhotoCell.photo.image = photoFromDate[indexPath.row].image
        /*
         let  Photo_temp = photoFromDate[indexPath.row].image
         let x = Double(Photo_temp.size.height)/Double(100)
         let y = Double(Photo_temp.size.width)/Double(100)
         let scale = x > y ? x : y
         let Photo = UIImage(CGImage: Photo_temp.CGImage!, scale: CGFloat(scale), orientation: Photo_temp.imageOrientation)
         PhotoCell.photo.frame.size.width = Photo.size.width
         PhotoCell.photo.frame.size.height = Photo.size.height
         PhotoCell.photo.constraints[1].constant = Photo.size.height
         PhotoCell.photo.constraints[0].constant = Photo.size.width
         self.updateViewConstraints()
         
         PhotoCell.photo.backgroundColor = .whiteColor()
         PhotoCell.photo.center = (PhotoCell.photo.superview?.center)!
         PhotoCell.photo.image = Photo
 */
        return PhotoCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        currentPhoto = indexPath.row
        fromPhotoCal = true
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("onePhoto") as? UINavigationController
        self.revealViewController().pushFrontViewController(controller, animated: true)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let  date = selectedCalendarDayPhoto.date
        let controller = calendarView.contentController as! CVCalendarWeekContentViewController
        //controller.selectDayViewWithDay(date.day, inWeekView: controller.getPresentedWeek()!)
        self.calendarView.toggleViewWithDate(selectedCalendarDayPhoto.date.convertedDate()!)
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calendarView.backgroundColor = StrawBerryColor
        menuView.backgroundColor = StrawBerryColor
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
        // calendarView.changeMode(.WeekView)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.performSegueWithIdentifier("UpdateCalendarTable", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PhotoFromCalendarViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .WeekView
    }
    
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .Monday
    }
    
    // MARK: Optional methods
    
    func shouldShowWeekdaysOut() -> Bool {
        return shouldShowDaysOut
    }
    
    func shouldAnimateResizing() -> Bool {
        return true // Default value is true
    }
    
    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("\(dayView.date.commonDescription) is selected!")
        selectedCalendarDayPhoto = dayView
        loadPhoto(selectedCalendarDayPhoto.date.convertedDate()!)
        photoCollectionView.reloadData()
    }
    
    
    func swipedetected(){
        
        
        
    }
    
    func presentedDateUpdated(date: CVDate) {
        
        if self.title != date.globalDescription && self.animationFinished {
            let updatedMonthLabel = UILabel()
            // updatedMonthLabel.textColor = monthLabel.textColor
            //updatedMonthLabel.font = monthLabel.font
            updatedMonthLabel.textAlignment = .Center
            updatedMonthLabel.text = date.globalDescription
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            
            
            
            switch date.month {
            case 1:
                self.navigationController?.parentViewController?.title = "Январь \(date.year)"
                self.title = "Январь \(date.year)"
                break
            case 2:
                self.navigationController?.parentViewController?.title = "Февраль \(date.year)"
                self.title = "Февраль \(date.year)"
                break
            case 3:
                self.navigationController?.parentViewController?.title = "Март \(date.year)"
                self.title = "Март \(date.year)"
                break
            case 4:
                self.navigationController?.parentViewController?.title = "Апрель \(date.year)"
                self.title = "Апрель \(date.year)"
                break
            case 5:
                self.navigationController?.parentViewController?.title = "Май \(date.year)"
                self.title = "Май \(date.year)"
                break
            case 6:
                self.navigationController?.parentViewController?.title = "Июнь \(date.year)"
                self.title = "Июнь \(date.year)"
                break
            case 7:
                self.navigationController?.parentViewController?.title = "Июль \(date.year)"
                self.title = "Июль \(date.year)"
                break
            case 8:
                self.navigationController?.parentViewController?.title = "Август \(date.year)"
                self.title = "Август \(date.year)"
                break
            case 9:
                self.navigationController?.parentViewController?.title = "Сентябрь \(date.year)"
                self.title = "Сентябрь \(date.year)"
                break
            case 10:
                self.navigationController?.parentViewController?.title = "Октябрь \(date.year)"
                self.title = "Октябрь \(date.year)"
                break
            case 11:
                self.navigationController?.parentViewController?.title = "Ноябрь \(date.year)"
                self.title = "Ноябрь \(date.year)"
                break
            case 12:
                self.navigationController?.parentViewController?.title = "Декабрь \(date.year)"
                self.title = "Декабрь \(date.year)"
                break
            default:
                break
            }
        }
    }
    
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        let day = dayView.date.day
        let res = ImageFromCalendar.ShowCalendarImages(dayView.date.convertedDate()!)
        if (res.0 || res.1 || res.2)
        {
            return true
        }
        
        
        return false
    }
    
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
        
        var numberOfDots = 0
        
        var colors = [UIColor]()
        
        let res = ImageFromCalendar.ShowCalendarImages(dayView.date.convertedDate()!)
        if (res.0 )
        {
            numberOfDots += 1
            colors.append(UIColor.redColor())
        }
        if (res.1 )
        {
            numberOfDots += 1
            colors.append(UIColor.greenColor())
        }
        if (res.2 )
        {
            numberOfDots += 1
            colors.append(UIColor.blueColor())
        }
        
        return colors
        
    }
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        return false
    }
    
    
    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        return 10
    }
    
    
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .Short
    }
    
    func selectionViewPath() -> ((CGRect) -> (UIBezierPath)) {
        return { UIBezierPath(rect: CGRectMake(0, 0, $0.width, $0.height)) }
    }
    
    func shouldShowCustomSingleSelection() -> Bool {
        return false
    }
    
    func preliminaryView(viewOnDayView dayView: DayView) -> UIView {
        let circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Circle)
        circleView.fillColor = .colorFromCode(0xCCCCCC)
        return circleView
    }
    
    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if (dayView.isCurrentDay) {
            return true
        }
        return false
    }
    
    func supplementaryView(viewOnDayView dayView: DayView) -> UIView {
        let π = M_PI
        
        let ringSpacing: CGFloat = 3.0
        let ringInsetWidth: CGFloat = 1.0
        let ringVerticalOffset: CGFloat = 1.0
        var ringLayer: CAShapeLayer!
        let ringLineWidth: CGFloat = 4.0
        let ringLineColour: UIColor = .blueColor()
        
        let newView = UIView(frame: dayView.bounds)
        
        let diameter: CGFloat = (newView.bounds.width) - ringSpacing
        let radius: CGFloat = diameter / 2.0
        
        let rect = CGRectMake(newView.frame.midX-radius, newView.frame.midY-radius-ringVerticalOffset, diameter, diameter)
        
        ringLayer = CAShapeLayer()
        newView.layer.addSublayer(ringLayer)
        
        ringLayer.fillColor = nil
        ringLayer.lineWidth = ringLineWidth
        ringLayer.strokeColor = ringLineColour.CGColor
        
        let ringLineWidthInset: CGFloat = CGFloat(ringLineWidth/2.0) + ringInsetWidth
        let ringRect: CGRect = CGRectInset(rect, ringLineWidthInset, ringLineWidthInset)
        let centrePoint: CGPoint = CGPointMake(ringRect.midX, ringRect.midY)
        let startAngle: CGFloat = CGFloat(-π/2.0)
        let endAngle: CGFloat = CGFloat(π * 2.0) + startAngle
        let ringPath: UIBezierPath = UIBezierPath(arcCenter: centrePoint, radius: ringRect.width/2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        ringLayer.path = ringPath.CGPath
        ringLayer.frame = newView.layer.bounds
        
        return newView
    }
    
    func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if (Int(arc4random_uniform(3)) == 1) {
            return false
        }
        
        return false
    }
}


// MARK: - CVCalendarViewAppearanceDelegate

extension PhotoFromCalendarViewController: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
}

// MARK: - IB Actions

extension PhotoFromCalendarViewController {
    @IBAction func switchChanged(sender: UISwitch) {
        if sender.on {
            calendarView.changeDaysOutShowingState(false)
            shouldShowDaysOut = true
        } else {
            calendarView.changeDaysOutShowingState(true)
            shouldShowDaysOut = false
        }
    }
    
    @IBAction func todayMonthView() {
        calendarView.toggleCurrentDayView()
    }
    
    /// Switch to WeekView mode.
    @IBAction func toWeekView(sender: AnyObject) {
        calendarView.changeMode(.WeekView)
    }
    
    /// Switch to MonthView mode.
    @IBAction func toMonthView(sender: AnyObject) {
        calendarView.changeMode(.MonthView)
    }
    
    @IBAction func loadPrevious(sender: AnyObject) {
        calendarView.loadPreviousView()
    }
    
    
    @IBAction func loadNext(sender: AnyObject) {
        calendarView.loadNextView()
    }
}

// MARK: - Convenience API Demo

extension PhotoFromCalendarViewController {
    func toggleMonthViewWithMonthOffset(offset: Int) {
        let calendar = NSCalendar.currentCalendar()
        //        let calendarManager = calendarView.manager
        let components = Manager.componentsForDate(NSDate()) // from today
        
        components.month += offset
        
        let resultDate = calendar.dateFromComponents(components)!
        
        self.calendarView.toggleViewWithDate(resultDate)
    }
    
    func didShowNextMonthView(date: NSDate)
    {
        //        let calendar = NSCalendar.currentCalendar()
        //        let calendarManager = calendarView.manager
        let components = Manager.componentsForDate(date) // from today
        
        print("Showing Month: \(components.month)")
    }
    
    
    func didShowPreviousMonthView(date: NSDate)
    {
        //        let calendar = NSCalendar.currentCalendar()
        //        let calendarManager = calendarView.manager
        let components = Manager.componentsForDate(date) // from today
        
        print("Showing Month: \(components.month)")
    }
    
}
