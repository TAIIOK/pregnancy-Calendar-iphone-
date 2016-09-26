//
//  VideoPlayerViewController.swift
//  rodicalc
//
//  Created by deck on 28.04.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit

class VideoPlayerViewController: UIViewController {
    
    @IBOutlet weak var noConnectionImage: UIImageView!
    @IBOutlet weak var noConnectionButton: UIButton!
    @IBOutlet weak var noConnectionLabel: UILabel!
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var background: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                let btnBack = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = btnBack
        noConnectionButton.layer.borderWidth = 2
        noConnectionButton.layer.borderColor = StrawBerryColor.CGColor
        noConnectionButton.layer.cornerRadius = 5
        noConnectionLabel.textColor = UIColor.grayColor()
        //check()
        
        // Do any additional setup after loading the view.
    }
    @IBAction func back(sender: UIBarButtonItem) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("VideoAlbumController") as? UINavigationController
        self.revealViewController().pushFrontViewController(controller, animated: true)
    }
    
    func check(){
        let status = Reach().connectionStatus()
        switch status {
        case .Unknown, .Offline:
            print("Not connected")
            noConnectionImage.hidden = false
            noConnectionLabel.hidden = false
            noConnectionButton.hidden = false
            noConnectionView.hidden = false
            noConnectionButton.enabled = true
            background.image = UIImage(named: "no_connection_background.png")
        case .Online(.WWAN):
            var frame = self.view.frame
            frame.origin.y -= 32
            let videoPlayer = YouTubePlayerView(frame: frame)
            videoPlayer.backgroundColor = .whiteColor()
            self.view.addSubview(videoPlayer)
            self.view.bringSubviewToFront(videoPlayer)
            let id =  choosedVideoSegment ? "\(videosDress[videoIndex])" : "\(videosGym[videoIndex])"
            videoPlayer.loadVideoID(id)
            background.image = UIImage(named: "background.png")
        case .Online(.WiFi):
            var frame = self.view.frame
            frame.origin.y -= 32
            let videoPlayer = YouTubePlayerView(frame: frame)
            videoPlayer.backgroundColor = .whiteColor()
            self.view.addSubview(videoPlayer)
            self.view.bringSubviewToFront(videoPlayer)
            let id =  choosedVideoSegment ? "\(videosDress[videoIndex])" : "\(videosGym[videoIndex])"
            videoPlayer.loadVideoID(id)
            background.image = UIImage(named: "background.png")
        }
    }
    @IBAction func reconnect(sender: UIButton) {
        check()
    }
    
    override func viewWillAppear(animated: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.shouldRotate = true // or false to disable rotation
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        check()
    }
    
    override func viewWillDisappear(animated: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.shouldRotate = false // or false to disable rotation
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
