//
//  ShareViewController.swift
//  rodicalc
//
//  Created by deck on 04.04.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit

import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

import SwiftyVK
import Social

import MessageUI

var sharingExportVk = false
var userID = ""
class ShareViewController: UIViewController ,VKDelegate, MFMailComposeViewControllerDelegate {

    @IBAction func SaveToGallery(sender: UIButton) {
        
        for (var i = 0 ; i < selectedImages.count ; i++){
            CustomPhotoAlbum.sharedInstance.saveImage(selectedImages[i])
        }
        
        let   alert =  UIAlertController(title: "Внимание", message: "Экспортируемые фотографии сохранены в память вашего устройства", preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Закрыть", style: .Default, handler: { (_) in alert.dismissViewControllerAnimated(true, completion: nil)  } )
        alert.addAction(ok)
    self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func vkAutorizationFailed(error: VK.Error) {
        print("Autorization failed with error: \n\(error)")
    }
    
    func vkWillAutorize() -> [VK.Scope] {
        let scope = [VK.Scope.messages,.offline,.friends,.wall,.photos,.audio,.video,.docs,.market,.email]
        
        return  scope
    }
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func vkDidAutorize(parameters: Dictionary<String, String>) {
      userID =  parameters["user_id"]! as String
    }

    func vkDidUnautorize() {
        
    }
    
    func vkTokenPath() -> (useUserDefaults: Bool, alternativePath: String) {
        return (true, "")
    }
    
    func vkWillPresentView() -> UIViewController {
     
        return self
    }

    
    
    func Vk_sharing(){
        
        print(selectedImages.count)
        
        print(PDF.length)
        
        if(sharingExportVk){
            VK.API.Upload.document(Media(documentData: PDF, type: "pdf")).send(method: HTTPMethods.POST , success:{response in print(response)
                let name = response.arrayObject![0] as! NSDictionary
                
                let string = "doc" + userID + "_" + String(name.valueForKey("id")!)
                print(string)
                let mass = [VK.Arg.userId : userID , VK.Arg.friendsOnly : "0" , VK.Arg.message : "Testing FEST share " , VK.Arg.attachments : string ]
                
                let req = VK.API.Wall.post(mass).send(method: HTTPMethods.GET , success: {response in print(response)}, error: {error in print(error)})
                
                },error: { error in print(error)})
            
        }
        else {
            
            selectedImages = selectedImages.reverse()
            var string = ""
            var result = 0
            dispatch_sync(dispatch_get_main_queue(),
                          {
                            for(var i=0;i<selectedImages.count;i++){
                                
                                let media = Media(imageData: UIImagePNGRepresentation(selectedImages[i])!, type: .PNG )
                                
                                print(media)
                                
                                VK.API.Upload.Photo.toWall.toUser(media, userId: userID).send(method: HTTPMethods.GET , success: {response in print(response)
                                    
                                    
                                    let name = response.arrayObject![0] as! NSDictionary
                                    
                                    if(string.characters.count > 0)
                                    {
                                        string.appendContentsOf(",")
                                    }
                                    string.appendContentsOf("photo" + userID + "_" + String(name.valueForKey("id")!))
                                    
                                    print(string)
                                    result += 1
                                    }, error: {error in print(error)  ; result += 1})
                            }
                            
            })
            
            while (result != selectedImages.count)
            {
            }
            
            let mass = [VK.Arg.userId : userID , VK.Arg.friendsOnly : "0" , VK.Arg.message : "Testing FEST share " , VK.Arg.attachments : string ]
            
            let req = VK.API.Wall.post(mass).send(method: HTTPMethods.GET , success: {response in print(response)}, error: {error in print(error)})
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = CustomPhotoAlbum.sharedInstance
        VK.start(appID: "5437729", delegate: self)
        
    //view.opaque = false
        // Do any additional setup after loading the view.
    }


    
    @IBAction func Cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func ShareMail(sender: AnyObject) {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self;

                for (var i = 0 ; i < selectedImages.count ; i++){
                mailComposerVC.addAttachmentData(UIImagePNGRepresentation(selectedImages[i])!, mimeType: "image/png", fileName: "\(i)")

            }
        
        
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposerVC, animated: true, completion: nil)
        } else {
            
        }
        
        print("шарю на мыло")
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        switch result {
    
            
        case MFMailComposeResultCancelled:
            print("Cancelled mail")
            self.dismissViewControllerAnimated(true, completion: nil)
            break
        case MFMailComposeResultSent:
            print("Message sent")
            self.dismissViewControllerAnimated(true, completion: nil)
            break
        default:
            break
        }
        
        
        
    }
    
    @IBAction func ShareVK(sender: AnyObject) {
        
            print("шарю во вконтактик")

        VK.autorize()
      
        Vk_sharing()
        

    }
    
    @IBAction func ShareOK(sender: AnyObject) {
        
        if(sharingExportVk){
            for (var i = 0 ; i < selectedImages.count ; i++){
                CustomPhotoAlbum.sharedInstance.saveImage(selectedImages[i])
            }
            
            let   alert =  UIAlertController(title: "Внимание", message: "Экспортируемые фотографии сохранены в фотоальбом. Для того что бы разместить фотографии перейдите в приложение Одноклассники", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "Закрыть", style: .Default, handler: { (_) in alert.dismissViewControllerAnimated(true, completion: nil)  } )
            alert.addAction(ok)
            let open = UIAlertAction(title: "Перейти", style: .Default, handler: { (_) in
                
                if (UIApplication.sharedApplication().canOpenURL(NSURL(string: "https://ok.ru")!)){
                    UIApplication.sharedApplication().openURL(NSURL(string: "https://ok.ru")!)
                }
                else {
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }
            } )
            alert.addAction(open)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else{
            
        let settings  = OKSDKInitSettings.init()
        settings.appKey = "CBAFLEFLEBABABABA"
        settings.appId = "1246999552"
        settings.controllerHandler = {
            return self;
        }
        
        OKSDK.initWithSettings(settings)


        
        OKSDK.authorizeWithPermissions(["VALUABLE_ACCESS","LONG_ACCESS_TOKEN","PHOTO_CONTENT"], success: {id in print(id)
            
          //  OKSDK.invokeMethod("users.getCurrentUser", arguments: [:], success: {data in print(data)}, error: {error in print(error)})
            
            
            for(var i = 0 ; i<selectedImages.count; i++){
              let imageData = UIImagePNGRepresentation(selectedImages[i])
            
        OKSDK.invokeMethod("photosV2.getUploadUrl", arguments: [:], success: {
            data in print(data)
        
         let photoId = (data["photo_ids"]as! NSArray)[0] as! String
         let boundary = "0xKhTmLbOuNdArY"
         let kNewLine = "\r\n"
         let urlPath = data["upload_url"] as! String
         let url: NSURL = NSURL(string: urlPath)!
         let request1: NSMutableURLRequest = NSMutableURLRequest(URL: url)
          let data = NSMutableData()
            
            request1.HTTPMethod = "POST"
            request1.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            data.appendData("--\(boundary)\(kNewLine)".dataUsingEncoding(NSUTF8StringEncoding)!)
            data.appendData("Content-Disposition: form-data; name=\"0.png\"; filename=\"0.png\"\(kNewLine)".dataUsingEncoding(NSUTF8StringEncoding)!)
            data.appendData("Content-Type: image/png".dataUsingEncoding(NSUTF8StringEncoding)!)
            data.appendData("\(kNewLine)\(kNewLine)".dataUsingEncoding(NSUTF8StringEncoding)!)
            data.appendData(imageData!)
            data.appendData("\(kNewLine)".dataUsingEncoding(NSUTF8StringEncoding)!)
            data.appendData("--\(boundary)--".dataUsingEncoding(NSUTF8StringEncoding)!)
            request1.HTTPBody=data
            request1.timeoutInterval = 60
            request1.HTTPShouldHandleCookies=false
               let queue:NSOperationQueue = NSOperationQueue()
            
            NSURLConnection.sendAsynchronousRequest(request1, queue: queue, completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                
                do {
                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                        print("ASynchronous\(jsonResult)")
                        
                        let token = jsonResult.valueForKeyPath("photos.\(photoId).token") // ["photos"][photoId]["token"]

                        OKSDK.invokeMethod("photosV2.commit", arguments: ["photo_id":photoId,"token":token!,"comment":"Example Anon"], success:{ data in print(data)}, error: {error in print(error)})
                        
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                
            })
            
      
            }
            , error: {error in print(error)})
            }
        
            }, error: {error in print(error)
        })
        OKSDK.clearAuth()
    
        }
    }
    
    @IBAction func ShareFB(sender: AnyObject) {
        print("шарю в фсб")
        

            if(sharingExportVk){
        for (var i = 0 ; i < selectedImages.count ; i++){
            CustomPhotoAlbum.sharedInstance.saveImage(selectedImages[i])
        }
    
        let   alert =  UIAlertController(title: "Внимание", message: "Экспортируемые фотографии сохранены в фотоальбом. Для того что бы разместить фотографии перейдите в приложение facebook", preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Закрыть", style: .Default, handler: { (_) in alert.dismissViewControllerAnimated(true, completion: nil)  } )
        alert.addAction(ok)
        let open = UIAlertAction(title: "Перейти", style: .Default, handler: { (_) in
            
            if (UIApplication.sharedApplication().canOpenURL(NSURL(string: "fb://profile/PageId")!)){
                UIApplication.sharedApplication().openURL(NSURL(string: "fb://profile/PageId")!)
            }
            else {
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
             } )
        alert.addAction(open)
        
        self.presentViewController(alert, animated: true, completion: nil)
            }
            else{
        

                
                 if (UIApplication.sharedApplication().canOpenURL(NSURL(string: "fb://profile/PageId")!)){
                    let dialog = FBSDKShareDialog()
                    dialog.fromViewController = self
                    dialog.mode = FBSDKShareDialogMode.Native
                    let content = FBSDKSharePhotoContent()
                    content.photos = selectedImages
                    dialog.shareContent = content
                    dialog.show()
                }
                 else{
                
                    let shareToFacebook : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
 
                  shareToFacebook.setInitialText("")
                for (var i = 0 ; i < selectedImages.count ; i++){
                      shareToFacebook.addImage(selectedImages[i])
                }
                self.presentViewController(shareToFacebook, animated: true, completion: nil)
            
                }
        }
     
        
        // если использовать апи )) для верисии ios 7
        

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
