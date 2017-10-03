//
//  AddPhotoViewController+UISearchBarDelegate.swift
//  GoogleMapDemo
//
//  Created by Brad on 03/10/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import Foundation
import UIKit

extension AddPhotoViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        if self.placeNameButton.titleLabel?.text == nil {
            
            let alert = UIAlertController(
                title: "IMPORTANT",
                message: "Must choose a place for this photo!",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { _ in
                
                self.assignSearchBarAsFirstResponder()
                
            }))
            
            self.present(alert, animated: true)
            
        } else {
            
            searchController?.searchBar.isHidden = true
            
        }
        
    }
    
}
