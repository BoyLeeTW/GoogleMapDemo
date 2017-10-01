//
//  AddPhotoViewController.swift
//  GoogleMapDemo
//
//  Created by Brad on 29/09/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit
import GooglePlaces
import AVFoundation

class AddPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    let photoImageView  = UIImageView()
    let imagePicker = UIImagePickerController()
    let subView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // change position of the search bar
//        let subView = UIView(frame: CGRect(x: 0, y: 365.0, width: 350.0, height: 45.0))
        
        self.view.addSubview(subView)
        subView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0).isActive = true
        subView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0).isActive = true
        subView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 70.0).isActive = true
        subView.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
        subView.translatesAutoresizingMaskIntoConstraints = false

        subView.addSubview((searchController?.searchBar)!)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
    
        photoImageViewSetUp()

        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
    }

    func photoImageViewSetUp() {

        self.view.addSubview(photoImageView)

        photoImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15.0).isActive = true
        photoImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15.0).isActive = true
        photoImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 15.0).isActive = true
        photoImageView.heightAnchor.constraint(equalToConstant: self.view.frame.height / 2).isActive = true
        photoImageView.translatesAutoresizingMaskIntoConstraints = false

        photoImageView.clipsToBounds = true

        photoImageView.backgroundColor = .red

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapPhotoImageView(sender: )))
        
        tapRecognizer.delegate = self

        photoImageView.addGestureRecognizer(tapRecognizer)
        
        photoImageView.isUserInteractionEnabled = true

    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.dismiss(animated: true) { () -> Void in
            
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                
                self.photoImageView.image = image
                
                self.photoImageView.contentMode = .scaleAspectFill
                
//                self.journeyImageReminderLabel.isHidden = true
                
            } else {
                
                print("Something went wrong")
                
            }
            
        }
        
    }
    
    @objc func handleTapPhotoImageView(sender: UITapGestureRecognizer) {
        
        let photoAlert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
        photoAlert.addAction(UIAlertAction(title: "Take a photo now", style: .default, handler: { _ in
            
            self.checkCamera()
            
        }))
        
        photoAlert.addAction(UIAlertAction(title: "Choose from album", style: .default, handler: { _ in
            
            self.openAlbum()
            
        }))
        
        photoAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(photoAlert, animated: true)
        
    }

    func openCamera() {
        
        let isCameraExist = UIImagePickerController.isSourceTypeAvailable(.camera)

        let isCameraPermissionAllowed = UIImagePickerController.isCameraDeviceAvailable(.rear)

        if isCameraExist {

            self.imagePicker.delegate = self

            self.imagePicker.sourceType = .camera

            self.present(self.imagePicker, animated: true)

        } else {

            let noCameraPermissionAlert = UIAlertController(title: "Sorry", message: "You don't have camera", preferredStyle: .alert)

            noCameraPermissionAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            self.present(noCameraPermissionAlert, animated: true)

        }

    }

    func checkCamera() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .authorized: openCamera() // Do your stuff here i.e. callCameraMethod()
        case .denied: alertToEncourageCameraAccessInitially()
        case .notDetermined: alertPromptToAllowCameraAccessViaSetting()
        default: alertToEncourageCameraAccessInitially()
        }
    }

    func openAlbum() {
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true)
        
    }

    func callCamera(){
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.camera
        
        self.present(myPickerController, animated: true, completion: nil)
        NSLog("Camera");
    }
    
    func alertToEncourageCameraAccessInitially() {
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Camera access required for capturing photos!",
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func alertPromptToAllowCameraAccessViaSetting() {
        
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Camera access required for capturing photos!",
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { alert in
            if AVCaptureDevice.devices(for: .video).count > 0 {
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async() {
                        self.checkCamera() } }
            }
            }
        )
        present(alert, animated: true, completion: nil)
    }

}

// Handle the user's selection.
extension AddPhotoViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
