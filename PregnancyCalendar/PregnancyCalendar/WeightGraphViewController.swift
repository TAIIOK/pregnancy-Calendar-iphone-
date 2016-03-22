//
//  WeightGraphViewController.swift
//  PregnancyCalendar
//
//  Created by farestz on 25.02.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit

class WeightGraphViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, LineChartDelegate {
    
    // инднекс массы тела
    let IMT0: [CGFloat] = [0.5,0.9,1.4,1.6,1.8,2.0,2.7,3.2,4.5,5.4,6.8,7.7,8.6,9.8,10.2,11.3,12.5,13.6,14.5,15.2]
    let IMT1: [CGFloat] = [0.5,0.7,1.0,1.2,1.3,1.5,1.9,2.3,3.6,4.8,5.7,6.4,7.7,8.2,9.1,10.0,10.9,11.9,12.7,13.6]
    let IMT2: [CGFloat] = [0.5,0.5,0.6,0.7,0.8,0.9,1.0,1.4,2.3,2.9,3.4,3.9,5.0,5.4,5.9,6.4,7.3,7.9,8.6,9.1]
    
    var mass = 60
    var growth = 0
    var firstComponent = [0, 1, 2]
    var secondComponent = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    var thirdComponent = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    
    var lineChart: LineChart!
    var views: [String: AnyObject] = [:]
    
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var pickerViewTextField: UITextField!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var growthButton: UIBarButtonItem!
    @IBOutlet weak var label: UILabel!
    
    @IBAction func growthButtonPress(sender: UIBarButtonItem) {
        self.pickerViewTextField.becomeFirstResponder() // открывает пикер роста
        self.setupPickerViewValues()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.growth = loadGrowthFromCoreData()
        self.navigationItem.rightBarButtonItem?.title = self.growth == 0 ? "Ваш рост" : "\(self.growth) см"
        self.setupSidebarMenu()
        self.setupGrowthPickerView()
        self.setupGrowthPickerViewToolbar()
        self.setupGraph()
    }
    
    private func setupGraph() {
        if self.growth != 0 {
            self.drawGraph()
            self.label.hidden = true
        } else {
            self.label.hidden = false
        }
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
    
    func didSelectDataPoint(x: CGFloat, yValues: [CGFloat]) {
        
    }
    
    func drawGraph() {
        let factMass = UILabel()
        factMass.text = "                  Фактический вес"
        factMass.translatesAutoresizingMaskIntoConstraints = false
        factMass.textAlignment = NSTextAlignment.Left
        factMass.textColor=StrawBerryColor
        self.view.addSubview(factMass)
        self.views["factMass"] = factMass
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[factMass]-|", options: [], metrics: nil, views: self.views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-100-[factMass]", options: [], metrics: nil, views: self.views))
        
        let recommend = UILabel()
        recommend.text = "                 Условно-рекомендуемая норма"
        recommend.translatesAutoresizingMaskIntoConstraints = false
        recommend.textAlignment = NSTextAlignment.Center
        recommend.textColor=UIColor.blueColor()
        self.view.addSubview(recommend)
        self.views["recommend"] = recommend
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-100-[recommend]-|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-100-[recommend]", options: [], metrics: nil, views: views))
        
        // simple arrays
        let ves = Double(mass)
        let rost = Double(growth)
        let a = CGFloat(51)
        
        var data: [CGFloat] = [51]
        
        let b = CGFloat(ves)
        var data1 : [CGFloat] = [b]
        
        var imt=ves*10000.0
        let x: Double = rost*rost
        if(x>0){
            imt = imt/x}
        else{
            imt = 0
        }
        
        for (var i=0; i<20;i++){
            if(mass==0){
                data1.append(0)
            }
            else{
                if(imt < 18.5){
                    data1.append(b+IMT0[i])
                }
                else if (imt >= 25){
                    data1.append(b+IMT2[i])
                }
                else{
                    data1.append(b+IMT1[i])
                }
            }
            data.append(a+IMT2[i])
        }
        
        // simple line with custom x axis labels
        let xLabels: [String] = ["0","2", "4", "6", "8", "10", "12", "14", "16", "18", "20", "22", "24", "26", "28", "30", "32", "34", "36", "38", "40"]
        
        lineChart = LineChart()
        lineChart.animation.enabled = true
        lineChart.area = false
        lineChart.x.labels.visible = true
        lineChart.y.labels.visible = true
        lineChart.x.grid.count = 21
        lineChart.y.grid.count = 21
        lineChart.x.labels.values = xLabels
        lineChart.x.axis.visible = true
        lineChart.x.axis.color = UIColor.blueColor()
        lineChart.addLine(data)
        lineChart.addLine(data1)
        
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.delegate = self
        
        self.view.addSubview(lineChart)
        views["chart"] = lineChart
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[chart]-|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[factMass]-[chart(==500)]", options: [], metrics: nil, views: views))
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        if let chart = self.lineChart {
            chart.setNeedsDisplay()
        }
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
        }
    }
    
    func cancelButtonTouched() {
        self.pickerViewTextField.resignFirstResponder()
    }
    
    private func alertToNotes() {
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: "", message: "Теперь укажите свой вес в заметках, чтобы построить фактический график набор веса и отслеживать отклонения", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel, handler: { (alert) in self.dismissViewControllerAnimated(true, completion: nil)} )
            let notesAction = UIAlertAction(title: "В заметки", style: .Default, handler: { (alert) in self.actionToNotes() } )
            alert.addAction(cancelAction)
            alert.addAction(notesAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        else {
            let alert: UIAlertView = UIAlertView()
            alert.delegate = self
            alert.title = ""
            alert.message = "Теперь укажите свой вес в заметках, чтобы построить фактический график набор веса и отслеживать отклонения"
            alert.addButtonWithTitle("Отмена")
            alert.addButtonWithTitle("В заметки")
            
            alert.show()
            
        }

    }
    
    func actionToNotes() {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("NotesNavigationController") as? UINavigationController
        self.revealViewController().pushFrontViewController(controller, animated: true)

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
}