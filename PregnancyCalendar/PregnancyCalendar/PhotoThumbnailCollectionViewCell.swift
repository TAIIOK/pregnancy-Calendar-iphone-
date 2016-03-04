//
//  PhotoThumbnailCollectionViewCell.swift
//  PregnancyCalendar
//
//  Created by farestz on 02.03.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit

class PhotoThumbnailCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    func setImage(image: UIImage) {
        self.imageView.image = image
    }
}
