//
//  PhotosTableViewController.swift
//  rodicalc
//
//  Created by deck on 25.02.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit
import CoreData


//var photos = [UIImage]()
//var uzis = [UIImage]()

class Photo: NSObject {
    var image: UIImage
    var date: NSDate
    var text: String
    init(image: UIImage, date: NSDate, text: String) {
        self.image = image
        self.date = date
        self.text = text
        super.init()
    }
}

var photos = [Photo]()
var uzis = [Photo]()
var currentPhoto = 0


class PhotosViewController: UICollectionViewController, UIImagePickerControllerDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate {
    
    var picker = UIImagePickerController()
   
    @IBOutlet var PhotoCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadPhoto:", name:"LoadPhoto", object: nil)
        PhotoCollectionView.backgroundView = UIImageView(image: UIImage(named: "background.jpg"))
        PhotoCollectionView.backgroundColor = .clearColor()
        picker.delegate=self
        self.title = choosedSegmentImages ? "Мои фото" : "УЗИ"
        /*let a = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: #selector(PhotosViewController.openCamera))
        let b = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(PhotosViewController.addPhoto))
        a.tintColor = UIColor.whiteColor()
        b.tintColor = UIColor.whiteColor()
        //self.navigationItem.setLeftBarButtonItems([a,b], animated: true)
        self.navigationItem.leftBarButtonItems?.append(a)
        self.navigationItem.leftBarButtonItems?.append(b)*/
        
    }
    
    /*func loadPhoto(notification: NSNotification){
        dispatch_async(dispatch_get_main_queue(), {
            self.PhotoCollectionView.reloadData()
            return}
        )
    }*/
    
    @IBAction func toselect(sender: UIBarButtonItem) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("selectPhoto") as? UINavigationController
        self.revealViewController().pushFrontViewController(controller, animated: true)
    }
    
    @IBAction func back(sender: UIBarButtonItem) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoNavigationController") as? UINavigationController
        self.revealViewController().pushFrontViewController(controller, animated: true)
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.cameraCaptureMode = .Photo
            picker.modalPresentationStyle = .FormSheet
            presentViewController(picker, animated: true, completion: nil)
        }else{
            if #available(iOS 8.0, *) {
                let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .Alert)
                let ok = UIAlertAction(title: "OK", style:.Default, handler: nil)
                alert.addAction(ok)
                presentViewController(alert, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func addPhoto(){
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.modalPresentationStyle = .FormSheet
        //picker?.interfaceOrientation
        presentViewController(picker, animated: true, completion: nil)
    }
      func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let type: Int
        choosedSegmentImages ? (type=0) : (type=1)
        let Date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: NSDate())
        components.hour = 00
        components.minute = 00
        components.second = 00
        let newDate = calendar.dateFromComponents(components)
        choosedSegmentImages ? photos.append(Photo(image: chosenImage, date: newDate!, text: "")) : uzis.append(Photo(image: chosenImage, date: newDate!, text: ""))
        dismissViewControllerAnimated(true, completion: nil)
        dispatch_async(dispatch_get_main_queue(), {
            self.PhotoCollectionView.reloadData()
            return}
        )
        savePhotos(chosenImage,Type: type)
        cameras.removeAll()
        fillcamera()
    }

    
    @IBAction func SegmentChanger(sender: AnyObject) {
        self.reloadTable(sender.selectedSegmentIndex == 1 ? false : true)
    }
    private func reloadTable(index: Bool) {
        choosedSegmentImages = index
        PhotoCollectionView.reloadData()
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  choosedSegmentImages ? photos.count+1 : uzis.count+1
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        

        if indexPath.row == 0 {
            let PhotoCell = collectionView.dequeueReusableCellWithReuseIdentifier("AppendCell", forIndexPath: indexPath) as! PhotoAppendCell
            PhotoCell.image.image = UIImage(named: "Cross Filled-50")
            PhotoCell.backgroundColor = UIColor.lightGrayColor()
            return PhotoCell
        }else{
            let PhotoCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
            PhotoCell.photo.image = choosedSegmentImages ? photos[indexPath.row-1].image : uzis[indexPath.row-1].image
            return PhotoCell
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != 0{
            currentPhoto = indexPath.row-1
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("onePhoto") as? UINavigationController
            self.revealViewController().pushFrontViewController(controller, animated: true)
        }else{

            let actionSheetController: UIAlertController = UIAlertController(title: "", message: "", preferredStyle: .ActionSheet)
            
            //Create and add the Cancel action
            let camera: UIAlertAction = UIAlertAction(title: "Снять фото", style: .Default) { action -> Void in
                //Do some stuff
                self.openCamera()
            }
            actionSheetController.addAction(camera)
            //Create and an option action
            let galery: UIAlertAction = UIAlertAction(title: "Добавить фото", style: .Default) { action -> Void in
                //Do some other stuff
                self.addPhoto()
            }
            actionSheetController.addAction(galery)
            //Create and an option action
            let cancel: UIAlertAction = UIAlertAction(title: "Отмена", style: .Cancel) { action -> Void in
                //Do some other stuff
                
            }
            actionSheetController.addAction(cancel)
            //Present the AlertController
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        }
    }
    
    func savePhotos(img: UIImage, Type: Int){
       
        let date = Expression<String>("Date")
        let image = Expression<Blob>("Image")
        let text = Expression<String>("Text")
        let imageData = NSData(data: UIImageJPEGRepresentation(img, 1.0)!)
        let Date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: Date)
        components.hour = 00
        components.minute = 00
        components.second = 00
        let newDate = calendar.dateFromComponents(components)
        if(Type == 0){
            let table = Table("Photo")
            
            try! db.run(table.insert(date <- "\(newDate!)", image <- Blob(bytes: imageData.datatypeValue.bytes), text <- ""))
        }else{
            let table = Table("Uzi")
            try! db.run(table.insert(date <- "\(newDate!)", image <- Blob(bytes: imageData.datatypeValue.bytes), text <- ""))
        }

    }
 
    func loadPhotos(){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            photos.removeAll()
            uzis.removeAll()
            var table = Table("Photo")
            let date = Expression<String>("Date")
            let image = Expression<Blob>("Image")
            let type = Expression<Int64>("Type")
            let text = Expression<String>("Text")
            
            for i in try! db.prepare(table.select(date,image,type,text)) {
                let a = i[image]
                let c = NSData(bytes: a.bytes, length: a.bytes.count)
                let b = i[date]
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
                print(dateFormatter.dateFromString(b)!)
                photos.append(Photo(image: UIImage(data: c)!, date: dateFormatter.dateFromString(b)!, text: i[text]))
                NSNotificationCenter.defaultCenter().postNotificationName("LoadPhoto", object: nil)
            }
            
            table = Table("Uzi")
            for i in try! db.prepare(table.select(date,image,type,text)) {
                let a = i[image]
                let c = NSData(bytes: a.bytes, length: a.bytes.count)
                let b = i[date]
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
                uzis.append(Photo(image: UIImage(data: c)!, date: dateFormatter.dateFromString(b)!, text: i[text]))
                NSNotificationCenter.defaultCenter().postNotificationName("LoadPhoto", object: nil)
            }
        }
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


