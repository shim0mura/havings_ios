//
//  ImagePickable.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/29.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//
// http://qiita.com/sagaraya/items/5e73501ff7a3f0c502c0

import Foundation
import QBImagePicker

protocol ImagePickable: QBImagePickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    weak var imageCollectionView: UICollectionView! {get set}
    var currentDate: NSDate {get set}
    var item: ItemEntity {get set}
}

extension ImagePickable where Self: UIViewController {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("camera finished!!")
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(AddFormViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        print("saved")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        if error != nil {
            print(error.code)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("camera cancel!!")
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func qb_imagePickerController(imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        print("finish gallery!!")
        
        let manager: PHImageManager = PHImageManager()
        let option = PHImageRequestOptions()
        option.synchronous = true
        option.resizeMode = .Fast
        for asset in assets {
            print(asset)
            if let aset = asset as? PHAsset {
                manager.requestImageForAsset(aset,
                                             targetSize: CGSize(width: 800, height: 800),
                                             contentMode: .AspectFit, options: option) {
                                                image, info in
                                                print("UIImage get!")
                                                print(image)
                                                if let i = image {
                                                    self.addImageEntity(i)
                                                }
                                                print("add image!!")
                }
            }
        }
        self.imageCollectionView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func qb_imagePickerControllerDidCancel(imagePickerController: QBImagePickerController!) {
        print("gallery cancel!!")
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func addImageEntity(image: UIImage){
        let itemImage = ItemImageEntity()
        itemImage.imageByUIImage = image
        itemImage.addedDate = currentDate
        itemImage.setBase64Data()
        if self.item.imageDataForPost == nil {
            self.item.imageDataForPost = [itemImage]
        }else{
            self.item.imageDataForPost!.append(itemImage)
        }
    }
    
}