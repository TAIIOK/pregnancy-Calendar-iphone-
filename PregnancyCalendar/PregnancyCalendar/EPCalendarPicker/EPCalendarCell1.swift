//
//  EPCalendarCell1.swift
//  EPCalendar
//
//  Created by Roman Efimov on 20/02/16.
//  Copyright © 2016 Roman Efimov. All rights reserved.
//

import UIKit



class EPCalendarCell1: UICollectionViewCell {

    var currentDate: NSDate!
    var isCellSelectable: Bool?
    var isCellFirstEvent: Bool?
    var isCellSecondEvent: Bool?
    var isCellThirdEvent: Bool?
    
    @IBOutlet weak var lblDay: UILabel!
    
    @IBOutlet weak var first: UIImageView! = nil
    @IBOutlet weak var second: UIImageView! = nil
    @IBOutlet weak var third: UIImageView! = nil

    
    
    override func awakeFromNib() {

        super.awakeFromNib()
      
    }

    func selectedForLabelColor(color: UIColor) {
       
        self.lblDay.layer.cornerRadius = self.lblDay.frame.size.width/2
        self.lblDay.layer.backgroundColor = color.CGColor
        
        self.lblDay.textColor = UIColor.whiteColor()
    }
    
    func deSelectedForLabelColor(color: UIColor) {
        self.lblDay.layer.backgroundColor = UIColor.whiteColor().CGColor
        self.lblDay.textColor = color
    }
    
    func showEvents()
    {
        
        if(self.isCellFirstEvent != nil)
        {
        if(self.isCellFirstEvent!.boolValue){
        print(self.currentDate)
        self.first.image = UIImage(named: "Black_dot.png")
        }

        }
    }

    func setEvent(first : Bool, second : Bool, third : Bool) {
        
        if(first){
            self.isCellFirstEvent = true;
        }
        if(second){
            self.isCellSecondEvent = true;
        }
        if(third){
            self.isCellThirdEvent = true;
            
        }
        
    
}
    func setTodayCellColor(backgroundColor: UIColor) {
        
        self.lblDay.layer.cornerRadius = self.lblDay.frame.size.width/2
        self.lblDay.layer.backgroundColor = backgroundColor.CGColor
        self.lblDay.textColor  = UIColor.whiteColor()
    }
    
    func setEventCellColor(backgroundColor: UIColor)
    {
    self.lblDay.layer.cornerRadius = self.lblDay.frame.size.width/2
    self.lblDay.layer.backgroundColor = backgroundColor.CGColor
    self.lblDay.textColor  = UIColor.whiteColor()
    
    }
}
