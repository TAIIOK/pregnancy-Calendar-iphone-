//
//  ShowExportViewController.swift
//  Календарь беременности
//
//  Created by Roman Efimov on 27.05.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit

var segmenttype = true
var PDF = NSData()
class ShowExportViewController: UIViewController , UIScrollViewDelegate  {

    @IBOutlet weak var Segment: UISegmentedControl!
    @IBOutlet weak var CurrentScrollView: UIScrollView!
    
    @IBAction func SegmentAction(sender: AnyObject) {
        segmenttype = segmenttype ? false : true
        self.view.makeToastActivityWithMessage(message: "Пожалуйста, подождите.", addOverlay: true)
        dispatch_async(dispatch_get_main_queue(), {
            self.loadExportImages()
            self.view.hideToastActivity()
            return
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if segmenttype {
            Segment.selectedSegmentIndex = 0
        }else{
            Segment.selectedSegmentIndex = 1
        }
        
        CurrentScrollView.delegate = self
        CurrentScrollView.userInteractionEnabled = true
        CurrentScrollView.scrollEnabled = true
        CurrentScrollView.minimumZoomScale = 0.1
        CurrentScrollView.maximumZoomScale = 2
        CurrentScrollView.bouncesZoom = true
        //loadExportImages()
        sharingExportVk = true
        self.view.makeToastActivityWithMessage(message: "Пожалуйста, подождите.", addOverlay: true)
        dispatch_async(dispatch_get_main_queue(), {
            self.loadExportImages()
            self.view.hideToastActivity()
            return
        })
        
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        print("zooming")
    }
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        print("scroll zooming")
        return nil
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        sharingExportVk  = false
        PDF = NSData()
    }
    
    
    func loadExportImages()
    {
        selectedImages.removeAll()
        CurrentScrollView.removeAllSubviews()
        let height =  CGFloat(integerLiteral:  245 * AllExportNotes.count + 245 )
        CurrentScrollView.contentSize = CGSizeMake(350 , height)
        
        var y = CGFloat(integerLiteral: 0)
        
        if(segmenttype){
            CurrentScrollView.addSubview(CreateTitleBlue())
            selectedImages.append(CreateTitleBlue().image!)}
        else{
            CurrentScrollView.addSubview(CreateTitlePink())
            selectedImages.append(CreateTitlePink().image!)}
        
        //y += 10
        
        for( var i = 0;i < AllExportNotes.count ; i++)
        {
            
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Day , .Month , .Year], fromDate: AllExportNotes[i].date)
            
            var string = ""
            if(components.month<10)
            {
                string = "0\(components.month)"
            }
            else
            {
                string = "\(components.month)"
            }
            
            var stringday = ""
            if(components.day<10)
            {
                stringday = "0\(components.day)"
            }
            else
            {
                stringday = "\(components.day)"
            }
            
            
            let dateString = "\(stringday).\(string).\(components.year)"
            
            if(!AllExportNotes[i].photos.isEmpty && AllExportNotes[i].notes.isEmpty && AllExportNotes[i].notifi.isEmpty)
            {
                print("1")
                var photos = AllExportNotes[i].photos
                let image = UIImageView(frame: CGRect(x: 0, y: 0 , width: 350, height: 245))
                if(photos.count >= 2 ){
                    if(segmenttype){
                        image.image = CreateTwoPhotosBlue(photos[0].image, right: photos[1].image, title: dateString , leftText: photos[0].text, rightText: photos[1].text)
                    }
                    else{
                        image.image = CreateTwoPhotosPink(photos[0].image, right: photos[1].image, title: dateString , leftText: photos[0].text, rightText: photos[1].text)
                    }
                }else if (photos.count < 2 )  {
                    if(segmenttype){
                        image.image = CreateTwoPhotosBlue(photos[0].image, right: photos[0].image, title: dateString , leftText: photos[0].text, rightText: photos[0].text)
                    }else{
                        image.image = CreateTwoPhotosPink(photos[0].image, right: photos[0].image, title: dateString , leftText: photos[0].text, rightText: photos[0].text)
                    }
                }
                
                if(CurrentScrollView.subviews.count > 0)
                {
                    image.frame.origin.y = image.frame.height + y
                    y += image.frame.height
                }
                CurrentScrollView.addSubview(image)
                //y += 10
                selectedImages.append(image.image!)
                
            }else if(!AllExportNotes[i].photos.isEmpty && !AllExportNotes[i].notes.isEmpty || !AllExportNotes[i].notifi.isEmpty){
                print("2")
                var photos = AllExportNotes[i].photos
                
                if(photos.count >= 2 )
                {
                    let text = create_text(AllExportNotes[i].notes, notifi: AllExportNotes[i].notifi, type: 3)
                    for var i = 0; i < text.count; i += 1{
                        let image = UIImageView(frame: CGRect(x: 0, y: 0 , width: 350, height: 245))
                        if i == 0{
                            if(segmenttype){
                                image.image = CreateTextWithTwoPhotosBlue(photos[0].image, UpText: photos[0].text, DownPhoto: photos[1].image, DownText: photos[1].text, Title: dateString, CenterText: text[i])
                            }
                            else{
                                image.image = CreateTextWithTwoPhotosPink(photos[0].image, UpText: photos[0].text, DownPhoto: photos[1].image, DownText: photos[1].text, Title: dateString, CenterText: text[i])
                            }
                        }else{
                            CurrentScrollView.contentSize.height += 245
                            if(segmenttype){
                                image.image = CreateTextOnlyBlue(dateString , CenterText: text[i])
                            }
                            else{
                                image.image = CreateTextOnlyPink(dateString , CenterText: text[i])
                            }
                        }
                        
                        if(CurrentScrollView.subviews.count > 0)
                        {
                            image.frame.origin.y = image.frame.height + y
                            y += image.frame.height
                        }
                        CurrentScrollView.addSubview(image)
                        selectedImages.append(image.image!)
                        //y += 10
                    }
                    
                }else if (photos.count < 2  && photos.count != 0)  {
                    let text = create_text(AllExportNotes[i].notes, notifi: AllExportNotes[i].notifi, type: 3)
                    for var i = 0; i < text.count; i += 1{
                        let image = UIImageView(frame: CGRect(x: 0, y: 0 , width: 350, height: 245))
                        if i == 0{
                            if(segmenttype){
                                image.image = CreateTextWithTwoPhotosBlue(photos[0].image, UpText: photos[0].text, DownPhoto: photos[0].image, DownText: photos[0].text, Title: dateString, CenterText: text[i])
                            }
                            else{
                                image.image = CreateTextWithTwoPhotosPink(photos[0].image, UpText: photos[0].text, DownPhoto: photos[0].image, DownText: photos[0].text, Title: dateString, CenterText: text[i])
                            }
                        }else{
                            CurrentScrollView.contentSize.height += 245
                            if(segmenttype){
                                image.image = CreateTextOnlyBlue(dateString , CenterText: text[i])
                            }
                            else{
                                image.image = CreateTextOnlyPink(dateString , CenterText: text[i])
                            }
                        }
                        
                        if(CurrentScrollView.subviews.count > 0)
                        {
                            image.frame.origin.y = image.frame.height + y
                            y += image.frame.height
                        }
                        CurrentScrollView.addSubview(image)
                        selectedImages.append(image.image!)
                        //y += 10
                    }
                }else{
                    let text = create_text(AllExportNotes[i].notes, notifi: AllExportNotes[i].notifi, type: 0)
                    for var i = 0; i < text.count; i += 1{
                        let image = UIImageView(frame: CGRect(x: 0, y: 0 , width: 350, height: 245))
                        if(segmenttype){
                            image.image = CreateTextOnlyBlue(dateString , CenterText: text[i])
                        }
                        else{
                            image.image = CreateTextOnlyPink(dateString , CenterText: text[i])
                        }
                        if i > 0{
                            CurrentScrollView.contentSize.height += 245
                        }
                        
                        if(CurrentScrollView.subviews.count > 0)
                        {
                            image.frame.origin.y = image.frame.height + y
                            y += image.frame.height
                        }
                        CurrentScrollView.addSubview(image)
                        selectedImages.append(image.image!)
                        //y += 10
                    }
                    
                }
            }else if(AllExportNotes[i].photos.isEmpty && !AllExportNotes[i].notes.isEmpty || !AllExportNotes[i].notifi.isEmpty){
                print("3")
                let text = create_text(AllExportNotes[i].notes, notifi: AllExportNotes[i].notifi, type: 0)
                for var i = 0; i < text.count; i += 1{
                    let image = UIImageView(frame: CGRect(x: 0, y: 0 , width: 350, height: 245))
                    if(segmenttype){
                        image.image = CreateTextOnlyBlue(dateString , CenterText: text[i])
                    }
                    else{
                        image.image = CreateTextOnlyPink(dateString , CenterText: text[i])
                    }
                    if i > 0{
                        CurrentScrollView.contentSize.height += 245
                    }
                    if(CurrentScrollView.subviews.count > 0)
                    {
                        image.frame.origin.y = image.frame.height + y
                        y += image.frame.height
                    }
                    CurrentScrollView.addSubview(image)
                    selectedImages.append(image.image!)
                    //y += 10
                }
            }else {
                CurrentScrollView.contentSize = CGSizeMake(350 , CurrentScrollView.contentSize.height -  245)
            }
            PDF = toPDF(CurrentScrollView.subviews)!
        }
    }
    
    func create_text(notes: [TextNoteE], notifi: [TextNoteE], type: Int)-> [NSMutableAttributedString]{
        var count = 0
        var returnedText = [NSMutableAttributedString]()
        var attrText = NSMutableAttributedString()
        var attrTextnotifi = NSMutableAttributedString()
        
        var mas = [Int]()
        for(var n = 0 ; n < notes.count ; n++)
        {
            
            var characters = 0
            if (notes[n].typeS == "Посещения врачей" && !mas.contains(0)) || (notes[n].typeS == "Принимаемые лекарства" && !mas.contains(1)) || (notes[n].typeS == "Моё меню на сегодня" && !mas.contains(2)){
                characters += notes[n].typeS.characters.count + 2
                count += 1
                if n > 0{
                    count += 1
                }
            }else{
                characters += 5
            }
            
            if notes[n].typeS != "Посещения врачей" && notes[n].typeS != "Принимаемые лекарства" && notes[n].typeS != "Моё меню на сегодня"{
                characters += notes[n].typeS.characters.count
                if n > 0{
                    count += 1
                }
            }
            
            characters += notes[n].text.characters.count
            switch type {
            case 0:
                count += Int(lroundf(Float(Float(characters)/85)))
            case 1:
                count += characters/60
            case 2:
                count += characters/143
            case 3:
                count += Int(lroundf(Float(Float(characters)/70)))
            default:
                break
            }
            
            
            
            if count > 17{
                print("append")
                attrText.addAttributes([NSForegroundColorAttributeName: BiruzaColor1], range: NSRange(location: 0,length: attrText.length))
                returnedText.append(attrText)
                attrText.deleteCharactersInRange(NSRange(location: 0,length: attrText.length))
                count = 0
            }
            
            if notes[n].typeS == "Посещения врачей" && !mas.contains(0){
                mas.append(0)
                if n > 0{
                    attrText.appendAttributedString(NSMutableAttributedString(string: "\n"))
                }
                
                var tmp = NSMutableAttributedString(string: notes[n].typeS)
                tmp.addAttributes([NSFontAttributeName : UIFont.boldSystemFontOfSize(13)], range: NSRange(location: 0,length: tmp.length))
                attrText.appendAttributedString(tmp)
                attrText.appendAttributedString(NSMutableAttributedString(string: ":\n"))
            }
            if notes[n].typeS == "Принимаемые лекарства" && !mas.contains(1){
                mas.append(1)
                if n > 0{
                    attrText.appendAttributedString(NSMutableAttributedString(string: "\n"))
                }
                var tmp = NSMutableAttributedString(string: notes[n].typeS)
                tmp.addAttributes([NSFontAttributeName : UIFont.boldSystemFontOfSize(13)], range: NSRange(location: 0,length: tmp.length))
                attrText.appendAttributedString(tmp)
                attrText.appendAttributedString(NSMutableAttributedString(string: ":\n"))
            }
            if notes[n].typeS == "Моё меню на сегодня" && !mas.contains(2){
                mas.append(2)
                if n > 0{
                    attrText.appendAttributedString(NSMutableAttributedString(string: "\n"))
                }
                var tmp = NSMutableAttributedString(string: notes[n].typeS)
                tmp.addAttributes([NSFontAttributeName : UIFont.boldSystemFontOfSize(13)], range: NSRange(location: 0,length: tmp.length))
                attrText.appendAttributedString(tmp)
                attrText.appendAttributedString(NSMutableAttributedString(string: ":\n"))
            }
            
            if notes[n].typeS != "Посещения врачей" && notes[n].typeS != "Принимаемые лекарства" && notes[n].typeS != "Моё меню на сегодня"{
                if n > 0{
                    attrText.appendAttributedString(NSMutableAttributedString(string: "\n"))
                }
                var tmp = NSMutableAttributedString(string: notes[n].typeS)
                tmp.addAttributes([NSFontAttributeName : UIFont.boldSystemFontOfSize(13)], range: NSRange(location: 0,length: tmp.length))
                attrText.appendAttributedString(tmp)
                attrText.appendAttributedString(NSMutableAttributedString(string: ": "))
            }else{
                attrText.appendAttributedString(NSMutableAttributedString(string: "\t- "))
            }
            var tmp = NSMutableAttributedString(string: notes[n].text)
            attrText.appendAttributedString(tmp)
            attrText.appendAttributedString(NSMutableAttributedString(string: "\n"))
        }
        
        for(var n = 0 ; n < notifi.count ; n++)
        {
            count += 2
            if attrText.length > 0{
                count += 1
            }
            var characters = 0
            characters += notifi[n].typeS.characters.count + 2
            characters += notifi[n].text.characters.count
            switch type {
            case 0:
                count += Int(lroundf(Float(Float(characters)/85)))
            case 1:
                count += characters/60
            case 2:
                count += characters/143
            case 3:
                count += Int(lroundf(Float(Float(characters)/70)))
            default:
                break
            }
            
            if count > 17{
                print("append")
                var centertext = NSMutableAttributedString()
                attrText.addAttributes([NSForegroundColorAttributeName: BiruzaColor1], range: NSRange(location: 0,length: attrText.length))
                attrTextnotifi.addAttributes([NSForegroundColorAttributeName: BiruzaColor1], range: NSRange(location: 0,length: attrTextnotifi.length))
                centertext.appendAttributedString(attrText)
                if attrTextnotifi.length > 0{
                    if centertext.length > 0{
                        centertext.appendAttributedString(NSMutableAttributedString(string: "\n"))
                    }
                    let uved = NSMutableAttributedString(string: "Уведомления\n\n", attributes: [NSForegroundColorAttributeName: BiruzaColor1])
                    uved.addAttributes([NSFontAttributeName : UIFont.boldSystemFontOfSize(13)], range: NSRange(location: 0,length: uved.length))
                    centertext.appendAttributedString(uved)
                }
                centertext.appendAttributedString(attrTextnotifi)
                
                returnedText.append(centertext)
                
                attrTextnotifi.deleteCharactersInRange(NSRange(location: 0,length: attrTextnotifi.length))
                attrText.deleteCharactersInRange(NSRange(location: 0,length: attrText.length))
                count = 0
            }
            
            var tmp = NSMutableAttributedString(string: notifi[n].typeS)
            tmp.addAttributes([NSFontAttributeName : UIFont.boldSystemFontOfSize(13)], range: NSRange(location: 0,length: tmp.length))
            attrTextnotifi.appendAttributedString(tmp)
            attrTextnotifi.appendAttributedString(NSMutableAttributedString(string: ": "))
            tmp = NSMutableAttributedString(string: notifi[n].text)
            attrTextnotifi.appendAttributedString(tmp)
            attrTextnotifi.appendAttributedString(NSMutableAttributedString(string: "\n\n"))
        }
        
        
        var centertext = NSMutableAttributedString()
        if attrText.length > 0 || attrTextnotifi.length > 0{
            attrText.addAttributes([NSForegroundColorAttributeName: BiruzaColor1], range: NSRange(location: 0,length: attrText.length))
            attrTextnotifi.addAttributes([NSForegroundColorAttributeName: BiruzaColor1], range: NSRange(location: 0,length: attrTextnotifi.length))
            centertext.appendAttributedString(attrText)
            if attrTextnotifi.length > 0{
                if notifi.count > 0{
                    if centertext.length > 0{
                        centertext.appendAttributedString(NSMutableAttributedString(string: "\n"))
                    }
                    let uved = NSMutableAttributedString(string: "Уведомления\n\n", attributes: [NSForegroundColorAttributeName: BiruzaColor1])
                    uved.addAttributes([NSFontAttributeName : UIFont.boldSystemFontOfSize(13)], range: NSRange(location: 0,length: uved.length))
                    centertext.appendAttributedString(uved)
                }
                centertext.appendAttributedString(attrTextnotifi)
            }
            returnedText.append(centertext)
        }
        
        return returnedText
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
