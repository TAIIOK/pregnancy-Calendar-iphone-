//
//  CustomCollectionViewLayout.swift
//  CustomCollectionLayout
//
//  Created by JOSE MARTINEZ on 15/12/2014.
//  Copyright (c) 2014 brightec. All rights reserved.
//

import UIKit

class CustomCollectionViewLayout: UICollectionViewLayout {
    let numberOfColumns = 5
    var itemAttributes : NSMutableArray!
    var itemsSize : NSMutableArray!
    var contentSize : CGSize!
    
    override func prepareLayout() {
        if self.collectionView?.numberOfSections() == 0 {
            return
        }
        
        self.itemAttributes = nil
        if (self.itemAttributes != nil && self.itemAttributes.count > 0) {
            for section in 0..<self.collectionView!.numberOfSections() {
                for index in 0..<self.collectionView!.numberOfItemsInSection(section) {
                    if section != 0 && index != 0 {
                        continue
                    }
                    
                    let attributes = self.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: index, inSection: section))
                    if section == 0 {
                        var frame = attributes!.frame
                        frame.origin.y = self.collectionView!.contentOffset.y
                        attributes!.frame = frame
                    }
                    
                    if index == 0 {
                        var frame = attributes!.frame
                        frame.origin.x = self.collectionView!.contentOffset.x
                        attributes!.frame = frame
                    }
                }
            }
        
            return
        }
        
        if (self.itemsSize == nil || self.itemsSize.count != self.numberOfColumns) {
            self.calculateItemsSize()
        }
        
        var column = 0
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        var contentWidth: CGFloat = 0
        var contentHeight: CGFloat = 0
        
        for section in 0..<self.collectionView!.numberOfSections() {
            let sectionAttributes = NSMutableArray()
            
            for index in 0..<self.numberOfColumns {
                let itemSize = self.itemsSize[index].CGSizeValue()
                let indexPath = NSIndexPath(forItem: index, inSection: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.frame = CGRectIntegral(CGRectMake(xOffset, yOffset, itemSize.width, itemSize.height))
                
                if section == 0 && index == 0 {
                    attributes.zIndex = 1024;
                } else if section == 0 || index == 0 {
                    attributes.zIndex = 1023
                }
                
                if section == 0 {
                    var frame = attributes.frame
                    frame.origin.y = self.collectionView!.contentOffset.y
                    attributes.frame = frame
                }
                
                if index == 0 {
                    var frame = attributes.frame
                    frame.origin.x = self.collectionView!.contentOffset.x
                    attributes.frame = frame
                }
                
                sectionAttributes.addObject(attributes)
                
                xOffset += itemSize.width
                column += 1
                
                if column == self.numberOfColumns {
                    if xOffset > contentWidth {
                        contentWidth = xOffset
                    }
                    
                    column = 0
                    xOffset = 0
                    yOffset += itemSize.height
                }
            }
            
            if (self.itemAttributes == nil) {
                self.itemAttributes = NSMutableArray(capacity: self.collectionView!.numberOfSections())
            }
            
            self.itemAttributes.addObject(sectionAttributes)
        }
        
        let attributes = self.itemAttributes.lastObject?.lastObject as! UICollectionViewLayoutAttributes
        contentHeight = attributes.frame.origin.y + attributes.frame.size.height
        self.contentSize = CGSizeMake(contentWidth, contentHeight)
    }
    
    override func collectionViewContentSize() -> CGSize {
        return self.contentSize
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let sectionAttributes = self.itemAttributes [indexPath.section] as![UICollectionViewLayoutAttributes]
        return sectionAttributes[indexPath.row] as UICollectionViewLayoutAttributes
        
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        if self.itemAttributes != nil {
            for section in self.itemAttributes {
                
                let filteredArray = section.filteredArrayUsingPredicate(NSPredicate(block: { (evaluatedObject, bindings) -> Bool in return CGRectIntersectsRect(rect, evaluatedObject.frame) })) as! [UICollectionViewLayoutAttributes]
                attributes.appendContentsOf(filteredArray)
            }
        }
        
        return attributes
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    func sizeForItemWithColumnIndex(columnIndex: Int) -> CGSize {
        var text = ""
        switch (columnIndex) {
        case 0:
            text = ""
        case 1:
            text = "НАЧАЛО "
        case 2:
            text = "ДЛИТЕЛЬНОСТЬ"
        case 3:
            text = "КОНЕЦ  "
        case 4:
            text = "ПРОМЕЖУТОК"
        default:
            text = ""
        }
        
        let size = (text as NSString).sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(12.0)])
        let width = size.width + 25
        return CGSizeMake(width, 30)
    }
    
    func calculateItemsSize() {
        self.itemsSize = NSMutableArray(capacity: self.numberOfColumns)
        for index in 0..<self.numberOfColumns {
            self.itemsSize.addObject(NSValue(CGSize: self.sizeForItemWithColumnIndex(index)))
        }
    }
}