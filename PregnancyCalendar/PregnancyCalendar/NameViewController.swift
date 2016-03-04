//
//  NameViewController.swift
//  PregnancyCalendar
//
//  Created by farestz on 25.02.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit

class NameViewController: UIViewController {
    let namesDescription = ["Тимофей": "Имя Тимофей произошло от греческого «тимофеос», в переводе означающего «почитающий Бога». В различных европейских странах это имя будет звучать как Тимоти, Тимотиас в Англии, Тимотео - в Испании, Италии, Тимотеу - в Португалии, Тимотеос - в Греции, Тимотей - в Румынии, Тимотеуш - в Польше, в северных странах (Норвегия, Дания, Швеция) и в Германии - Тимотеус, Тимо, Тими - в Финляндии, Тимод - в Ирландии."]
    var name = ""
    
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = self.name
        self.navigationController?.navigationBar.topItem?.title = ""
        self.fillTheInformation()
    }

    private func fillTheInformation() {
        self.textView.text = self.namesDescription[self.name]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}