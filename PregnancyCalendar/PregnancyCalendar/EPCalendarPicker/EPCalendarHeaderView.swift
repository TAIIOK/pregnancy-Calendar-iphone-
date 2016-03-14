//
//  EPCalendarHeaderView.swift
//  EPCalendar
//
//  Created by Roman Efimov on 20/02/16.
//  Copyright © 2016 Roman Efimov. All rights reserved.
//

import UIKit

class EPCalendarHeaderView: UICollectionReusableView {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMonday: UILabel!    
    @IBOutlet weak var lblTuesday: UILabel!
    @IBOutlet weak var lblWednesday: UILabel!
    @IBOutlet weak var lblThursday: UILabel!
    @IBOutlet weak var lblFriday: UILabel!
    @IBOutlet weak var lblSaturday: UILabel!
    @IBOutlet weak var lblSunday: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let calendar = NSCalendar.currentCalendar()
        let weeksDayList = calendar.shortWeekdaySymbols
        
        if NSCalendar.currentCalendar().firstWeekday == 2 {
            lblMonday.text = weeksDayList[1]
            lblTuesday.text = weeksDayList[2]
            lblWednesday.text = weeksDayList[3]
            lblThursday.text = weeksDayList[4]
            lblFriday.text = weeksDayList[5]
            lblSaturday.text = weeksDayList[6]
            lblSunday.text = weeksDayList[0]
        } else {
            lblMonday.text = weeksDayList[0]
            lblTuesday.text = weeksDayList[1]
            lblWednesday.text = weeksDayList[2]
            lblThursday.text = weeksDayList[3]
            lblFriday.text = weeksDayList[4]
            lblSaturday.text = weeksDayList[5]
            lblSunday.text = weeksDayList[6]
        }

        
    }
    
    func updateWeekendLabelColor(color: UIColor) {
        if NSCalendar.currentCalendar().firstWeekday == 2 {
            lblSaturday.textColor = color
            lblSunday.textColor = color
        } else {
            lblMonday.textColor = color
            lblSunday.textColor = color
        }
    }
    
    func updateWeekdaysLabelColor(color: UIColor) {
    
        if NSCalendar.currentCalendar().firstWeekday == 2 {
            lblMonday.textColor = color
            lblTuesday.textColor = color
            lblWednesday.textColor = color
            lblThursday.textColor = color
            lblFriday.textColor = color
        } else {
            lblTuesday.textColor = color
            lblWednesday.textColor = color
            lblThursday.textColor = color
            lblFriday.textColor = color
            lblSaturday.textColor = color
        }
    

    }
    
}
