//
//  DoctorViewCell.swift
//  AccordionMenu
//
//  Created by Roman Efimov on 04.05.16.
//  Copyright © 2016 Zaeem Solutions. All rights reserved.
//

import UIKit

class DoctorViewCell: UITableViewCell {

    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var timebutton: UIButton!
    @IBOutlet weak var notifibutton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
     
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
