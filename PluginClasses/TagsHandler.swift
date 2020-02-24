//
//  TagsHandler.swift
//  Alamofire
//
//  Created by MSApps on 23/02/2020.
//

import Foundation
 
 private let CONF_TAG_STYLE_JSON = "tag_styles_json"
 var styleArry: [ZappStyle]?

func setStylesList(stylesJsonString: String){
    var styles = [ZappStyle]()
    if let jsonStyles = stylesJsonString.toJSON() as? [String:Any]{
        if let stylesArry = jsonStyles["styles"] as? [[String:String]]{
            for style in stylesArry{
                styles.append(ZappStyle(dic: style))
            }
        }
    }
    
    if(styles.count > 0){
        styleArry = styles
    }
}

func getStyle(styleName:String) -> ZappStyle?{
    if let sList  = styleArry{
        if let foundObject = sList.first(where:{($0.keyRegex?.regExpression(expectedExpersion: styleName))!}){
            return foundObject
        }else{
            return nil
        }
    }else{
        return nil
    }
}

func getStringJsonFromConfig(config: [String:Any]){
    if let stringJson  = config[CONF_TAG_STYLE_JSON] as? String{
        setStylesList(stylesJsonString: stringJson)
    }
}

class ZappStyle {
    var keyRegex: String?
    let font = "font"
    let textColor = "textColor"
    let textSize = "textSize"
    let backgroundColor = "backgroundColor"
    var styleDic: [String:String]?
    
    init(dic:[String:String]) {
        self.keyRegex = dic["keyRegex"]
        self.styleDic = dic
    }
}

extension String {
     func regExpression (expectedExpersion: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: self) else { return false }
        let range = NSRange(location: 0, length: expectedExpersion.utf16.count)
        return regex.firstMatch(in: expectedExpersion, options: [], range: range) != nil
    }
    
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: [])
      }
}

