//
//  WildBerriesTableViewCell.swift
//  PregnancyCalendar
//
//  Created by farestz on 28.03.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit

class WildBerriesTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    @IBAction func buttonTouched(sender: UIButton) {
        if let url = NSURL(string: "https://wildberries.ru") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.button.clipsToBounds = true
        self.button.layer.cornerRadius = 4
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
