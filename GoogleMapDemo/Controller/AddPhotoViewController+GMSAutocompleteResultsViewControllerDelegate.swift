//
//  AddPhotoViewController+GMSAutocompleteResultsViewControllerDelegate.swift
//  GoogleMapDemo
//
//  Created by Brad on 03/10/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import GooglePlaces

extension AddPhotoViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        
        searchController?.isActive = false
        
        self.placeLatitude = place.coordinate.latitude
        self.placeLongitute = place.coordinate.longitude
        self.placeNameButton.setTitle(place.name, for: .normal)
        self.placeNameButton.isHidden = false
        self.searchController?.searchBar.isHidden = true
        
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        
        print("Error: ", error.localizedDescription)
    }
    
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
