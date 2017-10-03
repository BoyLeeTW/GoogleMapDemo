//
//  PhotosTableViewController+UINavigationControllerDelegate, UIImagePickerControllerDelegate .swift
//  GoogleMapDemo
//
//  Created by Brad on 03/10/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit
import AVFoundation

extension PhotosTableViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.dismiss(animated: true) { () -> Void in
            
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                
                self.photoViewImage = image
                
                self.performSegue(withIdentifier: "showAddPhotoView", sender: nil)
                
            } else {
                
                print("Something went wrong")
                
            }
            
        }
        
    }
    
    @objc func handleTapPhotoImageView(sender: UITapGestureRecognizer?) {
        
        let photoAlert = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        
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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showAddPhotoView" {
            
            let destinationViewController = segue.destination as? AddPhotoViewController
            
            destinationViewController?.photoImageView.image = photoViewImage
            
            destinationViewController?.isEditingPhoto = false
            
        } else if segue.identifier == "showEditPhotoView" {
            
            let destinationViewController = segue.destination as? AddPhotoViewController
            
            destinationViewController?.isEditingPhoto = true
            
            destinationViewController?.photoInformation = existingPhotos[selectedRow]
            
            destinationViewController?.photoImageView.sd_setImage(with: URL(string: existingPhotos[selectedRow].photoImageURL), completed: nil)
            
            destinationViewController?.placeNameButton.setTitle(existingPhotos[selectedRow].placeName, for: .normal)
            
            destinationViewController?.photoAutoID = existingPhotos[selectedRow].uniqueID
            
            destinationViewController?.searchController?.searchBar.isHidden = true
            
        }
        
    }


}
