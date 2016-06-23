//
//  ForumTableViewController.swift
//  rodicalc
//
//  Created by deck on 25.02.16.
//  Copyright © 2016 deck. All rights reserved.
//

import UIKit
var items: [String] = ["Общие","Скидки, подарки, конкурсы","Планирование беременности","Традиционные религии России","Беременность","Поступки мужчин","Ваш возраст при беременности","Роды","После родов","Клуб МАМА-ФЭСТ","Комментарии пользователей"]

var urls: [String] = ["http://www.aist-k.com/forum/","http://www.aist-k.com/forum/?PAGE_NAME=forums&GID=2/","http://www.aist-k.com/forum/?PAGE_NAME=forums&GID=4/","http://www.aist-k.com/forum/?PAGE_NAME=forums&GID=10/","http://www.aist-k.com/forum/?PAGE_NAME=forums&GID=5/","http://www.aist-k.com/forum/?PAGE_NAME=forums&GID=9/","http://www.aist-k.com/forum/?PAGE_NAME=forums&GID=3/","http://www.aist-k.com/forum/?PAGE_NAME=forums&GID=7/","http://www.aist-k.com/forum/?PAGE_NAME=forums&GID=8/","http://www.aist-k.com/forum/?PAGE_NAME=forums&GID=6/","http://www.aist-k.com/forum/?PAGE_NAME=forums&GID=1/"]
var id=0

class ForumViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    


    @IBOutlet weak var noConnetionView: UIView!
    @IBOutlet weak var noConnetionImage: UIImageView!
    @IBOutlet weak var noConnetionLabel: UILabel!
    @IBOutlet weak var noConnectionButton: UIButton!
    
    @IBOutlet weak var table: UITableView!

 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noConnetionView.backgroundColor = .clearColor()
        table.backgroundColor = .clearColor()
        self.setupSidebarMenu()
        let img  = UIImage(named: "menu")
        let btn = UIBarButtonItem(image: img , style: UIBarButtonItemStyle.Bordered, target: self.revealViewController(), action: "revealToggle:")
        self.navigationItem.leftBarButtonItem = btn

        let status = Reach().connectionStatus()
        switch status {
        case .Unknown, .Offline:
            print("Not connected")
            noConnetionImage.hidden = false
            noConnetionLabel.hidden = false
            noConnectionButton.hidden = false
            noConnetionView.hidden = false
            noConnectionButton.enabled = true
            
        case .Online(.WWAN):
            self.table.registerClass(UITableViewCell.self, forCellReuseIdentifier: "ForumCell")
            table.delegate = self
            table.dataSource = self
            table.hidden = false
        case .Online(.WiFi):
            self.table.registerClass(UITableViewCell.self, forCellReuseIdentifier: "ForumCell")
            table.delegate = self
            table.dataSource = self
            table.hidden = false
        }
    
    }
    
    private func setupSidebarMenu() {
        if self.revealViewController() != nil {
            self.revealViewController().rearViewRevealDisplacement = 0
            self.revealViewController().rearViewRevealOverdraw = 0
            self.revealViewController().rearViewRevealWidth = 275
            self.revealViewController().frontViewShadowRadius = 0
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ForumCell", forIndexPath: indexPath)
        cell.textLabel?.text=items[indexPath.row]
        cell.textLabel?.textColor = StrawBerryColor
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.backgroundColor = .clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //let websViewController = self.storyboard?.instantiateViewControllerWithIdentifier("WebsViewController") as? WebsViewController
        //self.navigationController?.pushViewController(websViewController!, animated: true)
        if let url = NSURL(string: urls[indexPath.row]){
            UIApplication.sharedApplication().openURL(url)
        }
        id=indexPath.row
    }

}
