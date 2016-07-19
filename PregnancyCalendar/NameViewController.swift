//
//  NameViewController.swift
//  rodicalc
//
//  Created by deck on 25.02.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit

class NameViewController: UIViewController{

    @IBOutlet weak var info: UITextView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Значение имени"
        info.scrollsToTop = true
        info.text = choosedSegmentNames ? (man[sections[choosedName.section].index + choosedName.row].name + "\n\n" + man[sections[choosedName.section].index + choosedName.row].value + "\n\n" + man[sections[choosedName.section].index + choosedName.row].about) : (woman[sectionsGirl[choosedName.section].index + choosedName.row].name + "\n\n" + woman[sectionsGirl[choosedName.section].index + choosedName.row].value + "\n\n" + woman[sectionsGirl[choosedName.section].index + choosedName.row].about)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        //info.scrollRangeToVisible(NSRange(location:0, length:0))

        dispatch_async(dispatch_get_main_queue(), {
                self.info.scrollRectToVisible(CGRectMake(0,0,1,1), animated: false)
        })
    }
}
