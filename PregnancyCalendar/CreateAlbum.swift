//
//  CreateAlbum.swift
//  Календарь беременности
//
//  Created by Roman Efimov on 02.06.16.
//  Copyright © 2016 deck. All rights reserved.
//

import Foundation
import Photos

func getDate() -> String{

    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Day , .Month , .Year], fromDate: NSDate())

    return "\(components.day).\(components.month).\(components.year)"

}

    class CustomPhotoAlbum {
        
        static let albumName = "Календарь беременности (\(getDate()))"
        static let sharedInstance = CustomPhotoAlbum()
        
        var assetCollection: PHAssetCollection!
        
        init() {
            
            func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
                let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
                
                if let firstObject: AnyObject = collection.firstObject {
                    return collection.firstObject as! PHAssetCollection
                }
                
                return nil
            }
            
            if let assetCollection = fetchAssetCollectionForAlbum() {
                self.assetCollection = assetCollection
                return
            }
            
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(CustomPhotoAlbum.albumName)
            }) { success, _ in
                if success {
                    self.assetCollection = fetchAssetCollectionForAlbum()
                }
            }
        }
        
        func saveImage(image: UIImage) {
            
            if assetCollection == nil {
                return   // If there was an error upstream, skip the save.
            }
            
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
                albumChangeRequest!.addAssets([assetPlaceholder!])
                }, completionHandler: nil)
        }
        
        
}