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
        //remove the imageViewCollection
        hideImageViewCollection()
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
    
    //MARK: private
    
    func hideImageViewCollection() {
        if let imageViewCollection = self.imageViewCollection {
            for image in imageViewCollection {
                if let image  = image as? UIImageView {
                    image.isHidden = true
                }
            }
        }
    }
    
    func isFreeItem(atomEntry: APAtomEntry) -> Bool {
        if let atomVideoEntry = atomEntry as? APAtomVideoEntry {
            return atomVideoEntry.isFree()
        }else{
            return false
        }
    }
    
    func isLockIconHidden(atomEntry: APAtomEntry) -> Bool {
        if let atomVideoEntry = atomEntry as? APAtomVideoEntry {
            return (atomVideoEntry.isFree() || self.isSubscribed())
        } else {
            return true
        }
    }
    
    //populates an atomEntry with extensions' parameters
    func populateEntry(with atomEntry: APAtomEntry) {
        let type = atomEntry.entryType
        if let itemLockedImageView = self.itemLockedImageView, type == .video {
            atomEntry.extensions["open_with_plugin_id"] = "baby_player_plugin"
            // Replace the lock asset by a new play button asset
            itemLockedImageView.isHidden = false
            if let componentModel = componentModel {
                if(isFreeItem(atomEntry: atomEntry)){
                    if let inAppRibbonImageView = inAppRibbonImageView{
                        inAppRibbonImageView.isHidden = false
                        ZAAppConnector.sharedInstance().componentsDelegate.customization(for: inAppRibbonImageView,
                                                                                         attributeKey: "inapp_ribbon_image",
                                                                                         attributesDictionary: ["image_name" : "inapp_ribbon_image"],
                                                                                         defaultAttributesDictionary: nil,
                                                                                         componentModel: componentModel,
                                                                                         componentDataSourceModel: componentDataSourceModel,
                                                                                         componentState: .normal)
                    }
                }
                
                if isLockIconHidden(atomEntry: atomEntry) == true && !self.shouldPreventUserInteraction(for: atomEntry) {
                    ZAAppConnector.sharedInstance().componentsDelegate.customization(for: itemLockedImageView,
                                                                                     attributeKey: "special_image_2",
                                                                                     attributesDictionary: ["image_name" : "special_image_2"],
                                                                                     defaultAttributesDictionary: nil,
                                                                                     componentModel: componentModel,
                                                                                     componentDataSourceModel: componentDataSourceModel,
                                                                                     componentState: .normal)
                } else {
                    ZAAppConnector.sharedInstance().componentsDelegate.customization(for: itemLockedImageView,
                                                                                     attributeKey: "item_locked_image_view",
                                                                                     attributesDictionary: ["image_name" : "item_locked_image_view"],
                                                                                     defaultAttributesDictionary: nil,
                                                                                     componentModel: componentModel,
                                                                                     componentDataSourceModel: componentDataSourceModel,
                                                                                     componentState: .normal)
                }
            }
        } else if type == .link {
            self.removeFreeLockIcons()
            self.removeCellButtons()
        }
        if let atomVideoEntry = atomEntry as? APAtomVideoEntry {
            if let hqmeButtonContainerView = self.hqmeButtonContainerView,
                !hqmeButtonContainerView.isHidden {
                hqmeButtonContainerView.isUserInteractionEnabled = (atomVideoEntry.isFree() || self.isSubscribed())
            }
        }
        if self.shouldPreventUserInteraction(for: atomEntry) {
            self.removeCellButtons()
            self.removeFreeLockIcons()
            //addHidingView()
        }
    }
    
    func populateFeed(with atomFeed: APAtomFeed) {
        self.removeFreeLockIcons()
        if self.shouldPreventUserInteraction(for: atomFeed) {
            self.removeCellButtons()
            //self.addHidingView()
        }
    }
    
    override func prepareComponentForReuse() {
        super.prepareComponentForReuse()
        self.updateUI()
    }
    
    func removeFreeLockIcons() {
        self.itemLockedImageView?.isHidden = true
        self.inAppRibbonImageView?.isHidden = true
    }
    
    func removeCellButtons() {
        self.favoritesButton?.isHidden = true
        self.hqmeButtonContainerView?.isHidden = true
    }
    
    func shouldPreventUserInteraction(for atomEntry:APAtomEntry) -> Bool {
        var retVal = false;
        let unclickableKey = "unClickable"
        retVal = atomEntry.title == unclickableKey || atomEntry.summary == unclickableKey || atomEntry.pipesObject["ui_tag"] as? String == unclickableKey
        return retVal
    }
    
    func shouldPreventUserInteraction(for atomFeed:APAtomFeed) -> Bool {
        var retVal = false;
        let unclickableKey = "unClickable"
        retVal = atomFeed.pipesObject["summary"] as? String == unclickableKey || atomFeed.pipesObject["ui_tag"] as? String == unclickableKey || atomFeed.title == unclickableKey
        return retVal
    }
    
    func addHidingView() {
        let button = UIButton.init(frame: self.view.frame)
        button.backgroundColor = UIColor.clear
        button.isUserInteractionEnabled = true
        self.view.addSubview(button)
    }
    
    func isSubscribed() -> Bool {
        
        var retVal = false
        
        var subscriptionExpirationDate: Date?
        var authorizationTokens:[String : AnyObject]?
        
        if let endUserProfile = APApplicasterController.sharedInstance()?.endUserProfile,
            let expirationDate = endUserProfile.subscriptionExpirationDate() {
            subscriptionExpirationDate = expirationDate
        }
        
        if let tokens = APAuthorizationManager.sharedInstance().authorizationTokens() as? [String : AnyObject] {
            authorizationTokens = tokens
        }
        if let count = authorizationTokens?.count {
            if subscriptionExpirationDate != nil || (count > 0) {
                retVal = true
            }
        }
        
        return retVal
    }
    
}
