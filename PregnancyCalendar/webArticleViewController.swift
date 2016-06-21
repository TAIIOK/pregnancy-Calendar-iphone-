//
//  webArticleViewController.swift
//  rodicalc
//
//  Created by Roman Efimov on 28.04.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit

class webArticleViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var myWebView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        myWebView.delegate = self
        var localfilePath : NSURL
        
        if(articletype == 0)
        {
         localfilePath = NSBundle.mainBundle().URLForResource("bondage", withExtension: "html")!
        }
        else {
         localfilePath = NSBundle.mainBundle().URLForResource("bra", withExtension: "html")!
        }
        let myRequest = NSURLRequest(URL: localfilePath);
        myWebView.loadRequest(myRequest);
        
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        switch navigationType {
        case .LinkClicked:
            // Open links in Safari
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        default:
            // Handle other navigation types...
            return true
        }
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
