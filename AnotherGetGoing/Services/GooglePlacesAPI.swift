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
    
    class func textSearch(query: String, radius: Int = 5000, openNow: Bool?, rankBy: String?, completionHandler: @escaping(_ statusCode: Int, _ json: [String: Any]?) -> Void){
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.scheme
        urlComponents.host = Constants.host
        urlComponents.path = Constants.textPlaceSearch
        
        urlComponents.queryItems = [
            URLQueryItem(name: "placeid", value: query),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "key", value: Constants.apiKey)
        ]
        if let openNow = openNow {
            urlComponents.queryItems?.append(URLQueryItem(name: "opennow", value: String(openNow)))
        }
        
        if radius <= 5000 {
            urlComponents.queryItems?.append(URLQueryItem(name: "radius", value: String(radius)))
        } else {
            urlComponents.queryItems?.append(URLQueryItem(name: "rankby", value: rankBy))
        }
        
        retrieveJsonResponseFromUrl(urlComponents: urlComponents, callbackFunction: completionHandler)
    }
    
    class func placeDetailsSearch(query: String, completionHandler: @escaping(_ statusCode: Int, _ json: [String: Any]?) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.scheme
        urlComponents.host = Constants.host
        urlComponents.path = Constants.placeDetails
        
        urlComponents.queryItems = [
            URLQueryItem(name: "placeid", value: query),
            URLQueryItem(name: "key", value: Constants.apiKey)
        ]
        
        retrieveJsonResponseFromUrl(urlComponents: urlComponents, callbackFunction: completionHandler)
    }
    class func nearbyLocationSearch(keyword: String?, locationCoordinates: CLLocationCoordinate2D, radius: Int = 5000 , openNow: Bool?, rankBy: String?, completionHandler: @escaping(_ statusCode: Int, _ json: [String: Any]?) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.scheme
        urlComponents.host = Constants.host
        urlComponents.path = Constants.nearbyPlaceSearch
        
        let location = "\(locationCoordinates.latitude),\(locationCoordinates.longitude)"
        
        urlComponents.queryItems = [
            URLQueryItem(name: "location", value: location),
            URLQueryItem(name: "key", value: Constants.apiKey)
        ]
        
        if rankBy == RankBy.distance.description(), let keyword = keyword, let openNow = openNow {
            urlComponents.queryItems?.append(URLQueryItem(name: "rankby", value: rankBy))
            urlComponents.queryItems?.append(URLQueryItem(name: "keyword", value: keyword))
            urlComponents.queryItems?.append(URLQueryItem(name: "opennow", value: String(openNow)))
        } else {
            urlComponents.queryItems?.append(URLQueryItem(name: "radius", value: String(radius)))
        }
        
        retrieveJsonResponseFromUrl(urlComponents: urlComponents, callbackFunction: completionHandler)
    }
    
    class func placePhotoSearch(maxWidth: Int, photoReference: String, completionHandler: @escaping(_ statusCode: Int, _ imageData: UIImage?) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.scheme
        urlComponents.host = Constants.host
        urlComponents.path = Constants.placePhotoSearch
        
        urlComponents.queryItems = [
            URLQueryItem(name: "photoreference", value: photoReference),
            URLQueryItem(name: "maxwidth", value: String(maxWidth)),
            URLQueryItem(name: "key", value: Constants.apiKey)
        ]
        
        NetworkingLayer.getRequest(with: urlComponents) {
            (statusCode, data) in
            if let imageData = data {
                completionHandler(statusCode, UIImage(data: imageData))
            } else {
                print("This is not easy")
                completionHandler(statusCode, nil)
            }
        }
    }
    
    class func retrieveJsonResponseFromUrl(urlComponents: URLComponents, callbackFunction: @escaping(_ statusCode: Int, _ json: [String: Any]?) -> Void) {
        NetworkingLayer.getRequest(with: urlComponents) {
            (statusCode, data) in
            if let jsonData = data, let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] {
                print(jsonObject ?? "")
                callbackFunction(statusCode, jsonObject)
            } else {
                print("This is not easy")
                callbackFunction(statusCode, nil)
            }
        }
    }
}
