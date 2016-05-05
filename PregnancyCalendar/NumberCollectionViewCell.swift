//
//  NumberCollectionViewCell.swift
//  PregnancyCalendar
//
//  Created by farestz on 03.03.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit

class NumberCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var numberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .whiteColor()
        self.numberLabel.textColor = .blackColor()
        self.numberLabel.font = .boldSystemFontOfSize(7)
    }
}
