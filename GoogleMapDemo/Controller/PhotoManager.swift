//
//  PhotoManager.swift
//  GoogleMapDemo
//
//  Created by Brad on 02/10/2017.
//  Copyright © 2017 Brad. All rights reserved.
//

import Foundation
import Firebase

class PhotoManager {

    var reference: DatabaseReference!

    var storageReference: StorageReference!

    func savePhoto(photoAutoID: String, placeName: String, uniqueID: String, photoImageURL: String, longitute: Double, latitude: Double) {

        reference = Database.database().reference()

        reference.child("savedPhoto").child(photoAutoID).updateChildValues([
            "placeName": placeName,
            "uniqueID": "\(uniqueID)",
            "url": "\(photoImageURL)",
            "longitute": longitute,
            "latitude": latitude]
        )

    }

    func deletePhoto(photoAutoID: String) {

        reference = Database.database().reference()

        reference.child("savedPhoto").child(photoAutoID).removeValue()

        storageReference = Storage.storage().reference()

        storageReference.child("savedPhoto").child("\(photoAutoID).jpg").delete { error in

            if let error = error {

                print(error)

            }
        }

    }

    func fetchPhotos(completion: @escaping ([Photo]) -> ()) {

        reference = Database.database().reference()

        reference.child("savedPhoto").observe(.value, with: { (dataSnapshot) in

            var photos = [Photo]()

            guard let photoInformationArray = dataSnapshot.value as? [String: Any] else { return }

            for (_, value) in photoInformationArray {
            
                guard
                    let photoInformation = value as? [String: Any],
                    let photoPlaceName = photoInformation["placeName"] as? String,
                    let photoUniqueID = photoInformation["uniqueID"] as? String,
                    let photoLatitude = photoInformation["latitude"] as? Double,
                    let photoLongitute = photoInformation["longitute"] as? Double,
                    let photoImageURL = photoInformation["url"] as? String
                    else { return }

                let photo = Photo.init(placeName: photoPlaceName, uniqueID: photoUniqueID, latitude: photoLatitude, longitute: photoLongitute, photoImageURL: photoImageURL)

                photos.append(photo)

            }

            completion(photos)

        })

    }

}
