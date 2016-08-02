//
//  ListImagePickupViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/17.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import QBImagePicker

class ListImagePickupViewController: UIViewController, QBImagePickerControllerDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    var listName: String?
    var listTags: [String]?
    weak var finishDelegate: FinishItemUpdateDelegate?
    
    deinit {
        print("deinit image")
    }
    
    @IBAction func startCamera(sender: AnyObject) {
        print("start camera")
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.cameraCaptureMode = .Photo
            self.presentViewController(picker, animated: true, completion: nil)
        }else{
            let alert :UIAlertController = UIAlertController(title: "カメラ機能を起動できません", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            
            presentViewController(alert, animated: true, completion: nil)
            return
        }
    }
    
    @IBAction func startGallery(sender: AnyObject) {
        print("start gallery")
        let picker = QBImagePickerController()
        picker.delegate = self
        picker.mediaType = QBImagePickerMediaType.Image
        picker.allowsMultipleSelection = true
        picker.showsNumberOfSelectedAssets = true
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Prompt.ListImageChoose", comment: "")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("camera finished!!")
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(AddFormViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        print("saved")
        dismissViewControllerAnimated(true, completion: nil)
        
        
        // TODO: move to form
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        if error != nil {
            print("error")
            print(error.code)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("camera cancel!!")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func qb_imagePickerController(imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        print("finish gallery!!")
        
        let next: AddFormViewController? = self.storyboard?.instantiateViewControllerWithIdentifier("add_form") as? AddFormViewController
        guard let addFormVC = next else {
            return
        }
        
        let currentDate = NSDate()
        let itemEntity = ItemEntity()
        itemEntity.isList = true
        itemEntity.name = self.listName
        itemEntity.tags = self.listTags
        itemEntity.imageDataForPost = []
        
        let manager: PHImageManager = PHImageManager()
        let option = PHImageRequestOptions()
        option.synchronous = true
        option.resizeMode = .Fast
        for asset in assets {
            print(asset)
            if let aset = asset as? PHAsset {
                print(aset.pixelWidth)
                print(aset.pixelHeight)
                manager.requestImageForAsset(aset,
                                     targetSize: CGSize(width: 800, height: 800),
                                     contentMode: .AspectFit, options: option) {
                                        image, info in
                                        print("UIImage get!")
                                        print(image)
                                        let imageEntity = ItemImageEntity()
                                        imageEntity.imageByUIImage = image!
                                        imageEntity.setBase64Data()
                                        imageEntity.addedDate = currentDate
                                        //addFormVC.selectedImages?.append(image!)
                                        //images.append(image!)
                                        itemEntity.imageDataForPost?.append(imageEntity)
                                        print("add image!!")
                }
            }
        }
        //addFormVC.selectedImages = images
        addFormVC.item = itemEntity
        addFormVC.finishDelegate = self.finishDelegate

        
        self.navigationController?.pushViewController(addFormVC, animated: true)

        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func qb_imagePickerControllerDidCancel(imagePickerController: QBImagePickerController!) {
        print("gallery cancel!!")
        dismissViewControllerAnimated(true, completion: nil)
    }

}
