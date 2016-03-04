//
//  WebViewController.swift
//  PregnancyCalendar
//
//  Created by farestz on 29.02.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    var url = ""
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Тема"
        self.webView.loadRequest(NSURLRequest(URL: NSURL(string: self.url)!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
