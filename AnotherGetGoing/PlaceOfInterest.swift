//
//  PlaceOfInterest.swift
//  AnotherGetGoing
//
//  Created by Alla Bondarenko on 2018-06-18.
//  Copyright © 2018 Alla Bondarenko. All rights reserved.
//

import Foundation
import CoreLocation

class PlaceOfInterest: NSObject, NSCoding {
    
    //keys used for archiving the obj (persistent storage)
    struct PropertyKey {
        static let idKey = "id"
        static let nameKey = "name"
        static let ratingKey = "rating"
        static let iconKey = "icon"
        static let latKey = "lat"
        static let lngKey = "lng"
        static let photoReferenceKey = "photoReference"
        static let maxWidthKey = "maxWidth"
        static let typesKey = "types"
        static let vicinityKey = "vicinity"
        static let formattedAddressKey = "formattedAddress"
    }
    
    var id: String
    var name: String
    var rating: Double?
    var location: CLLocation?
    var formattedAddress: String?
    var iconUrl: String?
    var photoReference: String?
    var maxWidth: Int?
    var vicinity: String?
    var types: [String]
    var categories: String? {
        get {
            if types.count > 0 {
                var finalString = ""
                for (index, type) in types.enumerated() {
                    if index == 0 {
                        finalString.append(type)
                    } else {
                        finalString.append(", \(type)")
                    }
                }
                return finalString
            } else {
                return nil
            }
        }
    }

    init?(json: [String: Any]){
        
        guard let id = json["id"] as? String else {
            return nil
        }
        guard let name = json["name"] as? String else {
            return nil
        }
        self.id = id
        self.name = name
        
        self.rating = json["rating"] as? Double
        self.formattedAddress = json["formatted_address"] as? String
        
        let categories = json["types"] as? [String] ?? []
        self.iconUrl = json["icon"] as? String
        
        //parsing an array of nested json objects
        if let photos = json["photos"] as? [[String: Any]]{
            for photo in photos {
                if let photoReference = photo["photo_reference"] as? String {
                    self.photoReference = photoReference
                }
                if let maxWidth = photo["width"] as? Int {
                    self.maxWidth = maxWidth
                }
            }
        }
        
        if let geometry = json["geometry"] as? [String: Any] {
            if let locationCoordinate = geometry["location"] as? [String: Double
                ] {
                if locationCoordinate["lat"] != nil, locationCoordinate["lng"] != nil {
                    self.location = CLLocation(latitude: locationCoordinate["lat"]!, longitude: locationCoordinate["lng"]!)
                }
            }
        }
        self.types = categories
    }
    //default initializer for persistent storage implementation
    init(id: String, name: String, rating: Double?, location: CLLocation?, iconUrl: String?, photoReference: String?, maxWidth: Int?, types: [String], vicinity: String?, formattedAddress: String?) {
        
        self.id = id
        self.name = name
        self.rating = rating
        self.location = location
        self.iconUrl = iconUrl
        self.photoReference = photoReference
        self.maxWidth = maxWidth
        self.types = types
        self.vicinity = vicinity
        self.formattedAddress = formattedAddress
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: PropertyKey.idKey)
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        if let rating = rating {
            aCoder.encode(rating, forKey: PropertyKey.ratingKey)
        }
        if let locationCoordinate = location?.coordinate {
            aCoder.encode(Double(locationCoordinate.latitude), forKey: PropertyKey.latKey)
            aCoder.encode(Double(locationCoordinate.longitude), forKey: PropertyKey.lngKey)
        }
        aCoder.encode(iconUrl, forKey: PropertyKey.iconKey)
        aCoder.encode(photoReference, forKey: PropertyKey.photoReferenceKey)
        if let maxWidth = maxWidth {
            aCoder.encode(maxWidth, forKey: PropertyKey.maxWidthKey)
        }
        aCoder.encode(types, forKey: PropertyKey.typesKey)
        aCoder.encode(vicinity, forKey: PropertyKey.vicinityKey)
        aCoder.encode(formattedAddress, forKey: PropertyKey.formattedAddressKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        //"recovering" - decoding properties one by one and then initializing the Class using the default initializer
        var location: CLLocation?
        
        let id = aDecoder.decodeObject(forKey: PropertyKey.idKey) as! String
        let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
        let rating = aDecoder.decodeDouble(forKey: PropertyKey.ratingKey)
        let iconUrl = aDecoder.decodeObject(forKey: PropertyKey.iconKey) as? String
        
        let lat = aDecoder.decodeDouble(forKey: PropertyKey.latKey)
        let lng = aDecoder.decodeDouble(forKey: PropertyKey.lngKey)
        location = CLLocation(latitude: lat, longitude: lng)
        
        let photoReference = aDecoder.decodeObject(forKey: PropertyKey.photoReferenceKey) as? String
        let maxWidth = aDecoder.decodeObject(forKey: PropertyKey.maxWidthKey) as? Int
        let types = aDecoder.decodeObject(forKey: PropertyKey.typesKey) as? [String] ?? []
        let vicinity = aDecoder.decodeObject(forKey: PropertyKey.vicinityKey) as? String
        let formattedAddress = aDecoder.decodeObject(forKey: PropertyKey.formattedAddressKey) as? String
        self.init(id: id, name: name, rating: rating, location: location, iconUrl: iconUrl, photoReference: photoReference, maxWidth: maxWidth, types: types, vicinity: vicinity, formattedAddress: formattedAddress)
    }
    
}