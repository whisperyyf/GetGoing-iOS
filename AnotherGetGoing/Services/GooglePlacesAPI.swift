//
//  GooglePlacesAPI.swift
//  AnotherGetGoing
//
//  Created by Alla Bondarenko on 2018-06-18.
//  Copyright © 2018 Alla Bondarenko. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class GooglePlacesAPI {
    
    class func textSearch(query: String, completionHandler: @escaping(_ statusCode: Int, _ json: [String: Any]?) -> Void){
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.scheme
        urlComponents.host = Constants.host
        urlComponents.path = Constants.textPlaceSearch
        
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "key", value: Constants.apiKey)
        ]
        
        NetworkingLayer.getRequest(with: urlComponents) { (statusCode, data) in
            if let jsonData = data,
                let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] {
                print(jsonObject ?? "")
                completionHandler(statusCode, jsonObject)
            } else {
                print("life is not easy")
                completionHandler(statusCode, nil)
            }
        }
        
    }
    
    
    class func nearbySearch(for locationCoordinate: CLLocationCoordinate2D, radius: Int = 5000, keyword: String?, completionHandler: @escaping(_ statusCode: Int, _ json: [String: Any]?) -> Void){
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.scheme
        urlComponents.host = Constants.host
        urlComponents.path = Constants.nearbyPlaceSearch
        
        let locationParameter = "\(locationCoordinate.latitude),\(locationCoordinate.longitude)"
        
        //adding parameters to network request
        urlComponents.queryItems = [
            URLQueryItem(name: "location", value: locationParameter),
            URLQueryItem(name: "radius", value: String(radius)),
            URLQueryItem(name: "key", value: Constants.apiKey)
        ]
        if let keyword = keyword {
            urlComponents.queryItems?.append(URLQueryItem(name: "keyword", value: keyword))
        }
        
        NetworkingLayer.getRequest(with: urlComponents) { (statusCode, data) in
            if let jsonData = data,
                let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] {
                print(jsonObject ?? "")
                completionHandler(statusCode, jsonObject)
            } else {
                print("life is not easy")
                completionHandler(statusCode, nil)
            }
        }
        
    }
    
    class func requestPhoto(photoreference: String, maxWidth: Int, completion: @escaping (_ status: Int, UIImage?) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.scheme
        urlComponents.host = Constants.host
        urlComponents.path = Constants.placePhotoSearch
        
        urlComponents.queryItems = [
            URLQueryItem(name: "photoreference", value: photoreference),
            URLQueryItem(name: "maxwidth", value: String(maxWidth)),
            URLQueryItem(name: "key", value: Constants.apiKey)
        ]
        
        NetworkingLayer.getRequest(with: urlComponents) { (status, data) in
            if let data = data {
                let image = UIImage(data: data)
                completion(200, image)
            } else {
                completion(500, nil)
            }
        }
    }
   
    
}
