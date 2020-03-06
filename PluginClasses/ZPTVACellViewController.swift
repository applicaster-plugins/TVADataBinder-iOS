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
import ZappSDK
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
        
        if let tag1 = atomFeed.extensions?["tag1"] as? String{
            if  let style = getStyle(styleName:tag1){
                for (index,label) in self.labelsCollection.enumerated(){
                    if(index == 1){
                        label.setColor(key: style.textColor, from: style.styleDic)
                        label.setBackgroundColor(key: style.backgroundColor, from: style.styleDic)
                        label.setFont(fontNameKey: style.font, fontSizeKey: style.textSize, from: style.styleDic)
                    }
                }
            }
        }
        
        if let tag0 = atomFeed.extensions?["tag0"] as? String{
            if  let style = getStyle(styleName:tag0){
                for (index,label) in self.labelsCollection.enumerated(){
                    if(index == 0){
                        label.setColor(key: style.textColor, from: style.styleDic)
                        label.setBackgroundColor(key: style.backgroundColor, from: style.styleDic)
                        label.setFont(fontNameKey: style.font, fontSizeKey: style.textSize, from: style.styleDic)
                    }
                }
            }
        }
        
        if let tag = atomFeed.extensions?["tag"] as? String{
            if  let style = getStyle(styleName:tag){
                for (index,label) in self.labelsCollection.enumerated(){
                    if(index == 0){
                        label.setColor(key: style.textColor, from: style.styleDic)
                        label.setBackgroundColor(key: style.backgroundColor, from: style.styleDic)
                        label.setFont(fontNameKey: style.font, fontSizeKey: style.textSize, from: style.styleDic)
                    }
                }
            }
        }
        
        if (atomFeed.mediaGroups.count > 1){
            if let image1Dic = atomFeed.mediaGroups[1] as? APAtomMediaGroup ,let imageUrl  = image1Dic.mediaItemStringURL(forKey: "image1"),
                let url = URL(string: imageUrl){
                if let imageViewCollection = self.imageViewCollection {
                    for (index,image) in imageViewCollection.enumerated() {
                        if let imageView  = image as? UIImageView{
                            if(index == 0){
                                let placeHolder = UIImage(named:"placeholder_special_2")
                                ZAAppConnector.sharedInstance().imageDelegate?.setImage(to: imageView, url: url, placeholderImage: placeHolder)
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func prepareComponentForReuse() {
        super.prepareComponentForReuse()
      //  self.updateUI()
    }    
}
