//
//  PhotosTableViewController.swift
//  GoogleMapDemo
//
//  Created by Brad on 29/09/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import UIKit
import SDWebImage

class PhotosTableViewController: UITableViewController{

    @IBAction func touchAddPhotoButton(_ sender: Any) {

        handleTapPhotoImageView(sender: nil)

    }

    var photoViewImage: UIImage!

    let imagePicker = UIImagePickerController()

    let photoManager = PhotoManager()

    var existingPhotos = [Photo]()

    var selectedRow: Int = Int()

    override func viewDidLoad() {
        super.viewDidLoad()

        photoManager.fetchPhotos { (existingPhotos) in

            self.existingPhotos = existingPhotos

            self.tableView.reloadData()

        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return existingPhotos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotosTableViewCell

        cell.photoImageView.sd_setImage(with: URL(string: existingPhotos[indexPath.row].photoImageURL), completed: nil)

        cell.photoNameLabel.text = existingPhotos[indexPath.row].placeName

        return cell

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.selectedRow = indexPath.row

        self.performSegue(withIdentifier: "showEditPhotoView", sender: nil)
        
    }

}
