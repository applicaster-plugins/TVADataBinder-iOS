//
// ZPDataBinderBabyFirst.swift
//
//  Created by Miri Vecselboim on
//
//

import Foundation
import ZappGeneralPluginsSDK
import ApplicasterSDK
import ZappSDK

class ZPDataBinderTVA: ZPGeneralBaseProvider, ZPGeneralPluginUIProtocol {
    
    required init(configurationJSON: NSDictionary?) {
        super.init(configurationJSON: configurationJSON)
        if let config = configurationJSON as? [String:Any]{
            if(styleArry == nil){
                getStringJsonFromConfig(config: config)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init() {
        super.init()
    }
    
    func viewController(options: [AnyHashable: Any]?) -> UIViewController? {
        
        guard let viewController = options?["viewController"] as? UIViewController else {
            return nil
        }
        guard var cellViewController = viewController as? CACellViewController else {
            return viewController
        }
        
        if let xibName = options?["xibKeyName"] as? String,
            let classType = NSClassFromString("TVADataBinder.ZPTVACellViewController") as? CACellViewController.Type {
            if let zappLayoutsStylesBundle = ZAAppConnector.sharedInstance().layoutsStylesDelegate.zappLayoutsStylesBundle(),
                (zappLayoutsStylesBundle.path(forResource: xibName, ofType: "nib") != nil) {
                cellViewController = classType.init(nibName: xibName, bundle: zappLayoutsStylesBundle)
            }
            else if let stylesBundle = ZAAppConnector.sharedInstance().layoutsStylesDelegate.stylesBundle(),
                (stylesBundle.path(forResource: xibName, ofType: "nib") != nil) {
                cellViewController = classType.init(nibName: xibName, bundle: stylesBundle)
            }
            else if let pluginModels = ZPPluginManager.pluginModels("cell_style_family") {
                for pluginModel in pluginModels {
                    if let cellStyleBundle = ZPPluginManager.bundleForModelClass(pluginModel),
                        (cellStyleBundle.path(forResource: xibName, ofType: "nib") != nil) {
                        cellViewController = classType.init(nibName: xibName, bundle: cellStyleBundle)
                    }
                }
            }
        }
        return cellViewController
    }
}
