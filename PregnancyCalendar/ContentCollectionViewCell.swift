//
//  ContentCollectionViewCell.swift
//  PregnancyCalendar
//
//  Created by farestz on 03.03.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit

class ContentCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .whiteColor()
        self.contentLabel.textColor = .blackColor()
        self.contentLabel.font = .boldSystemFontOfSize(7)
    }
}
