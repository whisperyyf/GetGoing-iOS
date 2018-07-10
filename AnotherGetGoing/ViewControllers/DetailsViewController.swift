//
//  DetailsViewController.swift
//  AnotherGetGoing
//
//  Created by Alla Bondarenko on 2018-06-20.
//  Copyright © 2018 Alla Bondarenko. All rights reserved.
//

import UIKit
import MapKit

class DetailsViewController: UIViewController, MKMapViewDelegate {
    
    var place: PlaceOfInterest!
    var detailPlace: PlaceOfInterest!


    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var imageViewAspectRatioLayoutConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addressLabel.text = place.formattedAddress
        updateImageView()
        setMapViewCoordinate()
    }
    
    func updateImageView(){
        //if photoReference and maxWidth are not nil (required for a network request to get a photo), the procced
        if let photoReference = place.photoReference, let maxWidth = place.maxWidth {
            //perform network call with the parameters specified
            GooglePlacesAPI.placePhotoSearch(maxWidth: maxWidth, photoReference: photoReference) {
                (status, image) in
                //on the main thread
                DispatchQueue.main.async {
                    if let img = image {
                        //recalculate aspect ratio based on the current image
                        let aspectRatio = img.size.height / img.size.width
                        
                        //update constraint
                        self.imageViewAspectRatioLayoutConstraint.constant = 1 / aspectRatio
                    }
                    //set image to imageView container
                    self.photoImageView.image = image
                }
            }
        }
    }

    func setMapViewCoordinate(){
        
        mapView.delegate = self
        
        if let coordinate = place.location?.coordinate {
            //constructing the Annotation view (pin with the title) on the map
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.coordinate.latitude = coordinate.latitude
            annotation.coordinate.longitude =  coordinate.longitude
            mapView.addAnnotation(annotation)
            //centering map camera on the point
            centerMapOnLocation(annotation.coordinate)
            
            //indicator in blue of user's current location if allowed by the user.
            mapView.showsUserLocation = true
        }
    }
    
    func centerMapOnLocation(_ location: CLLocationCoordinate2D) {
        let radius = 5000
        let region = MKCoordinateRegionMakeWithDistance(location, CLLocationDistance(Double(radius) * 2.0), CLLocationDistance(Double(radius) * 2.0))
        
        //set the camera on the mapview to cover 5000 radius aroung the point (like a zoom level)
        mapView.setRegion(region, animated: true)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //if user's current location (blue dot), ignore
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        //otherwise, customizing pin on the map for a given l=point.
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "reusePin")
        //allowing to show extra information in the pin view
        view.canShowCallout = true
        //"i" button
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
        view.pinTintColor = UIColor.blue
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //accessory (by default - "i" button on your annotation view.
        let location = view.annotation
        //preparation for a mode in Apple Maps
        let launchingOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        if let coordinate = view.annotation?.coordinate {
            //open apple maps with the required coordinate and launching options - walking mode
            location?.mapItem(coordinate:coordinate).openInMaps(launchOptions: launchingOptions)
        }
    }
    
    func retrievePlacePhoto(placeObj: PlaceOfInterest) {
        if let photoReference = place.photoReference, let maxWidth = place.maxWidth {
            GooglePlacesAPI.placePhotoSearch(maxWidth: maxWidth, photoReference: photoReference) {
                (status, image) in
                DispatchQueue.main.async {
                    if image != nil {
                        self.photoImageView.image = image
                    }
                }
            }
        }
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MKAnnotation {
    func mapItem(coordinate: CLLocationCoordinate2D)-> MKMapItem {
        
        let placeMark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placeMark)
        return mapItem
        
    }
}
