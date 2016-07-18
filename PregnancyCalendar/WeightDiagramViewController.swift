//
//  WeightDiagramTableViewController.swift
//  rodicalc
//
//  Created by deck on 25.02.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit
import Charts
import CoreData

class Weight: NSObject {
    var date: NSDate
    var kg: Int
    var gr: Int
    var week: Int
    
    init(date: NSDate, kg: Int, gr: Int, week: Int) {
        self.date = date
        self.kg = kg
        self.gr = gr
        self.week = week
        super.init()
    }
}

class WeightDiagramViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var growth = 0
    var mass = 60
    var firstComponent = [0, 1, 2]
    var secondComponent = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    var thirdComponent = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    //var lineChart: LineChart!
    //var label = UILabel()
    //var label1 = UILabel()
    var views: [String: AnyObject] = [:]
    var BirthDate = NSDate()
    
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var lbl: UILabel!
    let IMT0: [Double] = [0.5,0.9,1.4,1.6,1.8,2.0,2.7,3.2,4.5,5.4,6.8,7.7,8.6,9.8,10.2,11.3,12.5,13.6,14.5,15.2]
    let IMT1: [Double] = [0.5,0.7,1.0,1.2,1.3,1.5,1.9,2.3,3.6,4.8,5.7,6.4,7.7,8.2,9.1,10.0,10.9,11.9,12.7,13.6]
    let IMT2: [Double] = [0.5,0.5,0.6,0.7,0.8,0.9,1.0,1.4,2.3,2.9,3.4,3.9,5.0,5.4,5.9,6.4,7.3,7.9,8.6,9.1]
    var weights: [Weight] = []
    
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var pickerViewTextField: UITextField!
    @IBOutlet weak var growthButton: UIBarButtonItem!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var weekDescription: UILabel!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        growth = loadGrowthFromCoreData()
        loadDate()
        loadWeight()
        self.navigationItem.rightBarButtonItem?.title = growth == 0 ? "Ваш рост" : "\(growth) см"
        setupGrowthPickerView()
        setupGrowthPickerViewToolbar()
        setupGraphSettings()
        setupSidebarMenu()
        if (growth > 0){
            //lbl.hidden = true
            drawGraph()
            weekDescription.hidden = false
            //drawDataDots(StrawBerryColor, X: 80 ,Y: 100)
            //drawDataDots(UIColor.blueColor(), X: 280 ,Y: 100)
            arrow.hidden = true
        }
        else{
            weekDescription.hidden = true
            arrow.hidden = false
            //lbl.hidden = false
        }
    }

    // выезжающее меню
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
    
    func loadWeight(){
        var table = Table("WeightNote")
        let date = Expression<String>("Date")
        let kg = Expression<Int64>("WeightKg")
        let gr = Expression<Int64>("WeightGr")
        var weights_: [Weight] = []
        for i in try! db.prepare(table.select(date ,kg , gr)) {
            let b = i[date]
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
            let week = Int((calculateDay(dateFormatter.dateFromString(b)!))/7)
            if week < 41 {
                weights_.append(Weight(date: dateFormatter.dateFromString(b)!, kg: Int(i[kg]), gr: Int(i[gr]),week: week))
            }
        }
        weights = weights_.sort(self.fronkwards)
    }
    
    func fronkwards(s1: Weight, _ s2: Weight) -> Bool {
        return s1.week < s2.week
    }
    private func setupGraphSettings() {
        // общие настройки
        self.lineChartView.descriptionText = "кг"
        self.lineChartView.descriptionTextPosition = CGPoint(x: 20, y: 25)
        self.lineChartView.descriptionFont = .systemFontOfSize(11)
        self.lineChartView.noDataText = "Для отображения графика"
        self.lineChartView.noDataTextDescription = "необходимо указать рост"
        self.lineChartView.infoFont = .systemFontOfSize(18)
        self.lineChartView.infoTextColor = BiruzaColor1
        self.lineChartView.scaleXEnabled = true
        self.lineChartView.scaleYEnabled = false
        self.lineChartView.pinchZoomEnabled = true
        self.lineChartView.rightAxis.enabled = false
        
        self.lineChartView.legend.form = .Circle
        self.lineChartView.xAxis.labelPosition = .Bottom
        self.lineChartView.legend.position = .AboveChartLeft
        self.lineChartView.legend.font = .systemFontOfSize(10)
        
        // оси
        self.lineChartView.xAxis.spaceBetweenLabels = 2
        self.lineChartView.xAxis.drawGridLinesEnabled = false
        self.lineChartView.leftAxis.drawAxisLineEnabled = false
        self.lineChartView.leftAxis.drawGridLinesEnabled = false
        
        self.lineChartView.leftAxis.gridLineWidth = 40
        self.lineChartView.leftAxis.gridColor = UIColor(red: 97/255.0, green: 195/255.0, blue: 255/255.0, alpha: 0.3)
    }
    
    private func drawGraph(){
        // сначала очистить график
        self.lineChartView.clear()
        
        // графики
        // нарисовать условно-рекомендуемый график
        let dataEntries = self.getChartDataEntriesForRecommend(Double(50))
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Условно-рекомендуемая норма")
        self.setRecommendSetStyle(lineChartDataSet)
        // нарисовать график фактического веса
        let weight = Double(mass)
        let growth_ = Double(growth)
        let dataEntriesSecond = self.getChartDataEntriesForFact(weight, growth: growth_)
        let lineChartDataSetSecond = LineChartDataSet(yVals: dataEntriesSecond, label: "Фактический вес")
        self.setFactSetStyle(lineChartDataSetSecond)
        
        // подписать недели
        var dataPoints: [String] = []
        for i in 0...40 {
            dataPoints.append("\(i)")
        }
        
        // готово
        let dataSets = [lineChartDataSetSecond, lineChartDataSet]
        self.lineChartView.data = LineChartData(xVals: dataPoints, dataSets: dataSets)
      }
    
    private func setRecommendSetStyle(lineChartDataSet: LineChartDataSet) {
        lineChartDataSet.setColor(BiruzaColor)
        lineChartDataSet.fillColor = BiruzaColor
        lineChartDataSet.setCircleColor(BiruzaColor)
        lineChartDataSet.circleHoleColor = BiruzaColor
        lineChartDataSet.lineWidth = 1
        lineChartDataSet.circleRadius = 6
        lineChartDataSet.valueFont = .systemFontOfSize(0)
    }
    private func setFactSetStyle(lineChartDataSet: LineChartDataSet) {
        lineChartDataSet.setColor(StrawBerryColor)
        lineChartDataSet.fillColor = StrawBerryColor
        lineChartDataSet.setCircleColor(StrawBerryColor)
        lineChartDataSet.circleHoleColor = StrawBerryColor
        lineChartDataSet.lineWidth = 2
        lineChartDataSet.circleRadius = 6
        lineChartDataSet.valueFont = .systemFontOfSize(0)
    }
    private func getChartDataEntriesForRecommend(weight: Double) -> [ChartDataEntry] {
        let weeks = self.getWeeks()
        var dataEntries: [ChartDataEntry] = []
        if weights.count > 0{
            var week = weights[0].week
            let growth_ = Double(growth)
            var null_weight = Double(weights[0].kg + weights[0].gr/100)
            let imt = Double( null_weight / (growth_/100 * growth_/100))
            var IMT = [Double]()
            if(imt < 18.5){
                IMT = IMT0
            }
            else if (imt >= 25){
                IMT = IMT2
            }
            else{
                IMT = IMT1
            }
            if week%2 != 0{
                week -= 1
            }
            /*for (var i = week/2-1; i >= 0; i -= 1){
             print(null_weight)
             null_weight -= IMT[i]
             }*/
            null_weight -= IMT[week/2-1]
            
            let dataEntry = ChartDataEntry(value: null_weight, xIndex: weeks[0])
            dataEntries.append(dataEntry)
            
            for i in 1..<weeks.count {
                let dataEntry = ChartDataEntry(value: null_weight + IMT[i-1], xIndex: weeks[i])
                dataEntries.append(dataEntry)
            }
        }else{
            let dataEntry = ChartDataEntry(value: weight, xIndex: weeks[0])
            dataEntries.append(dataEntry)
            
            for i in 1..<weeks.count {
                let dataEntry = ChartDataEntry(value: weight + self.IMT2[i-1], xIndex: weeks[i])
                dataEntries.append(dataEntry)
            }
        }
        return dataEntries
    }
    private func getChartDataEntriesForFact(weight: Double, growth: Double) -> [ChartDataEntry] {
        let weeks = self.getWeeks()
        var dataEntries: [ChartDataEntry] = []
        if weights.count > 0{
            for i in weights{
                let dataEntry = ChartDataEntry(value: Double(i.kg+i.gr/100), xIndex: i.week)
                dataEntries.append(dataEntry)
            }
        }else{
            let dataEntry = ChartDataEntry(value: 0, xIndex: weeks[0])
            dataEntries.append(dataEntry)
            for i in 1..<weeks.count {
                let dataEntry = ChartDataEntry(value: 0, xIndex: weeks[i])
                dataEntries.append(dataEntry)
            }
        }
        
        return dataEntries
    }
    private func getWeeks() -> [Int] {
        var weeks: [Int] = []
        
        for var i = 0; i <= 40; i += 2 {
            weeks.append(i)
        }
        
        return weeks
    }

    
    
    @IBAction func setHeight(sender: UIBarButtonItem) {
        self.pickerViewTextField.becomeFirstResponder()
    }
    
    private func setupGrowthPickerView()  {
        self.pickerViewTextField = UITextField(frame: CGRectZero)
        self.view.addSubview(self.pickerViewTextField)
        self.pickerView = UIPickerView(frame: CGRectMake(0, 0, 0, 0))
        self.pickerView.showsSelectionIndicator = true
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerView.backgroundColor = .whiteColor()
        self.pickerViewTextField.inputView = pickerView
        setupPickerViewValues()
    }
    
    private func setupPickerViewValues() {
        var rowIndex = growth
        self.pickerView.selectRow(rowIndex % 10, inComponent: 2, animated: true)
        rowIndex /= 10
        self.pickerView.selectRow(rowIndex % 10, inComponent: 1, animated: true)
        rowIndex /= 10
        self.pickerView.selectRow(rowIndex % 10, inComponent: 0, animated: true)
    }
    
    private func setupGrowthPickerViewToolbar() {
        let toolBar = UIToolbar(frame: CGRectMake(0, 0, 320, 40))
        toolBar.tintColor = StrawBerryColor
        toolBar.barTintColor = .whiteColor()
        let doneButton = UIBarButtonItem(title: "Готово", style: .Plain, target: self, action: Selector("doneButtonTouched"))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .Plain, target: self, action: Selector("cancelButtonTouched"))
        toolBar.setItems([cancelButton, flexSpace, doneButton], animated: true)
        self.pickerViewTextField.inputAccessoryView = toolBar
    }
    
    private func getGrowthFromPickerView() -> Int {
        return firstComponent[self.pickerView.selectedRowInComponent(0)]*100 + secondComponent[self.pickerView.selectedRowInComponent(1)]*10 + thirdComponent[self.pickerView.selectedRowInComponent(2)]
    }
    
    func doneButtonTouched() {
        self.pickerViewTextField.resignFirstResponder()
        growth = getGrowthFromPickerView()
        
        self.navigationItem.rightBarButtonItem?.title = "\(growth) см"
        saveGrowthToPlist(growth)
        setupPickerViewValues()
        if growth > 0{
        //Create the AlertController
            if #available(iOS 8.0, *) {
                let actionSheetController: UIAlertController = UIAlertController(title: "", message: "Теперь укажите свой вес в заметках, чтобы построить фактический график набора веса и отслеживать отклонения", preferredStyle: .Alert)
                
                //Create and add the Cancel action
                let cancelAction: UIAlertAction = UIAlertAction(title: "Отмена", style: .Cancel) { action -> Void in
                    //Do some stuff
                    let graph = self.storyboard?.instantiateViewControllerWithIdentifier("WeightGraphNavigationController")
                    self.revealViewController().setFrontViewController(graph!, animated: true)
                }
                actionSheetController.addAction(cancelAction)
                //Create and an option action
                let nextAction: UIAlertAction = UIAlertAction(title: "Заметки", style: .Default) { action -> Void in
                    //Do some other stuff
                    let notes = self.storyboard?.instantiateViewControllerWithIdentifier("NotesNavigationController")
                    self.revealViewController().setFrontViewController(notes!, animated: true)
                }
                actionSheetController.addAction(nextAction)
                
                //Present the AlertController
                self.presentViewController(actionSheetController, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
        }else{
            let graph = self.storyboard?.instantiateViewControllerWithIdentifier("WeightGraphNavigationController")
            self.revealViewController().setFrontViewController(graph!, animated: true)
        }
    }
    
    func cancelButtonTouched() {
        self.pickerViewTextField.resignFirstResponder()
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // save to plist
    private func saveGrowthToPlist(growth: Int) {
        if let plist = Plist(fileName: "userInfo") {
            let dict = plist.getMutablePlistFile()!
            dict[userGrowth] = growth
            
            do {
                try plist.addValuesToPlistFile(dict)
            } catch {
                print(error)
            }
        }
    }
    
    // load from plist
    private func loadGrowthFromCoreData() -> Int {
        if let plist = Plist(fileName: "userInfo") {
            let dict = plist.getValuesFromPlistFile()
            return (dict![userGrowth] as? Int)!
        } else {
            return 0
        }
    }
    
    // MARK: - UIPickerView
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return firstComponent.count
        } else if component == 1 {
            return secondComponent.count
        } else {
            return thirdComponent.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(firstComponent[row])"
        } else if component == 1 {
            return "\(secondComponent[row])"
        } else {
            return "\(thirdComponent[row])"
        }
    }
    
    func loadDate(){
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entityForName("BirthDate", inManagedObjectContext:managedContext)
        
        fetchRequest.entity = entityDescription
        do {
            let result = try managedContext.executeFetchRequest(fetchRequest)
            
            if (result.count > 0) {
                for i in result {
                    let date = i as! NSManagedObject
                    let dte = date.valueForKey("date") as! NSDate
                    dateType = date.valueForKey("type") as! Int
                    BirthDate = dte
                    if dateType == 0{
                        BirthDate = addDaystoGivenDate(BirthDate, NumberOfDaysToAdd: 7*38)
                    }
                    else if dateType == 1{
                        BirthDate = addDaystoGivenDate(BirthDate, NumberOfDaysToAdd: 7*40)
                    }
                }
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
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
}

