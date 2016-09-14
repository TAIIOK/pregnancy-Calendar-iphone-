//
//  OnePhotoViewController.swift
//  Календарь беременности
//
//  Created by deck on 04.05.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit


class OnePhotoViewController: UIViewController, UIPopoverPresentationControllerDelegate{
    
    var isKeyboard = false
    
    func keyboardWillShow(notification: NSNotification) {
        if !isKeyboard{
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                self.view.frame.origin.y -= keyboardSize.height
                isKeyboard = true
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if isKeyboard{
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                self.view.frame.origin.y += keyboardSize.height
                isKeyboard = false
            }
        }
    }
    
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var imageheight: NSLayoutConstraint!
    @IBOutlet weak var imagewidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        var Photo_temp = UIImage()
        if fromPhotoCal{
            Photo_temp = photoFromDate[currentPhoto].image
        }else{
            Photo_temp = choosedSegmentImages ? photos[currentPhoto].image : uzis[currentPhoto].image
        }
        let x = Double(Photo_temp.size.height)/Double(500)
        let y = Double(Photo_temp.size.width)/Double(400)
        let scale = x > y ? x : y
        let Photo = UIImage(CGImage: Photo_temp.CGImage!, scale: CGFloat(scale), orientation: Photo_temp.imageOrientation)
        image.frame.size.width = Photo.size.width
        image.frame.size.height = Photo.size.height
        imageheight.constant = Photo.size.height
        imagewidth.constant = Photo.size.width
        self.updateViewConstraints()
        image.image = Photo
        
