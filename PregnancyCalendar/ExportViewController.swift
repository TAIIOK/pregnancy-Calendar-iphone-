//
//  ExportTableViewController.swift
//  rodicalc
//
//  Created by deck on 25.02.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit
import CoreData

class ExportNote: NSObject {
    var date: NSDate
    var photos: [PhotoWithText]
    var notes: [TextNoteE]
    var notifi: [TextNoteE]
    init(date: NSDate, photos: [PhotoWithText], notes: [TextNoteE], notifi: [TextNoteE]) {
        self.date = date
        self.photos = photos
        self.notes = notes
        self.notifi = notifi
        super.init()
    }
}

class PhotoWithText: NSObject {
    var image: UIImage
    var text: String
    init(photos: UIImage, text: String) {
        self.image = photos
        self.text = text
        super.init()
    }
}

class TextNoteE: NSObject {
    var date: NSDate
    var typeS: String
    var text: String
    init(typeS: String, text: String, date: NSDate) {
        self.typeS = typeS
        self.text = text
        self.date = date
        super.init()
    }
}

class AllNotesForExport: NSObject {
    var type: String
    var text: String
    var count: Int
    var selected: Bool
    init(type: String, text: String, count: Int, selected: Bool) {
        self.type = type
        self.text = text
        self.count = count
        self.selected = selected
        super.init()
    }
}

class Food: NSObject {
    var date: NSDate
    var text: String
    init(text: String, date: NSDate) {
        self.text = text
        self.date = date
        super.init()
    }
}

class ExportWeek: NSObject {
    var days: [NSDate]
    var week: Int
    init(week: Int, days: [NSDate]) {
        self.week = week
        self.days = days
        super.init()
    }
}

//var showingExportType = 0 //0-экспорт справа, слева меню выбора вкладок 1-экспорт слева, справа календарь 2-экспорт слева, справа предпросмотр

var selectionDateType = -1
var selectedExportDays = [NSDate]()
var selectedExportWeek = [ExportWeek]()
var ExpPhoto = [Photo]()
var NotificationExport = [TextNoteE]()

var NotesExportText = [TextNoteE]()
var NotestExportWeight = [Weight]()
var NotesExportDoctor = [Doctor]()
var NotesExportFood = [Food]()
var NotesExportDrugs = [Drugs]()

var AllExportNotes = [ExportNote]()
var AllNotesCount = [AllNotesForExport]()

class ExportViewController: UIViewController, UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource {


