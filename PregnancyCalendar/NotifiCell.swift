//
//  NotifiCell.swift
//  Календарь беременности
//
//  Created by deck on 12.05.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit

class NotifiCell: UITableViewCell {
    
    @IBOutlet weak var textLbl: UILabel!
    
    @IBOutlet weak var img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
