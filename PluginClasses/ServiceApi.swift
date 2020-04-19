//
//  ServiceApi.swift
//  TVADataBinder
//
//  Created by MSApps on 16/04/2020.
//

enum HTTPStatusCode: Int ,CaseIterable{
    case success = 200
    case notFound = 404
    case deleted = 204
}

import Foundation

let tokenKey = "AWSCognitoTokenKey"
let defaults = UserDefaults.standard
var baseApi :String?
let favouritePath = "/userlists/favorites/"
let deleteResponseArray: [Int] = HTTPStatusCode.allCases.map{$0.rawValue}

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
        }
        else if (response?.statusCode == HTTPStatusCode.notFound.rawValue){
            completion(false)
        }
        else{
            completion(nil)
        }
    }
}

 /*
 Set favorite state for item according to the the item identifier
 success response is for completion(true)
 */
func setFavoriteState(uid: String, completion: @escaping (( _ success: Bool) -> Void)){
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
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let params: [String:String] = ["object_uid" : uid]
    guard let data  = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) else{
        return
    }
    request.httpBody = data
    makeRequest(request: request) { (responseJson, response, error) in
        if(response?.statusCode == HTTPStatusCode.success.rawValue){
            completion(true)
        }
        else{
            completion(false)
        }
    }
}

/*
Delete favorite state for item according to the the item identifier
success , not found and deleted response is for completion(true)
*/
func deleteFavoriteState(uid: String, completion: @escaping (( _ success: Bool) -> Void)){
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
    request.httpMethod = "DELETE"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    makeRequest(request: request) { (responseJson, response, error) in
        guard let statusCode = response?.statusCode else{
          completion(false)
          return
        }
        if(deleteResponseArray.contains(statusCode)){
            completion(true)
        }
        else{
            completion(false)
        }
    }
}

private func makeRequest(request: NSMutableURLRequest, completion: @escaping ((_ result: Any?, _ httpResponse: HTTPURLResponse?, _ error: Error?) -> Void)) {
    let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
        guard let data = data ,
            let json = (try? JSONSerialization.jsonObject(with: data, options: [])) else {
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
        }
        else {
            DispatchQueue.main.async(execute: block)
        }
    }
}
