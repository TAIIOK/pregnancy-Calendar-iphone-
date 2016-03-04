//
//  CurrentPhotoViewController.swift
//  PregnancyCalendar
//
//  Created by farestz on 02.03.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit
import Photos

class CurrentPhotoViewController: UIViewController {
    var index = 0
    var photosAsset: PHFetchResult!
    var assetCollection: PHAssetCollection!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func buttonAction(sender: AnyObject) {

    }
    @IBAction func buttonTrash(sender: AnyObject) {
        let alert = UIAlertController(title: "Вы уверены, что хотите удалить это фото?", message: nil, preferredStyle: .ActionSheet)
        let deletePhotoAction = UIAlertAction(title: "Удалить фото", style: .Destructive, handler: { (alert) in
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let request = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
                request?.removeAssets([self.photosAsset[self.index]])
                }, completionHandler: { (success, error) in
                    self.photosAsset = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
                    if self.photosAsset.count == 0 {
                        self.imageView.image = nil
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
                    
                    if self.index >= self.photosAsset.count {
                        self.index = self.photosAsset.count - 1
                    }
                    
                    self.displayPhoto()
            })
        })
        let cancelAction = UIAlertAction(title: "Отменить", style: .Cancel, handler: nil)
        alert.addAction(deletePhotoAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.displayPhoto()
    }

    private func displayPhoto() {
        let imageManager = PHImageManager.defaultManager()
        imageManager.requestImageForAsset(self.photosAsset[self.index] as! PHAsset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFit, options: nil, resultHandler: { (result, info) in self.imageView.image = result})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}