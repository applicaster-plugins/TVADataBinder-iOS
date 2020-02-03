//
//  ZPBabyFirstCellViewController.swift
//
//  Created by Miri Vecselboim on
//  Copyright © 2018 Applicaster Ltd. All rights reserved.
//

import Foundation
import UIKit
import ZappGeneralPluginsSDK
import ApplicasterSDK
import ComponentsSDK
import ZappPlugins



class ZPTVACellViewController : CACellViewController {
    
    var atomEntry:APAtomEntry?
    var atomFeed: APAtomFeed?
    
    override func displayAtomEntry(_ entry: NSObject) {
        if let entry = entry as? APAtomEntry {
            self.atomEntry = entry
            self.atomFeed = nil
        }
        super.displayAtomEntry(entry)
    }
    
    override func updateUI() {
        super.updateUI()
        if let atomEntry = self.atomEntry {
            self.populateEntry(with: atomEntry)
        } else if let atomFeed = self.atomFeed {
            self.populateFeed(with: atomFeed)
        }
    }
    
    override func displayAtomFeed(_ atomFeed: NSObject!) {
        if let atomFeed = atomFeed as? APAtomFeed {
            self.atomFeed = atomFeed
            self.atomEntry = nil
        }
        super.displayAtomFeed(atomFeed)
    }
    
    //populates an atomEntry with extensions' parameters
    func populateEntry(with atomEntry: APAtomEntry) {

    }
    
    func populateFeed(with atomFeed: APAtomFeed) {
        if (atomFeed.mediaGroups.count > 1){
            if let image1Dic = atomFeed.mediaGroups[1] as? APAtomMediaGroup ,let imageUrl  = image1Dic.mediaItemStringURL(forKey: "image1"),
                let url = URL(string: imageUrl){
                if let imageViewCollection = self.imageViewCollection {
                    for image in imageViewCollection {
                        if let imageView  = image as? UIImageView{
                             let placeHolder = UIImage(named:"placeholder_special_2")
                            ZAAppConnector.sharedInstance().imageDelegate?.setImage(to: imageView, url: url, placeholderImage: placeHolder)
                        }
                    }
                }
            }
        }
    }
    
    override func prepareComponentForReuse() {
        super.prepareComponentForReuse()
        self.updateUI()
    }
    
}
