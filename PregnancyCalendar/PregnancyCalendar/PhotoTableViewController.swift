//
//  PhotoTableViewController.swift
//  PregnancyCalendar
//
//  Created by farestz on 16.03.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit
import AssetsLibrary

class IAAssetsLibrary: ALAssetsLibrary {
    
    class var defaultInstance : IAAssetsLibrary {
        struct Static {
            static let instance : IAAssetsLibrary = IAAssetsLibrary()
        }
        return Static.instance
    }
    
}


class PhotoTableViewController: UITableViewController {
    
    var assetsLibraty: ALAssetsLibrary!
    var albums:[ALAssetsGroup] = []
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    func loadAlbums() {
        let library = IAAssetsLibrary.defaultInstance
        library.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: { (group, stop) -> Void in
            //            println("in enumeration")
            if (group != nil) {
                //                println("group not nil")
                //                println(group.valueForProperty(ALAssetsGroupPropertyName))
                self.albums.append(group)
            } else {
                //                println("group is nil")
                dispatch_async(dispatch_get_main_queue(), {
                    //                    println("reload data")
                    self.tableView.reloadData()
                    
                })
            }
        }) { (error) -> Void in
            print("problem loading albums: \(error)")
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSidebarMenu()
        
        if self.assetsLibraty == nil {
            self.assetsLibraty = ALAssetsLibrary()
            loadAlbums()
        }
        
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

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albums.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let groupForCell = self.albums[indexPath.row]
        print(groupForCell)
        
        let poster = UIImage(CGImage: groupForCell.posterImage().takeUnretainedValue())
        cell.imageView?.image = poster
        cell.textLabel?.text =  groupForCell.valueForProperty(ALAssetsGroupPropertyName) as! String
        cell.detailTextLabel?.text = "\(groupForCell.numberOfAssets())"
        
       
        return cell
    }

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
