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
import Firebase

class AddPhotoViewController: UIViewController, UIGestureRecognizerDelegate, UISearchControllerDelegate {

    var resultsViewController: GMSAutocompleteResultsViewController?

    var searchController: UISearchController?

    let imagePicker = UIImagePickerController()

    let photoImageView  = UIImageView()

    let placeNameButton = UIButton()

    let deletePhotoButton = UIButton()

    let photoManager = PhotoManager()

    var isEditingPhoto: Bool = false

    var photoInformation: Photo?

    var placeLongitute: Double = 0.0
    
    var placeLatitude: Double = 0.0

    var photoAutoID: String = String()

    @IBAction func touchAddPhotoButton(_ sender: UIBarButtonItem) {

        let ref = Database.database().reference()
        
        let storageRef = Storage.storage().reference()

        sender.isEnabled = false

        if !isEditingPhoto {

            photoAutoID = ref.child("savedPhoto").childByAutoId().key

        }

        guard
            let photoImage = photoImageView.image,
            let compressedUploadData = UIImageJPEGRepresentation(photoImage, 0.6),
            let placeName: String = placeNameButton.titleLabel?.text
            else { return }

        let photoStorageRef = storageRef.child("savedPhoto").child("\(photoAutoID).jpg")

        photoStorageRef.putData(compressedUploadData, metadata: nil) { (metadata, error) in

            guard
                let metadata = metadata,
                let downloadURL = metadata.downloadURL()?.absoluteString
                else { return }

            let photoInformation = Photo(placeName: placeName,
                                         uniqueID: self.photoAutoID,
                                         latitude: self.placeLatitude,
                                         longitute: self.placeLongitute,
                                         photoImageURL: downloadURL
            )
            
            DispatchQueue.global().async {
                
                self.photoManager.savePhoto(photoAutoID: self.photoAutoID,
                                            placeName: photoInformation.placeName,
                                            uniqueID: photoInformation.uniqueID,
                                            photoImageURL: photoInformation.photoImageURL,
                                            longitute: photoInformation.longitute,
                                            latitude: photoInformation.latitude
                )
                
                sender.isEnabled = true

            }

            DispatchQueue.main.async {

                self.navigationController?.popViewController(animated: true)

            }
            
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpGooglePlacesAutoComplete()

        setUpPlaceNameButton()

        setUpPhotoImageView()

        setUpDeletePhotoButton()

        if !isEditingPhoto {

            self.placeNameButton.isHidden = true

        } else {

            self.deletePhotoButton.isHidden = false

        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)

        if !isEditingPhoto {

            assignSearchBarAsFirstResponder()

        }

    }

    func setUpPlaceNameButton() {

        view.addSubview(placeNameButton)

        placeNameButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50.0).isActive = true
        placeNameButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 64.0).isActive = true
        placeNameButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0.0).isActive = true
        placeNameButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        placeNameButton.translatesAutoresizingMaskIntoConstraints = false

        placeNameButton.backgroundColor = .red

        placeNameButton.addTarget(self, action: #selector(assignSearchBarAsFirstResponder), for: .touchUpInside)

    }

    @objc func assignSearchBarAsFirstResponder() {

        self.searchController?.searchBar.isHidden = false

        DispatchQueue.main.async {
            self.searchController?.searchBar.becomeFirstResponder()
        }

    }

    @objc func touchDeletePhotoButton() {

        let alertController = UIAlertController(title: "Attention",
                                                message: "Do you really want to delete?",
                                                preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { _ in
            
            self.navigationController?.popViewController(animated: true)

            self.photoManager.deletePhoto(photoAutoID: self.photoAutoID)

        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }

    func setUpGooglePlacesAutoComplete() {

        let subView = UIView()

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // change position of the search bar
        self.view.addSubview(subView)
        subView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0).isActive = true
        subView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0).isActive = true
        subView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 64.0).isActive = true
        subView.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
        subView.translatesAutoresizingMaskIntoConstraints = false
        
        subView.addSubview((searchController?.searchBar)!)
        searchController?.searchBar.delegate = self
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false

        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true

        if isEditingPhoto {

            searchController?.searchBar.isHidden = true

        }

    }

    func setUpPhotoImageView() {

        self.view.addSubview(photoImageView)

        photoImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15.0).isActive = true
        photoImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15.0).isActive = true
        photoImageView.topAnchor.constraint(equalTo: self.placeNameButton.bottomAnchor, constant: 30.0).isActive = true
        photoImageView.heightAnchor.constraint(equalToConstant: self.view.frame.height / 2).isActive = true
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.clipsToBounds = true

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapPhotoImageView(sender: )))
        
        tapRecognizer.delegate = self

        photoImageView.addGestureRecognizer(tapRecognizer)

        photoImageView.isUserInteractionEnabled = true

    }

    func setUpDeletePhotoButton() {

        self.view.addSubview(deletePhotoButton)

        deletePhotoButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50.0).isActive = true
        deletePhotoButton.topAnchor.constraint(equalTo: self.photoImageView.bottomAnchor, constant: 30).isActive = true
        deletePhotoButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0.0).isActive = true
        deletePhotoButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        deletePhotoButton.translatesAutoresizingMaskIntoConstraints = false

        deletePhotoButton.backgroundColor = .red

        deletePhotoButton.setTitle("DELETE", for: .normal)

        deletePhotoButton.addTarget(self, action: #selector(touchDeletePhotoButton), for: .touchUpInside)

        deletePhotoButton.isHidden = true

    }

}

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

extension AddPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.dismiss(animated: true) { () -> Void in
            
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                
                self.photoImageView.image = image
                
                self.photoImageView.contentMode = .scaleAspectFill
                
            } else {
                
                print("Something went wrong")
                
            }
            
        }
        
    }
    
    @objc func handleTapPhotoImageView(sender: UITapGestureRecognizer?) {
        
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
            
        case .authorized: openCamera()
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

//extension AddPhotoViewController: UITextFieldDelegate {
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//    }
//
//}

extension AddPhotoViewController: UISearchBarDelegate {

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("END EDITING!")
    }

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

