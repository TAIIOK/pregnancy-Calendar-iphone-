//
//  WeightGraphViewController.swift
//  PregnancyCalendar
//
//  Created by farestz on 25.02.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit

class WeightGraphViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var growth = 0
    var firstComponent = [0, 1, 2]
    var secondComponent = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    var thirdComponent = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var pickerViewTextField: UITextField!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var growthButton: UIBarButtonItem!

    @IBAction func growthButtonPress(sender: UIBarButtonItem) {
        self.pickerViewTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.growth = loadGrowthFromCoreData()
        self.navigationItem.rightBarButtonItem?.title = self.growth == 0 ? "Ваш рост" : "\(self.growth) см"
        self.setupSidebarMenu()
        self.setupGrowthPickerView()
        self.setupGrowthPickerViewToolbar()
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
        self.setupPickerViewValues()
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
            self.alertToNotes()
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