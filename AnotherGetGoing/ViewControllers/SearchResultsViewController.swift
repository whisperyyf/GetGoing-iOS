//
//  SearchResultsViewController.swift
//  AnotherGetGoing
//
//  Created by Alla Bondarenko on 2018-06-18.
//  Copyright © 2018 Alla Bondarenko. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var places: [PlaceOfInterest]!
    var sortedPlaces: [PlaceOfInterest]!

    @IBOutlet weak var sortSegment: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tableViewCellNib = UINib(nibName: "POITableViewCell", bundle: nil)
        tableView.register(tableViewCellNib, forCellReuseIdentifier: "reusableIdentifier")
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func Sort(index: Int) {
        switch index {
        case 0:
            places = places.sorted(by: {
                $0.name < $1.name
            })
        case 1:
            places = places.sorted(by: {
                Int($0.rating!) > Int($1.rating!)
            })
        default:
            break;
        }
        tableView.reloadData()
    }
    
    //MARK: - Sort Segment Control Action
    
    @IBAction func sortSegmentAction(_ sender: UISegmentedControl) {
        print("Changed \(sortSegment.selectedSegmentIndex)")
        
        Sort(index: sortSegment.selectedSegmentIndex)
        
        
        
        
    }
    
    //MARK: - TableView Delegate methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableIdentifier") as! POITableViewCell
        cell.titleLabel.text = places[indexPath.row].name
        cell.addressLabel.text = places[indexPath.row].formattedAddress
//        cell.iconImageView
        
        if let imageUrl  = places[indexPath.row].iconUrl, let url = URL(string: imageUrl),
            let dataContents = try? Data(contentsOf: url), let imageSrc = UIImage(data: dataContents){
            cell.iconImageView.image = imageSrc
        }
        /////////////////////////
        if let rating = places[indexPath.row].rating{
            cell.ratingControl.rating = Int(rating.rounded(.toNearestOrAwayFromZero))
        }else{
            
        }
        return cell
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlace = places[indexPath.row]
        if let placeId = selectedPlace.placeId {
            GooglePlacesAPI.placeDetailsSearch(query: placeId, completionHandler: {(status, json) in
                if let jsonObj = json {
                    let place = APIParser.parseAPIResponseForPlaceDetails(json: jsonObj)
                    print("found place \(place)")
                    DispatchQueue.main.async {
                        self.presentPlaceDetails(place)
                    }
                }
                else {
                    print("error parsing json!")
                }
            })
        }
    }
    
    func presentPlaceDetails(_ results: PlaceOfInterest) {
        let detailsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        
        detailsViewController.place = results
        
        navigationController?.pushViewController(detailsViewController, animated: true)
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
