//
//  ARSnapshotsPhotoAlbumService.swift
//  H.F.AR
//
//  Created by 이주원 on 2018. 6. 1..
//  Copyright © 2018년 Apple. All rights reserved.
//

import Photos
import Localize_Swift

class ARSnapshotsPhotoAlbumService {
    
    static let instance = ARSnapshotsPhotoAlbumService()
    static let albumName = "Home Furnishing AR"
    var assetCollection: PHAssetCollection!
    
    init() {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: ARSnapshotsPhotoAlbumService.albumName)
        }) { success, _ in
            if success {
                self.assetCollection = self.fetchAssetCollectionForAlbum()
            }
        }
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", ARSnapshotsPhotoAlbumService.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let firstObject: AnyObject = collection.firstObject {
            return firstObject as! PHAssetCollection
        }
        return nil
    }
    
    func saveImage(image: UIImage) {
        // If there was an error upstream, skip the save.
        if assetCollection == nil {
            NotificationCenter.default.post(name: NOTIF_SHOW_MESSAGE, object: "Saving Screenshot is FAILED. Please try again.".localized())
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            albumChangeRequest?.addAssets([assetPlaceholder ?? PHObjectPlaceholder()] as NSArray)
        }, completionHandler: nil)
        NotificationCenter.default.post(name: NOTIF_SHOW_MESSAGE, object: "Saving Screenshot is COMPLETED.".localized())
    }
}
