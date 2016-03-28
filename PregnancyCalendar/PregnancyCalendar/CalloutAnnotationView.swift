//
//  CalloutAnnotationView.swift
//  SwiftMapViewCustomCallout
//
//  Created by Robert Ryan on 6/15/15.
//  Copyright (c) 2015 Robert Ryan. All rights reserved.
//
//  This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
//  http://creativecommons.org/licenses/by-sa/4.0/

import UIKit
import MapKit

/// Annotation view for the callout
///
/// This is the annotation view for the callout annotation.

class CalloutAnnotationView : MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
   
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    // if we (re)set the annotation, remove old observer for title, if any and add new one
    
    override var annotation: MKAnnotation? {

        didSet {
            updateCallout()
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        updateCallout()
    }
    
    let bubbleView = BubbleView()           // the view that actually represents the callout bubble
    let label = UILabel()                   // the label we'll add as subview to the bubble's contentView
    let font = UIFont.systemFontOfSize(10)  // the font we'll use
    
    /// Update size and layout of callout view
    
    func updateCallout() {
        if annotation == nil {
            return
        }
        
        var size = CGSizeZero
        if let string = annotation?.title where string != nil {
            let attributes = [NSFontAttributeName : font]

            var myMutableString = NSMutableAttributedString()
            myMutableString = NSMutableAttributedString(string: string!, attributes: [NSFontAttributeName:UIFont(name: "Helvetica Neue", size: 10.0)!])
            let pos = string?.startIndex.distanceTo((string?.characters.indexOf(":"))!)

            myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: NSRange(location: pos! ,length: (string?.characters.count)!-pos!))

            label.attributedText = myMutableString
            size = string!.sizeWithAttributes(attributes)
        }
        
        if size.width < 30 {
            size.width = 30
        }
        size.height = 30
        bubbleView.setContentViewSize(size)
        frame = bubbleView.bounds
        centerOffset = CGPoint(x: 0, y: -50)
    }
    
    /// Perform the initial configuration of the subviews
    
    func configure() {
        backgroundColor = UIColor.clearColor()
        
        addSubview(bubbleView)
        
        label.frame = CGRectInset(bubbleView.contentView.bounds, -1, -1)
        label.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        label.textAlignment = .Left
        label.font = font
        label.textColor = UIColor.blackColor()
        label.numberOfLines = 2
        bubbleView.contentView.addSubview(label)
        
        updateCallout()
    }
}

