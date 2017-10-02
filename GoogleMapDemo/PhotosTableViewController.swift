//
//  PhotosTableViewController.swift
//  GoogleMapDemo
//
//  Created by Brad on 29/09/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit
import AVFoundation

class PhotosTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBAction func touchAddPhotoButton(_ sender: Any) {

        handleTapPhotoImageView(sender: nil)

    }

    var photoViewImage: UIImage!

    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

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

        }

    }

}
