//
//  export.swift
//  rodicalc
//
//  Created by Roman Efimov on 26.04.16.
//  Copyright © 2016 deck. All rights reserved.
//

import Foundation
import UIKit


class PhotoTemp: UIView {

    @IBOutlet weak var CenterImageView: UIImageView!
    
    @IBOutlet weak var Title: UILabel!
    func setContent(Photo: UIImage, title: String)
    {
    CenterImageView.image = Photo
    Title.text = title
        
    }

}



class PhotoTemplate:UIView{
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
    }
    
    
    func xibSetup(Photo: UIImage, title: String) {
        let view1 = loadViewFromNib("PhotoTemplate") as! PhotoTemp
        
        view1.setContent(Photo,title: title )
        
        frameSetup(view1)
        
    }
    
  
    func frameSetup(view : UIView)
    {
        view.frame = CGRectMake(0 , 0, self.frame.width, self.frame.height)
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
        
    }
    
    func loadViewFromNib(nibString : String) -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: nibString, bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
}



class TwoPhotoBlue: UIView{
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    func setContent(left: UIImage,right: UIImage, title: String,leftText : String, rightText: String){
        rotateViews()
        
        let LeftView = PhotoTemplate(frame: CGRect(x: leftImage.frame.origin.x, y: leftImage.frame.origin.y, width: 600, height: 700))
        LeftView.xibSetup(left,title: leftText)
        leftImage.image = LeftView.screenshot
        if(left != right)
        {
        let RightView = PhotoTemplate(frame: CGRect(x: leftImage.frame.origin.x, y: leftImage.frame.origin.y, width: 600, height: 700))
        RightView.xibSetup(right,title: rightText)
        rightImage.image = RightView.screenshot
        }
        titleLabel.text = title

    }
    
    func rotateViews(){
        leftImage.rotate(degrees: -12)
        rightImage.rotate(degrees: 6)
    }
    
}

class TextWithTwoPhotoBlue: UIView{
    
    @IBOutlet weak var UpPhotoView: UIImageView!
    @IBOutlet weak var DownPhotoView: UIImageView!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var CenterTextView: UITextView!
    
    func setContent(UpPhoto:UIImage,UpText :String, DownPhoto : UIImage,DownText : String, Title: String,CenterText :String ){
        
        rotateViews()
        if(UpPhoto != DownPhoto){
        let PhotoUPView = PhotoTemplate(frame: CGRect(x: UpPhotoView.frame.origin.x, y: UpPhotoView.frame.origin.y, width: 600, height: 700))
        PhotoUPView.xibSetup(UpPhoto,title: UpText)
        UpPhotoView.image = PhotoUPView.screenshot
        }
        let PhotoDownView = PhotoTemplate(frame: CGRect(x: DownPhotoView.frame.origin.x, y: DownPhotoView.frame.origin.y, width: 600, height: 700))
        
        PhotoDownView.xibSetup(DownPhoto,title: DownText)
        DownPhotoView.image = PhotoDownView.screenshot
        
        TitleLabel.text = Title
        CenterTextView.text = CenterText

    }
    
    func rotateViews(){
        UpPhotoView.rotate(degrees: -11)
        DownPhotoView.rotate(degrees: 7)
    }

}


class TextOnlyBlue: UIView{
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var CenterTextView: UITextView!
    func setContent(Title : String, CenterText: String){
        TitleLabel.text = Title
        CenterTextView.text = CenterText
    }
    
}

class TwoPhotoPink: UIView{
 
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var leftImage: UIImageView!

    func setContent(left: UIImage,right: UIImage, title: String,leftText : String, rightText: String){
        rotateViews()
        
        let LeftView = PhotoTemplate(frame: CGRect(x: leftImage.frame.origin.x, y: leftImage.frame.origin.y, width: 600, height: 700))
        LeftView.xibSetup(left,title: leftText)
        leftImage.image = LeftView.screenshot
        if(left != right){
        let RightView = PhotoTemplate(frame: CGRect(x: leftImage.frame.origin.x, y: leftImage.frame.origin.y, width: 600, height: 700))
        RightView.xibSetup(right,title: rightText)
        rightImage.image = RightView.screenshot
        }
        
        titleLabel.text = title

    }
    
    func rotateViews(){
        leftImage.rotate(degrees: -21)
        rightImage.rotate(degrees: 13)
    }
    
}

