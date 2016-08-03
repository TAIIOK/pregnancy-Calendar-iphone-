//
//  SetWeightViewController.swift
//  Календарь беременности
//
//  Created by deck on 22.07.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit

var setweight = false

class SetWeightViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var kgpicker: UIPickerView!
    @IBOutlet weak var grammpicker: UIPickerView!
    
    var firstComponent = [0, 1, 2]
    var secondComponent = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    var thirdComponent = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        kgpicker.delegate = self
        kgpicker.dataSource = self
        grammpicker.delegate = self
        grammpicker.dataSource = self
        setupPickerViewValues()
        setupPickerViewValuesGramm()
    }
    // MARK: - UIPickerView
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 && pickerView == kgpicker{
            return firstComponent.count
        } else {
            return secondComponent.count
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 && pickerView == kgpicker{
            return "\(firstComponent[row])"
        } else {
            return "\(secondComponent[row])"
        }
    }

    private func getWeightFromPickerView() -> Int {
        return secondComponent[self.kgpicker.selectedRowInComponent(0)]*100 + secondComponent[self.kgpicker.selectedRowInComponent(1)]*10 + secondComponent[self.kgpicker.selectedRowInComponent(2)]
    }
    
    private func getWeightFromPickerViewGramm() -> Int {
        return secondComponent[self.grammpicker.selectedRowInComponent(0)]*100 + secondComponent[self.grammpicker.selectedRowInComponent(1)]*10 + secondComponent[self.grammpicker.selectedRowInComponent(2)]
    }
    
    @IBAction func Cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func OK(sender: UIButton) {
        setweight = true
        RecWeight = Double(getWeightFromPickerView()) + Double(getWeightFromPickerViewGramm())/1000
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    private func setupPickerViewValues() {
        var rowIndex = Int(RecWeight)
        self.kgpicker.selectRow(rowIndex % 10, inComponent: 2, animated: true)
        rowIndex /= 10
        self.kgpicker.selectRow(rowIndex % 10, inComponent: 1, animated: true)
        rowIndex /= 10
        self.kgpicker.selectRow(rowIndex % 10, inComponent: 0, animated: true)
    }
    private func setupPickerViewValuesGramm() {
        var rowIndex = Int((RecWeight - Double(Int(RecWeight))) * 1000)
        self.grammpicker.selectRow(rowIndex % 10, inComponent: 2, animated: true)
        rowIndex /= 10
        self.grammpicker.selectRow(rowIndex % 10, inComponent: 1, animated: true)
        rowIndex /= 10
        self.grammpicker.selectRow(rowIndex % 10, inComponent: 0, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.performSegueWithIdentifier("setweight", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
