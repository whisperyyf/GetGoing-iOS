//
//  SearchViewController.swift
//  AnotherGetGoing
//
//  Created by Alla Bondarenko on 2018-06-13.
//  Copyright © 2018 Alla Bondarenko. All rights reserved.
//

import UIKit
import CoreLocation

class SearchViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchParameterTextField: UITextField!
    
    var searchParam: String?
    
    //MARK: - View Controller LifeCycle Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchParameterTextField.delegate = self
        activityIndicator.isHidden = true
    }
    
    
    // MARK: - Button Actions
    @IBAction func searchButtonAction(_ sender: UIButton) {
        print("chooo chooo button")
        searchParameterTextField.resignFirstResponder()
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            if let inputValue = searchParam {
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                GooglePlacesAPI.textSearch(query: inputValue, completionHandler: {(status, json) in
                    if let jsonObj = json {
                        let places = APIParser.parseAPIResponse(json: jsonObj)
                        //update UI on the main thread!
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.isHidden = true
                            if places.count > 0 {
                                self.presentSearchResults(places)
                                self.savePlacesToLocalStorage(places: places)
                            } else {
                                self.generalAlert(title: "Oops", message: "No results found")
                            }
                        }
                        print("\(places.count)")
                    } else {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.generalAlert(title: "Oops", message: "An error parsing json")
                    }
                })
                
            } else {
                generalAlert(title: "Oops", message: "An error has occurred")
            }
        case 1:
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            if let currentLocation = LocationService.sharedInstance.currentLocation {
                GooglePlacesAPI.nearbySearch(for: currentLocation.coordinate, keyword: searchParam, completionHandler: {(status, json) in
                    if let jsonObj = json {
                        let places = APIParser.parseAPIResponse(json: jsonObj)
                        //update UI on the main thread!
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.isHidden = true
                            if places.count > 0 {
                                self.savePlacesToLocalStorage(places: places)
                                self.presentSearchResults(places)
                            } else {
                                self.generalAlert(title: "Oops", message: "No results found")
                            }
                        }
                        print("\(places.count)")
                    } else {
                        self.generalAlert(title: "Oops", message: "An error parsing json")
                    }
                })
            } else {
                generalAlert(title: "Oops", message: "Could not identify your location")
            }
        default:
            break;
        }
        
    }
    
    @IBAction func loadLastSavedResults(_ sender: UIButton) {
        if let places = loadListsFromLocalStorage() {
            presentSearchResults(places)
        }
    }
    
  
    
    @IBAction func searchSelectionChanged(_ sender: UISegmentedControl) {
        print("segment control changed \(segmentedControl.selectedSegmentIndex)")
        if segmentedControl.selectedSegmentIndex == 1 {
            LocationService.sharedInstance.delegate = self
            LocationService.sharedInstance.startUpdatingLocation()
        }
    }
    
    //MARK: - Local Storage
    
    func savePlacesToLocalStorage(places: [PlaceOfInterest]) {
        //save array of PlaceOfInterest object to local storage
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(places, toFile: Constants.ArchiveURL.path)
        print("is successful save \(isSuccessfulSave)")
    }
    
    func loadListsFromLocalStorage() -> [PlaceOfInterest]? {
        //pull data from the local storage
        return NSKeyedUnarchiver.unarchiveObject(withFile: Constants.ArchiveURL.path) as? [PlaceOfInterest]
    }
    
    func presentSearchResults(_ results: [PlaceOfInterest]){
        
        let searchResultsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResultsViewController") as! SearchResultsViewController
        searchResultsViewController.places = results
        
        navigationController?.pushViewController(searchResultsViewController, animated: true)
    }
    
    
    func generalAlert(title: String, message: String?){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        
        present(alertController, animated: true) {
            self.searchParameterTextField.placeholder = "Input something"
        }
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
    
    @IBAction func presentFilters(_ sender: UIButton) {
        let filtersViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FiltersViewController") as! FiltersViewController
        
        present(filtersViewController, animated: true, completion: nil)
    }
    
}


//MARK: - Text Field Delegate
extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchParameterTextField {
            textField.resignFirstResponder()
            return true
        }
        return false
    }
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == searchParameterTextField {
            searchParam = textField.text
            print(textField.text ?? "no input")
        }
        return true
    }
    
}

//MARK: - Location Service Delegate

extension SearchViewController: LocationServiceDelegate {
    func tracingLocation(_ currentLocation: CLLocation) {
        print("\(currentLocation.coordinate.latitude) \(currentLocation.coordinate.longitude)")
    }
    
    func tracingLocationDidFailWithError(_ error: Error) {
        
    }
}

