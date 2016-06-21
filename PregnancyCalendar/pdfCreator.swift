//
//  pdfCreator.swift
//  Календарь беременности
//
//  Created by Roman Efimov on 23.05.16.
//  Copyright © 2016 deck. All rights reserved.
//

import Foundation
import UIKit

let defaultResolution: Int = 72


func toPDF(views: [UIView]) -> NSData? {
    
    if views.isEmpty {
        return nil
    }
    
    let pdfData = NSMutableData()
    UIGraphicsBeginPDFContextToData(pdfData, CGRect(x: 0, y: 0, width: 700, height: 600), nil)
    
    let context = UIGraphicsGetCurrentContext()
    
    for view in views {
        UIGraphicsBeginPDFPage()
        view.layer.renderInContext(context!)
    }
    
    UIGraphicsEndPDFContext()
    
    return pdfData
}

extension NSData {
    
    class func convertImageToPDF(image: UIImage) -> NSData? {
        return convertImageToPDF(image, resolution: 96)
    }
    
    class func convertImageToPDF(image: UIImage, resolution: Double) -> NSData? {
        return convertImageToPDF(image, horizontalResolution: resolution, verticalResolution: resolution)
    }
    
    class func convertImageToPDF(image: UIImage, horizontalResolution: Double, verticalResolution: Double) -> NSData? {
        
        if horizontalResolution <= 0 || verticalResolution <= 0 {
            return nil;
        }
        
        let pageWidth: Double = Double(image.size.width) * Double(image.scale) * Double(defaultResolution) / horizontalResolution
        let pageHeight: Double = Double(image.size.height) * Double(image.scale) * Double(defaultResolution) / verticalResolution
        
        let pdfFile: NSMutableData = NSMutableData()
        
        let pdfConsumer: CGDataConsumerRef = CGDataConsumerCreateWithCFData(pdfFile as CFMutableDataRef)!
        
        var mediaBox: CGRect = CGRectMake(0, 0, CGFloat(pageWidth), CGFloat(pageHeight))
        
        let pdfContext: CGContextRef = CGPDFContextCreate(pdfConsumer, &mediaBox, nil)!
        
        CGContextBeginPage(pdfContext, &mediaBox)
        CGContextDrawImage(pdfContext, mediaBox, image.CGImage!)
        CGContextEndPage(pdfContext)
        
        
        return pdfFile
    }
    
    class func convertImageToPDF(image: UIImage, resolution: Double, maxBoundRect: CGRect, pageSize: CGSize) -> NSData? {
        
        if resolution <= 0 {
            return nil
        }
        
        var imageWidth: Double = Double(image.size.width) * Double(image.scale) * Double(defaultResolution) / resolution
        var imageHeight: Double = Double(image.size.height) * Double(image.scale) * Double(defaultResolution) / resolution
        
        let sx: Double = imageWidth / Double(maxBoundRect.size.width)
        let sy: Double = imageHeight / Double(maxBoundRect.size.height)
        
        if sx > 1 || sy > 1 {
            let maxScale: Double = sx > sy ? sx : sy
            imageWidth = imageWidth / maxScale
            imageHeight = imageHeight / maxScale
        }
        
        let imageBox: CGRect = CGRectMake(maxBoundRect.origin.x, maxBoundRect.origin.y + maxBoundRect.size.height - CGFloat(imageHeight), CGFloat(imageWidth), CGFloat(imageHeight));
        
        let pdfFile: NSMutableData = NSMutableData()
        
        let pdfConsumer: CGDataConsumerRef = CGDataConsumerCreateWithCFData(pdfFile as CFMutableDataRef)!
        
        var mediaBox: CGRect = CGRectMake(0, 0, pageSize.width, pageSize.height);
        
        let pdfContext: CGContextRef = CGPDFContextCreate(pdfConsumer, &mediaBox, nil)!
        
        CGContextBeginPage(pdfContext, &mediaBox)
        CGContextDrawImage(pdfContext, imageBox, image.CGImage!)
        CGContextEndPage(pdfContext)
        
        return pdfFile
    }
    
    
}
