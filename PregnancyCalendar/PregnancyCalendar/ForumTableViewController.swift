//
//  ForumTableViewController.swift
//  PregnancyCalendar
//
//  Created by farestz on 26.02.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit

class ForumTableViewController: UITableViewController {
    let themes = ["Общие", "Скидки, подарки, конкурсы", "Планирование беременности", "Традиционные религии России", "Беременность", "Поступки мужчин", "Ваш возраст при беременности", "Роды", "После родов", "Клуб МАМА-ФЭСТ", "Комментарии пользователей"]
    let links = ["http://www.aist-k.com/forum/", "http://www.aist-k.com/forum/group2/", "http://www.aist-k.com/forum/group4/", "http://www.aist-k.com/forum/group10/", "http://www.aist-k.com/forum/group5/", "http://www.aist-k.com/forum/group9/", "http://www.aist-k.com/forum/group3/", "http://www.aist-k.com/forum/group7/", "http://www.aist-k.com/forum/group8/", "http://www.aist-k.com/forum/group6/", "http://www.aist-k.com/forum/group1/"]
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSidebarMenu()
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
    
    private func getCustomieBackgroundView() -> UIView {
        let backgroundView = UIView()
        backgroundView.backgroundColor = StrawBerryColor
        return backgroundView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.themes.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as? WebViewController
        controller?.url = self.links[indexPath.row]
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("forumCell", forIndexPath: indexPath)
        cell.textLabel?.text = self.themes[indexPath.row]
        cell.textLabel?.textColor = StrawBerryColor
        cell.textLabel?.highlightedTextColor = .whiteColor()
        cell.selectedBackgroundView = getCustomieBackgroundView()
        return cell
    }
}
