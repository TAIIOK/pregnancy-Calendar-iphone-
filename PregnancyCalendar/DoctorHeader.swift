//
//  DoctorHeader.swift
//  AccordionMenu
//
//  Created by Roman Efimov on 04.05.16.
//  Copyright © 2016 Zaeem Solutions. All rights reserved.
//

import UIKit

class DoctorHeader: UIView {


    var doctor:String
    var time:String
    var imageView:UIImageView
    var open:Bool
    var timestring:UILabel
    var doctorname:UILabel
    var doctornameText:UITextField
    var deletecross: UIImageView
    
    override init (frame : CGRect) {
        self.doctor = "Гениколог"
        self.time = "10:10"
        self.imageView = UIImageView()
        self.imageView.image = UIImage(named: "Bell-30_1")!
        self.imageView.highlightedImage = UIImage(named: "Bell-30")!
        self.imageView.frame =  CGRectMake(frame.width - 40,10,30,30)
        self.imageView.userInteractionEnabled = true
        self.imageView.tag = 99
        self.open = false
        self.timestring = UILabel(frame: CGRect(x: 50, y: 10, width: 85, height: 30))
        //self.timestring.font = .systemFontOfSize(9)
        self.doctorname  = UILabel(frame: CGRect(x: 105, y: 10, width: 210, height: 30))
        self.doctornameText = UITextField(frame: CGRect(x: 105, y: 10, width: 210, height: 30))
        self.doctornameText.hidden = true
        
        self.deletecross = UIImageView()
        self.deletecross.image = UIImage(named: "Delete-30 (1)")!
        self.deletecross.frame =  CGRectMake(10,15,20,20)
        self.deletecross.userInteractionEnabled = true
        self.deletecross.tag = 666
        
        super.init(frame : frame)
    }
    
    func  setupView(tag: Int, doctor: String, time: String ){
        self.tag = tag
        self.doctor = doctor
        self.time = time
        
        //self.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)
        
        
        self.frame = CGRectMake(0, 0, frame.width , 40)
        
        //let headerView = UIView(frame: CGRectMake(0, 0, 300, 40))
        
        self.tag = tag
        

        self.timestring.text = self.time  // sectionTitleArray.objectAtIndex(section) as? String
        self.addSubview(timestring)
        

        self.doctorname.text = self.doctor  // sectionTitleArray.objectAtIndex(section) as? String
        
        self.addSubview(deletecross)
        self.addSubview(doctorname)
        self.addSubview(doctornameText)
        self.addSubview(imageView)
    }
    
    func setopen(open : Bool)
    {
        self.open = open
    }
    
    func changeImage() {
    
        if (imageView.image == UIImage(named: "Bell-30_1")!)
        {
            imageView.image = imageView.highlightedImage
        }
        else {
          imageView.image = UIImage(named: "Bell-30_1")!
        }
        
        if let viewWithTag = self.viewWithTag(99) {
            viewWithTag.removeFromSuperview()
        }else{
            print("No!")
        }
        
        self.addSubview(imageView)
    }
    
    func changeFields()
    {
        
        if(self.open)
        {
        self.doctorname.hidden = true
        self.doctornameText.hidden = false
        }
        else{
        self.doctorname.hidden = false
        self.doctornameText.hidden = true
        }
        

        
        self.doctornameText.text = self.doctorname.text
    }
    

    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
