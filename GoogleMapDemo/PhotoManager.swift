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

    func fetchPhotos(completion: @escaping ([Photo]) -> ()) {

        reference = Database.database().reference()

        reference.child("savedPhoto").observe(.value, with: { (dataSnapshot) in

            var photos = [Photo]()

            guard let photoInformationArray = dataSnapshot.value as? [String: Any] else { return }

            for (key, value) in photoInformationArray {
            
                guard
                    let photoInformation = value as? [String: Any],
                    let photoUniqueID = photoInformation["uniqueID"] as? String,
                    let photoLatitude = photoInformation["latitude"] as? Double,
                    let photoLongitute = photoInformation["longitute"] as? Double,
                    let photoImageURL = photoInformation["url"] as? String
                    else { return }

                let photo = Photo.init(uniqueID: photoUniqueID, latitude: photoLatitude, longitute: photoLongitute, photoImageURL: photoImageURL)

                photos.append(photo)

            }

            completion(photos)

        })

    }

}
