//
//  VideoAlbumCollectionViewController.swift
//  PregnancyCalendar
//
//  Created by farestz on 29.03.16.
//  Copyright © 2016 farestz. All rights reserved.
//

import UIKit

enum VideoTypes {
    case Linen
    case Gym
}

private let reuseIdentifier = "Cell"

class VideoAlbumCollectionViewController: UICollectionViewController {
    
    let videosDress = ["iC5Oe_molfw",
        "2-rkmvmlZhY",
        "PpIWPXG67LE",
        "6xDPPupoErk",
        "jTYKDH9Gp8A",
        "CqbEmt5OvTw",
        "qt4Nrwi2H6s",
        "5EtmXqBcgHM",
        "r5BwTUiPHDM",
        "kfIfbrlg1Ik",
        "gkTuKuvnVvo",
        "H9u7Skai4gY",
        "PJL5TMXYSOQ",
        "fcUPgKMVWXA",
        "6HI_l9JitwE",
        "HBeBFGPJvwU",
        "D7xclqFnmrk",
        "YgsHdIhCCrQ",
        "j3wmoPJlR2A",
        "ZuBKd2D3TPg",
        "u9-klWTYBeo",
        "Da8nM8Ga1Jc",
        "TgihONK_swI",
        "dt-XaCO5mtc",
        "0F-dlfN9664"]
    
    let videosGym = ["iBzR_TNrWMI",
        "oCXnXP2R1NE",
        "evUKbaeGXB0",
        "-2jV00pq8Iw",
        "QELTjHFHqxg"]
    
    var type: VideoTypes = VideoTypes.Linen
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 75, height: 75)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        self.collectionView?.collectionViewLayout = layout
    

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(VideoCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return type == .Linen ? videosDress.count : videosGym.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! VideoCollectionViewCell
        cell.imageView.image = type == .Linen ? UIImage(named: "\(indexPath.row).jpg") : UIImage(named: "\(indexPath.row).png")
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