class TextWithTwoPhotoPink: UIView{
    
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var CenterTextView: UITextView!
    @IBOutlet weak var UpPhotoView: UIImageView!
    @IBOutlet weak var DownPhotoView: UIImageView!
    
    func setContent(UpPhoto:UIImage,UpText :String, DownPhoto : UIImage,DownText : String, Title: String,CenterText :String ){
        
        rotateViews()
        
        if(UpPhoto != DownPhoto){
        let PhotoUPView = PhotoTemplate(frame: CGRect(x: UpPhotoView.frame.origin.x, y: UpPhotoView.frame.origin.y, width: 600, height: 700))
        PhotoUPView.xibSetup(UpPhoto,title: UpText)
        UpPhotoView.image = PhotoUPView.screenshot
        }
        let PhotoDownView = PhotoTemplate(frame: CGRect(x: DownPhotoView.frame.origin.x, y: DownPhotoView.frame.origin.y, width: 600, height: 700))
        
        PhotoDownView.xibSetup(DownPhoto,title: DownText)
        DownPhotoView.image = PhotoDownView.screenshot
        
    
        TitleLabel.text = Title
        CenterTextView.text = CenterText
        
    }
    
    func rotateViews(){
        UpPhotoView.rotate(degrees: -15)
        DownPhotoView.rotate(degrees: 12)
    }
    
}


class TextOnlyPink: UIView{
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var CenterTextView: UITextView!
    
    func setContent(Title : String, CenterText: String){
        TitleLabel.text = Title
        CenterTextView.text = CenterText
    }
    
}

class photo: UIView{
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)

    }
    
    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        
    }
            
        
        func xibFirstSetupBlue(left: UIImage,right: UIImage, title: String,leftText : String, rightText: String) {
           let view1 = loadViewFromNib("TwoPhotoBlue") as! TwoPhotoBlue
            

                    
            view1.setContent(left, right: right, title: title, leftText: leftText, rightText: rightText)
            
            frameSetup(view1)

        }
    
    func xibSecondSetupBlue(UpPhoto:UIImage,UpText :String, DownPhoto : UIImage,DownText : String, Title: String,CenterText :String) {
        let view1 = loadViewFromNib("TextWithTwoPhotosBlue") as! TextWithTwoPhotoBlue
        
        view1.setContent(UpPhoto, UpText: UpText, DownPhoto: DownPhoto, DownText: DownText, Title: Title, CenterText: CenterText)
        
        frameSetup(view1)
        
    }
    
    func xibThirdSetupBlue(Title : String, CenterText: String) {
        let view1 = loadViewFromNib("TextOnlyBlue") as! TextOnlyBlue
        
        view1.setContent(Title, CenterText: CenterText)
        
        frameSetup(view1)
        
    }
    
    func xibFirstSetupPink(left: UIImage,right: UIImage, title: String,leftText : String, rightText: String) {
        let view1 = loadViewFromNib("TwoPhotosPink") as! TwoPhotoPink
        
        view1.setContent(left, right: right, title: title, leftText: leftText, rightText: rightText)
        
        frameSetup(view1)
        
    }
    
    func xibSecondSetupPink(UpPhoto:UIImage,UpText :String, DownPhoto : UIImage,DownText : String, Title: String,CenterText :String) {
        let view1 = loadViewFromNib("TextWithTwoPhotosPink") as! TextWithTwoPhotoPink
        
        view1.setContent(UpPhoto, UpText: UpText, DownPhoto: DownPhoto, DownText: DownText, Title: Title, CenterText: CenterText)
        
        frameSetup(view1)
        
    }
    
    func xibThirdSetupPink(Title : String, CenterText: String) {
        let view1 = loadViewFromNib("TextOnlyPink") as! TextOnlyPink
        
        view1.setContent(Title, CenterText: CenterText)
        
        frameSetup(view1)
        
    }
    
    func frameSetup(view : UIView)
    {
        view.frame = CGRectMake(0 , 0, self.frame.width, self.frame.height)
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)

    }

    func loadViewFromNib(nibString : String) -> UIView {
            let bundle = NSBundle(forClass: self.dynamicType)
            let nib = UINib(nibName: nibString, bundle: bundle)
            
            // Assumes UIView is top level and only object in CustomView.xib file
            let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
            return view
        }
        
    
}
