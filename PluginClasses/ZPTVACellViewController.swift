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
    let layoutArray = ["Family_5_horizontal_list_13", "Family_5_grid_11", "Family_5_grid_12" ]
    
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
        setTags(with: atomFeed)
        getFavorites(with: atomFeed)
        setFavoritesActionTapped()
    }
    
    private func setTags(with atomFeed: APAtomFeed){
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
                        if label.isHidden, label.text == nil {
                            label.text = tag0
                            label.isHidden = false
                        }
                        
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
    
    private func isFavoriteSupported() -> UIButton?{
        guard let layout = self.currentComponentModel()?.style["layout_name"] as? String,
            let favoriteBtn  = favoritesButton,
            layoutArray.contains(layout)  else{
            return nil
        }
        return favoriteBtn
    }

    private func getFavorites(with atomFeed: APAtomFeed){
        guard let favoriteBtn = isFavoriteSupported() else{
            return
        }
        favoriteBtn.isHidden = false;
        getFavouriteState(uid: atomFeed.identifier) { (on) in
            if let state = on{
                if(state){
                    favoriteBtn.isSelected = true
                }else{
                    favoriteBtn.isSelected = false
                }
            }
        }
    }
    
    private func setFavoritesActionTapped(){
        guard let favoriteBtn = isFavoriteSupported() else{
            return
        }
        favoriteBtn.removeTarget(self, action: #selector(favBtnTapped), for: .touchUpInside)
        favoriteBtn.addTarget(self, action:  #selector(favBtnTapped), for: .touchUpInside)
    }
    
    @objc func favBtnTapped(sender: UIButton!) {
        guard let atomFeed = atomFeed else {
            return
        }
        if(sender.isSelected){
            deleteFavoriteState(uid: atomFeed.identifier) { (success) in
                if(success){
                    DispatchQueue.onMain {
                        sender.isSelected = false
                    }
                }
            }
        }
        else{
            setFavoriteState(uid: atomFeed.identifier) { (success) in
                if(success){
                    DispatchQueue.onMain {
                        sender.isSelected = true;
                    }
                }
            }
        }
    }
    
    override func prepareComponentForReuse() {
        super.prepareComponentForReuse()
    }
}
