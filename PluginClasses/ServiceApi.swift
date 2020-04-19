//
//  ServiceApi.swift
//  TVADataBinder
//
//  Created by MSApps on 16/04/2020.
//

enum HTTPStatusCode: Int{
    case success = 200
    case notFound = 404
    case deleted = 204
}

import Foundation

let tokenKey = "AWSCognitoTokenKey"
let defaults = UserDefaults.standard
var baseApi :String?
let favouritePath = "/userlists/favorites/"

/*
Get favorite state for item according to the item identifier
success response is for item is favorite
not found response is for item is not favorite
*/
func getFavouriteState(uid: String, completion: @escaping (( _ on: Bool?) -> Void)){
    guard let token = defaults.string(forKey: tokenKey), let baseApiUrl = baseApi else{
        return
    }
    let apiName = "\(baseApiUrl)\(favouritePath)\(uid)"
    let url = URL(string: apiName)
    guard let apiUrl = url else{
        return
    }
    let request = NSMutableURLRequest(url: apiUrl)
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    makeRequest(request: request) { (responseJson, response, error) in
        if(response?.statusCode == HTTPStatusCode.success.rawValue){
            completion(true)
        }else if (response?.statusCode == HTTPStatusCode.notFound.rawValue){
            completion(false)
        }else{
            completion(nil)
        }
    }
}

 /*
 Set favorite state for item according to the the item identifier
 for set on favorite, success response is for completion(true)
 for set off favorite, success , not found and deleted response is for completion(true)
 */
func setFavoriteState(uid: String, on: Bool, completion: @escaping (( _ success: Bool) -> Void)){
    guard let token = defaults.string(forKey: tokenKey), let baseApiUrl = baseApi else{
        return
    }
    let apiName = "\(baseApiUrl)\(favouritePath)\(uid)"
    let url = URL(string: apiName)
    guard let apiUrl = url else{
        return
    }
    let request = NSMutableURLRequest(url: apiUrl)
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.httpMethod = on ? "PUT" : "DELETE"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if(on){
        let params: [String:String] = ["object_uid" : uid]
        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
    }
    makeRequest(request: request) { (responseJson, response, error) in
        if(response?.statusCode == HTTPStatusCode.success.rawValue){
            completion(true)
        }else if(response?.statusCode == HTTPStatusCode.notFound.rawValue){
            on ? completion(false) : completion(true)
        } else if (response?.statusCode == HTTPStatusCode.deleted.rawValue){
            on ? completion(false) : completion(true)
        } else{
            completion(false)
        }
    }
}

private func makeRequest(request: NSMutableURLRequest, completion: @escaping ((_ result: Any?, _ httpResponse: HTTPURLResponse?, _ error: Error?) -> Void)) {
    let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
        guard let data = data , let json = (try? JSONSerialization.jsonObject(with: data, options: [])) else {
            completion(nil, (response as? HTTPURLResponse), error)
            return
        }
        
        print("Response: \(json)")
        if let json = json as? [String:Any]  {
            DispatchQueue.onMain {
                completion(json, (response as? HTTPURLResponse), error)
            }
        }
        else {
            DispatchQueue.onMain {
                completion(json, (response as? HTTPURLResponse), error)
            }
        }
    }
    task.resume()
}

internal extension DispatchQueue {
    static func onMain(_ block: @escaping (() -> Void)) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
}