        image.backgroundColor = .whiteColor()
        image.center = (image.superview?.center)!
        if fromPhotoCal{
            commentField.text = photoFromDate[currentPhoto].text
        }else{
            commentField.text = choosedSegmentImages ? photos[currentPhoto].text : uzis[currentPhoto].text
        }
        
        
        selectedImages.append(Photo_temp)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "popoverSegue"{
            let popoverVC = segue.destinationViewController as! ShareViewController
            popoverVC.modalPresentationStyle = .Popover
            popoverVC.popoverPresentationController?.delegate = self
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    @IBAction func SaveButton(sender: AnyObject) {
        if fromPhotoCal{
            var index = -1
            let count = photoFromDate[currentPhoto].isMyPhoto ? photos.count : uzis.count
            for(var i = 0; i < count; i += 1)
            {
                if(photoFromDate[currentPhoto].isMyPhoto)
                {
                    if photos[i].date == photoFromDate[currentPhoto].date && photos[i].image.CIImage == photoFromDate[currentPhoto].image.CIImage{
                        index = i;
                        break;
                    }
                }
                else{
                    if uzis[i].date == photoFromDate[currentPhoto].date && uzis[i].image.CIImage == photoFromDate[currentPhoto].image.CIImage{
                        index = i;
                        break;
                    }
                }

            }
            if(photoFromDate[currentPhoto].isMyPhoto)
            {
                photos[index].text = commentField.text!
            }
            else{
                uzis[index].text = commentField.text!
            }
            UpdatePhotosInDB_()
        }else{
            if(choosedSegmentImages)
            {
                photos[currentPhoto].text = commentField.text!
            }
            else{
                uzis[currentPhoto].text = commentField.text!
            }
            UpdatePhotosInDB()
        }

        
        self.view.makeToast(message: "Cохранено!", duration: 2.0, position:HRToastPositionDefault)
    }
    func UpdatePhotosInDB_(){
        if(photoFromDate[currentPhoto].isMyPhoto)
        {
            let table = Table("Photo")
            let date = Expression<String>("Date")
            let image = Expression<Blob>("Image")
            let text = Expression<String>("Text")
            
            let count = try! db.scalar(table.count)
            
            if count > 0{
                try! db.run(table.delete())
            }
            for var i in photos{
                let imageData = NSData(data: UIImageJPEGRepresentation(i.image, 1.0)!)
                try! db.run(table.insert(date <- "\(i.date)", image <- Blob(bytes: imageData.datatypeValue.bytes), text <- i.text))
            }
        }
        else{
            let table = Table("Uzi")
            let date = Expression<String>("Date")
            let image = Expression<Blob>("Image")
            let text = Expression<String>("Text")
            let count = try! db.scalar(table.count)
            
            if count > 0{
                try! db.run(table.delete())
            }
            
            for var i in uzis{
                let imageData = NSData(data: UIImageJPEGRepresentation(i.image, 1.0)!)
                let dateFormatter = NSDateFormatter()
                try! db.run(table.insert(date <- "\(i.date)", image <- Blob(bytes: imageData.datatypeValue.bytes), text <- i.text))
            }
        }

    }
    func UpdatePhotosInDB() {
        if(choosedSegmentImages)
        {
            let table = Table("Photo")
            let date = Expression<String>("Date")
            let image = Expression<Blob>("Image")
            let text = Expression<String>("Text")
            
            let count = try! db.scalar(table.count)
            
            if count > 0{
                try! db.run(table.delete())
            }
            for var i in photos{
                let imageData = NSData(data: UIImageJPEGRepresentation(i.image, 1.0)!)
                try! db.run(table.insert(date <- "\(i.date)", image <- Blob(bytes: imageData.datatypeValue.bytes), text <- i.text))
            }
        }
        else{
            let table = Table("Uzi")
            let date = Expression<String>("Date")
            let image = Expression<Blob>("Image")
            let text = Expression<String>("Text")
            let count = try! db.scalar(table.count)
            
            if count > 0{
                try! db.run(table.delete())
            }
            
            for var i in uzis{
                let imageData = NSData(data: UIImageJPEGRepresentation(i.image, 1.0)!)
                let dateFormatter = NSDateFormatter()
                try! db.run(table.insert(date <- "\(i.date)", image <- Blob(bytes: imageData.datatypeValue.bytes), text <- i.text))
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        selectedImages.removeAll()
        print("one photo disappear")
        fromPhotoCal = false
    }
    
    @IBAction func back(sender: UIBarButtonItem) {
        if fromPhotoCal{
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoFromCalendarNavigation1") as? UINavigationController
            self.revealViewController().pushFrontViewController(controller, animated: true)
        }else{
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("photo") as? UINavigationController
            self.revealViewController().pushFrontViewController(controller, animated: true)
        }
    }
    
    @IBAction func Delete(sender: UIBarButtonItem) {
        
        //Create the AlertController
        if #available(iOS 8.0, *) {
            let actionSheetController: UIAlertController = UIAlertController(title: "", message: "Удалить фото?", preferredStyle: .Alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Отмена", style: .Cancel) { action -> Void in
                //Do some stuff
            }
            actionSheetController.addAction(cancelAction)
            //Create and an option action
            let nextAction: UIAlertAction = UIAlertAction(title: "Удалить", style: .Default) { action -> Void in
                //Do some other stuff
                if fromPhotoCal{
                    var index = -1
                    let count = photoFromDate[currentPhoto].isMyPhoto ? photos.count : uzis.count
                    for(var i = 0; i < count; i += 1)
                    {
                        if(photoFromDate[currentPhoto].isMyPhoto)
                        {
                            if photos[i].date == photoFromDate[currentPhoto].date && photos[i].image.CIImage == photoFromDate[currentPhoto].image.CIImage{
                                index = i;
                                break;
                            }
                        }
                        else{
                            if uzis[i].date == photoFromDate[currentPhoto].date && uzis[i].image.CIImage == photoFromDate[currentPhoto].image.CIImage{
                                index = i;
                                break;
                            }
                        }

                    }
                    photoFromDate[currentPhoto].isMyPhoto ? photos.removeAtIndex(index) : uzis.removeAtIndex(index)
                    photoFromDate[currentPhoto].isMyPhoto ? self.deleteImage(index) : self.deleteImageUzi(index)
                }else{
                    choosedSegmentImages ? photos.removeAtIndex(currentPhoto) : uzis.removeAtIndex(currentPhoto)
                    choosedSegmentImages ? self.deleteImage(currentPhoto) : self.deleteImageUzi(currentPhoto)

                }
                cameras.removeAll()
                fillcamera()
                if fromPhotoCal{
                    let controller = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoFromCalendarNavigation1") as? UINavigationController
                    self.revealViewController().pushFrontViewController(controller, animated: true)
                }else{
                    let controller = self.storyboard?.instantiateViewControllerWithIdentifier("photo") as? UINavigationController
                    self.revealViewController().pushFrontViewController(controller, animated: true)
                }
            }
            actionSheetController.addAction(nextAction)
            
            //Present the AlertController
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    func backwards(s1: NSIndexPath, _ s2: NSIndexPath) -> Bool {
        return s1.row > s2.row
    }
    
    func savePhotos(img: UIImage, Type: Int, Text: String){
        
        let date = Expression<String>("Date")
        let image = Expression<Blob>("Image")
        let type = Expression<Int64>("Type")
        let text = Expression<String>("Text")
        
        let imageData = NSData(data: UIImageJPEGRepresentation(img, 1.0)!)
        
        if(Type == 0){
            let table = Table("Photo")
            try! db.run(table.insert(date <- "\(NSDate())", image <- Blob(bytes: imageData.datatypeValue.bytes), type <- Int64(Type), text <- Text))
        }else{
            let table = Table("Uzi")
            try! db.run(table.insert(date <- "\(NSDate())", image <- Blob(bytes: imageData.datatypeValue.bytes), type <- Int64(Type), text <- Text))
        }
    }
    
    func deleteImage(index: Int){
        let table = Table("Photo")
        let date = Expression<String>("Date")
        let image = Expression<Blob>("Image")
        let text = Expression<String>("Text")
        
        let count = try! db.scalar(table.count)
        
        if count > 0{
            try! db.run(table.delete())
        }
        for var i in photos{
            let imageData = NSData(data: UIImageJPEGRepresentation(i.image, 1.0)!)
            try! db.run(table.insert(date <- "\(i.date)", image <- Blob(bytes: imageData.datatypeValue.bytes), text <- i.text))
        }
    }
    
    func deleteImageUzi(index: Int){
        let table = Table("Uzi")
        let date = Expression<String>("Date")
        let image = Expression<Blob>("Image")
        let text = Expression<String>("Text")
        let count = try! db.scalar(table.count)
        
        if count > 0{
            try! db.run(table.delete())
        }
        
        for var i in uzis{
            let imageData = NSData(data: UIImageJPEGRepresentation(i.image, 1.0)!)
            try! db.run(table.insert(date <- "\(i.date)", image <- Blob(bytes: imageData.datatypeValue.bytes), text <- i.text))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
