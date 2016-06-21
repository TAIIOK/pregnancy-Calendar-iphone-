//
//  DrugsTableViewCell.swift
//  Календарь беременности
//
//  Created by deck on 13.05.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit

class DrugsTableViewCell: UITableViewCell {

    @IBOutlet weak var timebutton: UIButton!
    @IBOutlet weak var startbutton: UIButton!
    @IBOutlet weak var stopbutton: UIButton!
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
