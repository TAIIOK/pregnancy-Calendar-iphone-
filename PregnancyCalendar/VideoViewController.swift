//
//  VideoViewController.swift
//  PregnancyCalendar
//
//  Created by farestz on 26.02.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit

class VideoViewController: UITableViewController{
   
    @IBOutlet weak var menuButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSidebarMenu()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    private func setupSidebarMenu() {
        if self.revealViewController() != nil {
            self.revealViewController().rearViewRevealDisplacement = 0
            self.revealViewController().rearViewRevealOverdraw = 0
            self.revealViewController().rearViewRevealWidth = 275
            self.revealViewController().frontViewShadowRadius = 0
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.imageView?.image = indexPath.row == 0 ? scaleImage(UIImage(named: "3.jpg")!,toSize: CGSize(width: 100,height: 100)) : scaleImage(UIImage(named: "0.png")!,toSize: CGSize(width: 100,height: 100))
        cell.textLabel?.text =  indexPath.row == 0 ? "Белье для беременных" : "Гимнастика для беременных"
        cell.detailTextLabel?.text = indexPath.row == 0 ? "25" : "5"
        return cell
    }
    
    func scaleImage(image: UIImage, toSize newSize: CGSize) -> (UIImage) {
        let newRect = CGRectIntegral(CGRectMake(0,0, newSize.width, newSize.height))
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, .High)
        let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
        CGContextConcatCTM(context, flipVertical)
        CGContextDrawImage(context, newRect, image.CGImage)
        let newImage = UIImage(CGImage: CGBitmapContextCreateImage(context)!)
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0{
            choosedVideoSegment = true
        }else{
            choosedVideoSegment = false
        }
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("VideoAlbumController") as? UINavigationController
        self.revealViewController().pushFrontViewController(controller, animated: true)
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
