//
//  WeightGraphViewController.swift
//  PregnancyCalendar
//
//  Created by farestz on 25.02.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit
import Charts

class WeightGraphViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // ИМТ < 18.5; ИМТ = 18.5 < 24.99; ИМТ >= 25
    //let IMT0: [Double] = [0.5, 0.9, 1.4, 1.6, 1.8, 2.0, 2.7, 3.2, 4.5, 5.4, 6.8, 7.7, 8.6, 9.8, 10.2, 11.3, 12.5, 13.6, 14.5, 15.2]
    let IMT1: [Double] = [0.5, 0.7, 1.0, 1.2, 1.3, 1.5, 1.9, 2.3, 3.6, 4.8, 5.7, 6.4, 7.7, 8.2, 9.1, 10.0, 10.9, 11.9, 12.7, 13.6]
    //let IMT2: [Double] = [0.5, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.4, 2.3, 2.9, 3.4, 3.9, 5.0, 5.4, 5.9, 6.4, 7.3, 7.9, 8.6, 9.1]
    
    // рост и вес (вес потом будет браться из заметок)
    let mass: [Double] = []
    var growth = 0
    
    var firstComponent = [0, 1, 2]
    var secondComponent = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    var thirdComponent = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var pickerViewTextField: UITextField!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var growthButton: UIBarButtonItem!
    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBAction func growthButtonPress(sender: UIBarButtonItem) {
        self.pickerViewTextField.becomeFirstResponder() // открывает пикер роста
        self.setupPickerViewValues() // установить значения пикера
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // загрузить рост
        self.growth = self.loadGrowthFromPlist()
        self.navigationItem.rightBarButtonItem?.title = self.growth == 0 ? "Ваш рост" : "\(self.growth) см"
        
        // менюшка и пикер
        self.setupSidebarMenu()
        self.setupGrowthPickerView()
        self.setupGrowthPickerViewToolbar()
        
        // график
        self.setupGraph()
        self.setupGraphSettings()
    }
    
    // установка графика
    private func setupGraph() {
        if self.growth != 0 {
            self.label.hidden = true
            self.setChart()
        } else {
            self.label.hidden = false
        }
    }
    private func setupGraphSettings() {
        // общие настройки
        self.lineChartView.descriptionText = ""
        self.lineChartView.noDataText = "Для отображения графика"
        self.lineChartView.noDataTextDescription = "необходимо указать рост"
        
        self.lineChartView.scaleXEnabled = true
        self.lineChartView.scaleYEnabled = false
        self.lineChartView.pinchZoomEnabled = true
        self.lineChartView.rightAxis.enabled = false
        
        self.lineChartView.legend.form = .Circle
        self.lineChartView.xAxis.labelPosition = .Bottom
        self.lineChartView.legend.position = .AboveChartRight
        
        // оси
        self.lineChartView.xAxis.drawGridLinesEnabled = false
        self.lineChartView.leftAxis.drawAxisLineEnabled = false
        self.lineChartView.leftAxis.drawGridLinesEnabled = false
        
        // анимация
        self.lineChartView.animate(xAxisDuration: 1)
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
    
    // ГРАФИК
    private func setChart() {
        // сначала очистить график
        self.lineChartView.clear()
        
        // графики
        // нарисовать условно-рекомендуемый график
        let dataEntries = self.getChartDataEntriesForRecommend(Double(self.growth - 110))
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Условно-рекомендуемая норма")
        self.setRecommendSetStyle(lineChartDataSet)
        
        // нарисовать график фактического веса
        let dataEntriesSecond = self.getChartDataEntriesForFact()
        let lineChartDataSetSecond = LineChartDataSet(yVals: dataEntriesSecond, label: "Фактический вес")
        self.setFactSetStyle(lineChartDataSetSecond)
        
        // подписать недели
        var dataPoints: [String] = []
        for i in 1...40 {
            dataPoints.append("\(i)")
        }
        
        // готово
        let dataSets = [lineChartDataSetSecond, lineChartDataSet]
        self.lineChartView.data = LineChartData(xVals: dataPoints, dataSets: dataSets)
    }
    private func setRecommendSetStyle(lineChartDataSet: LineChartDataSet) {
        lineChartDataSet.setColor(.cyanColor())
        lineChartDataSet.fillColor = .cyanColor()
        lineChartDataSet.setCircleColor(.cyanColor())
        lineChartDataSet.circleHoleColor = .cyanColor()
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
        
        for i in 0..<weeks.count {
            let dataEntry = ChartDataEntry(value: weight + self.IMT1[i], xIndex: weeks[i])
            dataEntries.append(dataEntry)
        }
        
        return dataEntries
    }
    private func getChartDataEntriesForFact() -> [ChartDataEntry] {
        let weeks = self.getWeeks()
        var dataEntries: [ChartDataEntry] = []
        
        // ПРОТОТИП
        if self.mass.count != 0 {
            for i in 0..<self.mass.count {
                let dataEntry = ChartDataEntry(value: mass[i], xIndex: weeks[i])
                dataEntries.append(dataEntry)
            }
        } else {
            for i in 0..<weeks.count {
                let dataEntry = ChartDataEntry(value: Double(self.growth - 110), xIndex: weeks[i])
                dataEntries.append(dataEntry)
            }
        }
        
        return dataEntries
    }
    private func getWeeks() -> [Int] {
        var weeks: [Int] = []
        
        for var i = 2; i <= 40; i += 2 {
            weeks.append(i)
        }
        
        return weeks
    }
    
    // ПИКЕР
    private func setupGrowthPickerView()  {
        self.pickerViewTextField = UITextField(frame: CGRectZero)
        self.view.addSubview(self.pickerViewTextField)
        self.pickerView = UIPickerView(frame: CGRectMake(0, 0, 0, 0))
        self.pickerView.showsSelectionIndicator = true
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerView.backgroundColor = .whiteColor()
        self.pickerViewTextField.inputView = self.pickerView
    }
    private func setupPickerViewValues() {
        var rowIndex = self.growth
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
        return self.firstComponent[self.pickerView.selectedRowInComponent(0)]*100 + self.secondComponent[self.pickerView.selectedRowInComponent(1)]*10 + self.thirdComponent[self.pickerView.selectedRowInComponent(2)]
    }
    func doneButtonTouched() {
        self.cancelButtonTouched()
        self.growth = self.getGrowthFromPickerView()
        self.navigationItem.rightBarButtonItem?.title = self.growth == 0 ? "Ваш рост" : "\(self.growth) см"
        self.saveGrowthToPlist(self.growth)
        self.setupPickerViewValues()
        
        if self.growth != 0 {
            self.label.hidden = true
            self.setupGraph()
            self.alertToNotes()
        } else {
            self.label.hidden = false
            self.lineChartView.clear()
        }
    }
    func cancelButtonTouched() {
        self.pickerViewTextField.resignFirstResponder()
    }
    private func alertToNotes() {
        let alert = UIAlertController(title: "", message: "Теперь укажите свой вес в заметках, чтобы построить фактический график набор веса и отслеживать отклонения", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel, handler: { (alert) in self.dismissViewControllerAnimated(true, completion: nil)} )
        let notesAction = UIAlertAction(title: "В заметки", style: .Default, handler: { (alert) in self.actionToNotes() } )
        alert.addAction(cancelAction)
        alert.addAction(notesAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func actionToNotes() {
        self.dismissViewControllerAnimated(true, completion: nil)
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("NotesNavigationController") as? UINavigationController
        self.revealViewController().setFrontViewController(controller, animated: true)
    }
    
    // PLIST
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
    private func loadGrowthFromPlist() -> Int {
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
            return self.firstComponent.count
        } else if component == 1 {
            return self.secondComponent.count
        } else {
            return self.thirdComponent.count
        }
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(self.firstComponent[row])"
        } else if component == 1 {
            return "\(self.secondComponent[row])"
        } else {
            return "\(self.thirdComponent[row])"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}