//
//  NameViewController.swift
//  PregnancyCalendar
//
//  Created by farestz on 25.02.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit

class NameViewController: UIViewController {
    var name: String!
    var desc: String!
    
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = self.name
        self.fillTheInformation()
    }

    private func fillTheInformation() {
        self.textView.text = self.desc
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}