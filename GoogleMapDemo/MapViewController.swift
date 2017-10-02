//
//  MapViewController.swift
//  GoogleMapDemo
//
//  Created by Brad on 29/09/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit
import GoogleMaps
import SDWebImage

class PhotoMarker: GMSMarker {

    var photoInformation: Photo?

}

class MapViewController: UIViewController {

    let photoManager = PhotoManager()

    var existingPhotos: [Photo] = [Photo]()

    var photoImformation: Photo!

    override func loadView() {
        super.loadView()

        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: 25.032963599999995, longitude: 121.56542680000001, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)

        mapView.delegate = self

        view = mapView

        photoManager.fetchPhotos { (existingPhotos) in

            self.existingPhotos = existingPhotos

            for photo in existingPhotos {

                let tempImage = UIImageView()
                tempImage.sd_setImage(with: URL(string: photo.photoImageURL), completed: nil)
                let photoMarker = PhotoMarker()
                
                photoMarker.position = CLLocationCoordinate2D(latitude: photo.latitude, longitude: photo.longitute)
                photoMarker.title = photo.placeName
                photoMarker.snippet = "Hey, this is \(photo.placeName)"
                photoMarker.map = mapView
                photoMarker.photoInformation = photo
                photoMarker.tracksInfoWindowChanges = true
            }
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showEditView" {

            let destinationViewController = segue.destination as? AddPhotoViewController

            destinationViewController?.isEditingPhoto = true
            
            destinationViewController?.photoInformation = photoImformation

            destinationViewController?.photoImageView.sd_setImage(with: URL(string: photoImformation.photoImageURL), completed: nil)
            
            destinationViewController?.placeNameButton.setTitle(photoImformation.placeName, for: .normal)
            
            destinationViewController?.photoAutoID = photoImformation.uniqueID

            destinationViewController?.searchController?.searchBar.isHidden = true

        }

    }

}

extension MapViewController: GMSMapViewDelegate {

    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {

        let marker = marker as! PhotoMarker

        photoImformation = marker.photoInformation

        self.performSegue(withIdentifier: "showEditView", sender: nil)
        
    }
    
}