    @IBOutlet weak var DateTable: UITableView!
    @IBOutlet weak var NotesTable: UITableView!
    @IBOutlet weak var PhotoCollectionVIew: UICollectionView!
    @IBOutlet weak var NotifiTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DateTable.delegate = self
        DateTable.dataSource = self
        DateTable.backgroundColor = .clearColor()
        NotesTable.delegate = self
        NotesTable.dataSource = self
        NotesTable.backgroundColor = .clearColor()
        NotifiTable.delegate = self
        NotifiTable.dataSource = self
        NotifiTable.backgroundColor = .clearColor()
        PhotoCollectionVIew.allowsMultipleSelection = true
        self.title = "Экспорт"
        self.setupSidebarMenu()
        let img  = UIImage(named: "menu")
        let btn = UIBarButtonItem(image: img , style: UIBarButtonItemStyle.Bordered, target: self.revealViewController(), action: "revealToggle:")
        self.navigationItem.leftBarButtonItem = btn
        let btnBack = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = btnBack
        if selectionDateType == 1{
            WeekToDays()
        }
        loadPhotos()
        PhotoCollectionVIew.reloadData()
        loadNotifi()
        NotifiTable.reloadData()
        loadNotes()
        NotesTable.reloadData()
    }
    
    func WeekToDays(){
        selectedExportDays.removeAll()
        for i in selectedExportWeek{
            selectedExportDays.appendContentsOf(i.days)
        }
    }
    
    private func setupSidebarMenu() {
        if self.revealViewController() != nil {
            self.revealViewController().rearViewRevealDisplacement = 0
            self.revealViewController().rearViewRevealOverdraw = 0
            self.revealViewController().rearViewRevealWidth = 275
            self.revealViewController().frontViewShadowRadius = 0
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
    }
    
    @IBAction func export(segue:UIStoryboardSegue) {
        FallBack()
    }
    func FallBack(){
        //let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ExportNav")
        //let vc1 = self.storyboard?.instantiateViewControllerWithIdentifier("MasterView")
        //self.splitViewController?.showDetailViewController(vc!, sender: self)
        //self.splitViewController?.viewControllers[0] = vc1!
        if selectionDateType == 1{
            WeekToDays()
        }
        loadPhotos()
        PhotoCollectionVIew.reloadData()
        loadNotifi()
        NotifiTable.reloadData()
        loadNotes()
        NotesTable.reloadData()
    }

    @IBAction func Show(sender: UIButton) {
        
        AllExportNotes.removeAll()

        let days = selectedExportDays.sort(self.frontwards)
        
        for day_ in days{
            self.SelectedNoteFromDate(day_)
        }
        
        /*print("Count: \(AllExportNotes.count)")
        for i in AllExportNotes{
            print("Date: \(i.date)")
            print("Photo count: \(i.photos.count)")
            for j in i.photos{
                print("\tPhoto: \(j)")
            }
            print("Note count: \(i.notes.count)")
            for k in i.notes{
                print("\tNote: \(k)")
            }
            print("Notifi count: \(i.notifi.count)")
            for n in i.notifi{
                print("\tNotifi: \(n)")
            }
        }*/
        var txt = ""
        var somanyphoto = false
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        for i in AllExportNotes{
            if i.photos.count > 2{
                somanyphoto = true
                txt.appendContentsOf("День \(dateFormatter.stringFromDate(i.date)) содержит \(i.photos.count) фотографий")
            }
        }
        if somanyphoto{
            let actionSheetController: UIAlertController = UIAlertController(title: "", message: "Слишком много фото! \(txt) Вы можете добавить не более 2 фотографий для одного дня.", preferredStyle: .Alert)
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Ок", style: .Default) { action -> Void in
                //Do some stuff
            }
            actionSheetController.addAction(cancelAction)
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        }else{
            let vc1 = self.storyboard?.instantiateViewControllerWithIdentifier("ShowExport")
            self.navigationController?.pushViewController(vc1!, animated: true)
        }
    }
    
    func SelectedNoteFromDate(date: NSDate){
        var imgmas = [PhotoWithText]()
        var notemas = [TextNoteE]()
        var notifimas = [TextNoteE]()
        
        let indexPathPhoto = PhotoCollectionVIew.indexPathsForSelectedItems()
        if indexPathPhoto != nil{
            for i in indexPathPhoto!{
                if ExpPhoto[i.row].date == date{
                    imgmas.append(PhotoWithText(photos: ExpPhoto[i.row].image, text: ExpPhoto[i.row].text))
                }
            }
        }
        var indexes = [Int]()
        let indexPathNote = NotesTable.indexPathsForSelectedRows
        if indexPathNote != nil{
            for i in indexPathNote!{
                indexes.append(i.row)
            }
        }
        for (var i = 0; i < AllNotesCount.count; i += 1){
            if indexes.contains(i){
                AllNotesCount[i].selected = true
            }else{
                AllNotesCount[i].selected = false
            }
        }
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        components.hour = 00
        components.minute = 00
        components.second = 00
        let newcurDate = calendar.dateFromComponents(components)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        for i in AllNotesCount{
            if i.selected == true{
                if i.type == "Мое самочувствие" {
                    for j in NotesExportText{
                        if j.date == date && j.typeS == "Мое самочувствие"{
                            notemas.append(TextNoteE(typeS: j.typeS, text: j.text, date: date))
                        }
                    }
                }
                if i.type == "Как ведет себя малыш"{
                    for j in NotesExportText{
                        if j.date == date && j.typeS == "Как ведет себя малыш"{
                            notemas.append(TextNoteE(typeS: j.typeS, text: j.text, date: date))
                        }
                    }
                }
                if i.type == "Приятное воспоминание дня"{
                    for j in NotesExportText{
                        if j.date == date && j.typeS == "Приятное воспоминание дня"{
                            notemas.append(TextNoteE(typeS: j.typeS, text: j.text, date: date))
                        }
                    }
                }
                if i.type == "Важные события"{
                    for j in NotesExportText{
                        if j.date == date && j.typeS == "Важные события"{
                            notemas.append(TextNoteE(typeS: j.typeS, text: j.text, date: date))
                        }
                    }
                }
                if i.type == "Мой вес"{
                    for j in NotestExportWeight{
                        if j.date == date{
                            notemas.append(TextNoteE(typeS: "Мой вес", text: "\(j.kg) кг \(j.gr) г", date: date))
                        }
                    }

                }else if i.type == "Принимаемые лекарства"{
                    for j in NotesExportDrugs{
 
                        let componentsS = calendar.components([.Day , .Month , .Year], fromDate: j.start)
                        let componentsE = calendar.components([.Day , .Month , .Year], fromDate: j.end)
                        componentsS.hour = 00
                        componentsS.minute = 00
                        componentsS.second = 00
                        let newDateS = calendar.dateFromComponents(componentsS)
                        componentsE.hour = 00
                        componentsE.minute = 00
                        componentsE.second = 00
                        let newDateE = calendar.dateFromComponents(componentsE)
                        let a = newcurDate?.compare(newDateS!)
                        let b = newcurDate?.compare(newDateE!)

                        if (a == NSComparisonResult.OrderedDescending || a == NSComparisonResult.OrderedSame) && (b == NSComparisonResult.OrderedAscending || b == NSComparisonResult.OrderedSame) {
                            notemas.append(TextNoteE(typeS: "Принимаемые лекарства", text: j.name, date: date))
                        }
                    }
                }else if i.type == "Посещение врачей"{
                    for j in NotesExportDoctor{
                        let componentsCurrent = calendar.components([.Day , .Month , .Year], fromDate: j.date)
                        if components.day == componentsCurrent.day && components.month == componentsCurrent.month && components.year == componentsCurrent.year {
                            notemas.append(TextNoteE(typeS: "Посещение врачей", text: j.name, date: date))
                        }
                    }
                }else if i.type == "Мое меню на сегодня"{
                    for j in NotesExportFood{
                        if j.date == date{
                            notemas.append(TextNoteE(typeS: "Мое меню на сегодня", text: j.text, date: date))
                        }
                    }
                }
            }
        }
        var NotifiSelected = false
        if NotifiTable.indexPathsForSelectedRows != nil{
            NotifiSelected = true
        }
        if NotifiSelected{
            for i in NotificationExport{
                if i.date == date{
                    notifimas.append(TextNoteE(typeS: i.typeS, text: i.text, date: date))
                }
            }
        }
   
        
        AllExportNotes.append(ExportNote(date: date, photos: imgmas, notes: notemas, notifi: notifimas))
    }
    
    //TABLE
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == DateTable{
            return 2
        }else if tableView == NotesTable{
            return AllNotesCount.count
        }else{
           return 1
        }
    }
    
    func frontwards(s1: NSDate, _ s2: NSDate) -> Bool {
        return s1.compare(s2) == NSComparisonResult.OrderedAscending
    }
    
    func  tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == DateTable{
            let cell = tableView.dequeueReusableCellWithIdentifier("DateExpCell", forIndexPath: indexPath) as! DateTableViewCell
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Выбранные дни"
                let days = selectedExportDays.sort(self.frontwards)
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                var str = ""
                for var i = 0; i < days.count; i += 1{
                    if i == 0 {
                        str.appendContentsOf("\(dateFormatter.stringFromDate(days[i]))")
                    }else{
                        str.appendContentsOf(", \(dateFormatter.stringFromDate(days[i]))")
                    }
                }
                if str.characters.count == 0 || selectionDateType == 1{
                    cell.detailTextLabel?.text = "не выбрано"
                }else{
                    cell.detailTextLabel?.text = str
                }
            case 1:
                cell.textLabel?.text = "Недели беременности"
                var str = ""
                for var i = 0; i < selectedExportWeek.count; i += 1{
                    if i == 0 {
                        str.appendContentsOf("\(selectedExportWeek[i].week)")
                    }else{
                        str.appendContentsOf(", \(selectedExportWeek[i].week)")
                    }
                }
                if str.characters.count == 0 || selectionDateType == 0{
                    cell.detailTextLabel?.text = "не выбрано"
                }else{
                    cell.detailTextLabel?.text = str
                }
            default:
                cell.textLabel?.text = ""
            }
            if indexPath.row == selectionDateType{
                cell.setHighlighted(true, animated: false)
                tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            }
            
            cell.selectedBackgroundView?.backgroundColor = .clearColor()
            cell.backgroundColor = .clearColor()
            return cell
        }else if tableView == NotesTable{
            let cell = tableView.dequeueReusableCellWithIdentifier("NoteExpCell", forIndexPath: indexPath) as! DateTableViewCell

            let count = AllNotesCount[indexPath.row].count
            var txt = ""
            if count%10 == 1{
                txt = "заметка"
            }else if count%10 == 2 || count%10 == 3 || count%10 == 4 {
                txt = "заметки"
            }else{
                txt = "заметок"
            }
            
            if count > 10 && count < 15{
                txt = "заметок"
            }
            cell.textLabel?.text = AllNotesCount[indexPath.row].type
            cell.detailTextLabel?.text = "\(count) \(txt)"
            cell.backgroundColor = .clearColor()
            cell.selectedBackgroundView?.backgroundColor = .clearColor()
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("NotifiExpCell", forIndexPath: indexPath) as! DateTableViewCell
            let count = NotificationExport.count
            var txt = ""
            if count%10 == 1{
                txt = "уведомление"
            }else if count%10 == 2 || count%10 == 3 || count%10 == 4 {
                txt = "уведомления"
            }else{
                txt = "уведомлений"
            }
            
            if count > 10 && count < 15{
                txt = "уведомлений"
            }
            cell.detailTextLabel?.text = "\(count) \(txt)"
            cell.backgroundColor = .clearColor()
            cell.selectedBackgroundView?.backgroundColor = .clearColor()
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == DateTable{
            
            selectionDateType = indexPath.row
            selectedExportDays.removeAll()
            if selectionDateType == 0 {
                let vc1 = self.storyboard?.instantiateViewControllerWithIdentifier("CalendarExport")
                self.navigationController?.pushViewController(vc1!, animated: true)
            }else{
                if dateType != -1 {
                let vc1 = self.storyboard?.instantiateViewControllerWithIdentifier("CalendarExport")
                self.navigationController?.pushViewController(vc1!, animated: true)
                }
            }
        }else if tableView == NotesTable{

        }else{

        }
    }
    
    //collectionView
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  ExpPhoto.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let PhotoCell = collectionView.dequeueReusableCellWithReuseIdentifier("ExpPhotoSelCell", forIndexPath: indexPath) as! ExportPhotoCollectionViewCell
        PhotoCell.photo.image = ExpPhoto[indexPath.row].image
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: ExpPhoto[indexPath.row].date)
        var string = ""
        if(components.month<10)
        {
            string = "0\(components.month)"
        }
        else
        {
            string = "\(components.month)"
        }
        
        var stringday = ""
        if(components.day<10)
        {
            stringday = "0\(components.day)"
        }
        else
        {
            stringday = "\(components.day)"
        }
        
        PhotoCell.title.text = "\(stringday).\(string).\(components.year)"

        //PhotoCell.ImgSelector.hidden = true
        return PhotoCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ExportPhotoCollectionViewCell
        if(cell.ImgSelector.hidden == true){
            //cell.ImgSelector.hidden = false
            //selectedImages.append(cell.photo.image!)
            cell.selected = true
        }else{
            //selectedImages.removeAtIndex(selectedImages.indexOf(cell.photo.image!)!)
            //cell.ImgSelector.hidden = true
            cell.selected = false
        }
    }
    
    func loadNotes(){
        NotesExportText.removeAll()
        NotestExportWeight.removeAll()
        NotesExportFood.removeAll()
        NotesExportDoctor.removeAll()
        NotesExportDrugs.removeAll()
        
        let days = selectedExportDays.sort(self.frontwards)
        for day_ in days{
            NotesFromDate(day_)
        }
        AllNotesCount.removeAll()
        var temp = [AllNotesForExport]()
        var mas = [String]()
        for note in NotesExportText{
            if !mas.contains(note.typeS){
                mas.append(note.typeS)
            }
        }
        
        if mas.count > 0{
            for type in mas{
                var count = 0
                for n in NotesExportText {
                    if n.typeS == type{
                        count += 1
                    }
                }
                AllNotesCount.append(AllNotesForExport(type: type, text: "", count: count,selected: false))
            }
        }
        
        if NotestExportWeight.count > 0{
            AllNotesCount.append(AllNotesForExport(type: "Мой вес", text: "", count: NotestExportWeight.count, selected: false))
        }

        if NotesExportDrugs.count > 0{
            AllNotesCount.append(AllNotesForExport(type: "Принимаемые лекарства", text: "", count: NotesExportDrugs.count,selected: false))
        }
        if NotesExportDoctor.count > 0{
            AllNotesCount.append(AllNotesForExport(type: "Посещение врачей", text: "", count: NotesExportDoctor.count,selected:
                false))
        }
        if NotesExportFood.count > 0{
            AllNotesCount.append(AllNotesForExport(type: "Мое меню на сегодня", text: "", count: NotesExportFood.count,selected: false))
        }
    }
    
    func NotesFromDate(date: NSDate){
    
        var table = Table("TextNote")
        let Date = Expression<String>("Date")
        let type = Expression<Int64>("Type")
        let text = Expression<String>("NoteText")
        //count += try db.scalar(table.filter(Date == "\(selectedCalendarDay.date.convertedDate()!)").count)
        for i in try! db.prepare(table.select(text, type).filter(Date == "\(date)")){
            var str = ""
            switch i[type] {
            case 0:
                str = "Мое самочувствие"
            case 1:
                str = "Как ведет себя малыш"
            case 5:
                str = "Приятное воспоминание дня"
            case 6:
                str = "Важные события"
            default:
                str = ""
            }
            NotesExportText.append(TextNoteE(typeS: str, text: i[text], date: date))
        }
        table = Table("WeightNote")
        let kg = Expression<Int64>("WeightKg")
        let gr = Expression<Int64>("WeightGr")
        //count += try db.scalar(table.filter(Date == "\(selectedCalendarDay.date.convertedDate()!)").count)
        for i in try! db.prepare(table.select(kg, gr).filter(Date == "\(date)")){
            NotestExportWeight.append(Weight(date: date, kg: Int(i[kg]), gr: Int(i[gr]), week: -1))
        }
        
        
        table = Table("DoctorVisit")
        let name = Expression<String>("Name")
        let calendar = NSCalendar.currentCalendar()
        
        var components = calendar.components([.Day , .Month , .Year], fromDate: date)
        for i in try! db.prepare(table.select(Date,name)) {
            let b = i[Date]
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
            let componentsCurrent = calendar.components([.Day , .Month , .Year], fromDate: dateFormatter.dateFromString(b)!)
            if components.day == componentsCurrent.day && components.month == componentsCurrent.month && components.year == componentsCurrent.year {
                NotesExportDoctor.append(Doctor(date: date, name: i[name], isRemind: false, remindType: 0, cellType: 0))
            }
        }
        
        table = Table("Food")
        let textFood = Expression<String>("Text")
        //count += try db.scalar(table.filter(Date == "\(selectedCalendarDay.date.convertedDate()!)").count)
        for i in try! db.prepare(table.select(textFood).filter(Date == "\(date)")){
            NotesExportFood.append(Food(text: i[textFood], date: date))
        }
        
        
        table = Table("MedicineTake")
        let start = Expression<String>("Start")
        let end = Expression<String>("End")
        let isRemind = Expression<Bool>("isRemind")
        let hour_ = Expression<Int>("Hour")
        let minute_ = Expression<Int>("Minute")
        let interval_ = Expression<Int>("Interval")
        
        components = calendar.components([.Day , .Month , .Year], fromDate: date)
        components.hour = 00
        components.minute = 00
        components.second = 00
        let newcurDate = calendar.dateFromComponents(components)
        
        for i in try! db.prepare(table.select(name,start,end,isRemind,hour_,minute_,interval_)) {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
            let componentsS = calendar.components([.Day , .Month , .Year], fromDate: dateFormatter.dateFromString(i[start])!)
            let componentsE = calendar.components([.Day , .Month , .Year], fromDate: dateFormatter.dateFromString(i[end])!)
            componentsS.hour = 00
            componentsS.minute = 00
            componentsS.second = 00
            let newDateS = calendar.dateFromComponents(componentsS)
            componentsE.hour = 00
            componentsE.minute = 00
            componentsE.second = 00
            let newDateE = calendar.dateFromComponents(componentsE)
            let a = newcurDate?.compare(newDateS!)
            let b = newcurDate?.compare(newDateE!)
            if (a == NSComparisonResult.OrderedDescending || a == NSComparisonResult.OrderedSame) && (b == NSComparisonResult.OrderedAscending || b == NSComparisonResult.OrderedSame) {
                NotesExportDrugs.append(Drugs(name: i[name], hour: i[hour_], minute: i[minute_], start: dateFormatter.dateFromString(i[start])!, end: dateFormatter.dateFromString(i[end])!, interval: i[interval_], isRemind: i[isRemind], cellType: 0))
            }
        }
    }

    func loadNotifi(){
        if dateType != -1 {
            //300 - BirthDate.daysFrom(selectedDay.date.convertedDate()!)
            let days = selectedExportDays.sort(self.frontwards)
            NotificationExport.removeAll()
            let table = Table("Notification")
            let day = Expression<Int64>("Day")
            let text = Expression<String>("Text")
            let type = Expression<Int64>("CategoryId")
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Day , .Month , .Year], fromDate: BirthDate)
            components.hour = 24
            components.minute = 00
            components.second = 00
            let NewDate = calendar.dateFromComponents(components)!
            for i in days{
                let a = calculateDay(i)
                for j in try! db.prepare(table.select(text,type).filter(day == Int64(a))){
                    var str = ""
                    switch j[type] {
                    case 1:
                        str = "Общая информация"
                    case 2:
                        str = "Здоровье мамы"
                    case 3:
                        str = "Здоровье малыша"
                    case 4:
                        str = "Питание"
                    case 5:
                        str = "Это важно!"
                    case 6:
                        str = "Скрытая реклама"
                    case 7:
                        str = "Рекалама ФЭСТ"
                    case 8:
                        str = "Размышления ФЭСТ"
                    default:
                        str = ""
                    }
                    NotificationExport.append(TextNoteE(typeS: str, text: j[text], date: i))
                }
            }
        }
    }
    
    func loadPhotos(){
        ExpPhoto.removeAll()
        
        let days = selectedExportDays.sort(self.frontwards)
        for day_ in days{
            PhotoFromDate(day_)
        }
    }
    
    func PhotoFromDate(Date: NSDate){
        var table = Table("Photo")
        let date = Expression<String>("Date")
        let image = Expression<Blob>("Image")
        let text = Expression<String>("Text")
        let count = try db.scalar(table.filter(date == "\(Date)").count)
        for i in try! db.prepare(table.filter(date == "\(Date)")) {
            let a = i[image] 
            let c = NSData(bytes: a.bytes, length: a.bytes.count)
            let b = i[date]
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
            ExpPhoto.append(Photo(image: UIImage(data: c)!, date: dateFormatter.dateFromString(b)!, text: i[text]))
        }
        
        table = Table("Uzi")
        for i in try! db.prepare(table.filter(date == "\(Date)")) {
            let a = i[image] 
            let c = NSData(bytes: a.bytes, length: a.bytes.count)
            let b = i[date]
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
            ExpPhoto.append(Photo(image: UIImage(data: c)!, date: dateFormatter.dateFromString(b)!, text: i[text]))
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        /*NotesExportText.removeAll()
        NotestExportWeight.removeAll()
        NotesExportFood.removeAll()
        NotesExportDoctor.removeAll()
        NotesExportDrugs.removeAll()
        AllNotesCount.removeAll()
        selectionDateType = -1
        selectedExportDays.removeAll()
        ExpPhoto.removeAll()
        NotificationExport.removeAll()*/
    }
}

extension UISplitViewController {
    var xx_primaryViewController: UIViewController? {
        get {
            return self.viewControllers[0] as? UIViewController
        }
    }
    
    var xx_secondaryViewController: UIViewController? {
        get {
            if self.viewControllers.count > 1 {
                return self.viewControllers[1] as? UIViewController
            }
            return nil
        }
    }
}
