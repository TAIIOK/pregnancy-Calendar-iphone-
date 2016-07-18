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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let btnBack = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = btnBack
        check()
        
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
            
        case .Online(.WWAN):
            let videoPlayer = YouTubePlayerView(frame: self.view.frame)
            videoPlayer.backgroundColor = .whiteColor()
            self.view.addSubview(videoPlayer)
            self.view.bringSubviewToFront(videoPlayer)
            let id =  choosedVideoSegment ? "\(videosDress[videoIndex])" : "\(videosGym[videoIndex])"
            videoPlayer.loadVideoID(id)
        case .Online(.WiFi):
            let videoPlayer = YouTubePlayerView(frame: self.view.frame)
            videoPlayer.backgroundColor = .whiteColor()
            self.view.addSubview(videoPlayer)
            self.view.bringSubviewToFront(videoPlayer)
            let id =  choosedVideoSegment ? "\(videosDress[videoIndex])" : "\(videosGym[videoIndex])"
            videoPlayer.loadVideoID(id)
        }
    }
    @IBAction func reconnect(sender: UIButton) {
        check()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
