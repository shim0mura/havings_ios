//
//  ProfileEditViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/18.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import QBImagePicker

class ProfileEditViewController: UIViewController, PostAlertUtil {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var userProfileTextView: UITextView!
    @IBOutlet weak var profileBeforeImage: UIImageView!
    @IBOutlet weak var profileAfterImage: UIImageView!
    
    var userEntity: UserEntity = UserEntity()
    private var imageData: String = ""
    private var isSending: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let spinner = self.showConnectingSpinner()
        self.isSending = true
        self.userProfileTextView.addBottomBorderWithColor(UIColorUtil.borderColor, width: 0.5)
        
        API.call(Endpoint.User.GetSelf) { response in
            spinner.dismissViewControllerAnimated(true, completion: nil)

            switch response {
            case .Success(let result):

                self.userEntity = result
                self.setDefault()
            case .Failure(let error):
                self.dismissViewControllerAnimated(true, completion: {
                    self.simpleAlertDialog(NSLocalizedString("Prompt.ProfileEdit.FailedToGetUserInfo", comment: ""), message: nil)
                })
                print("failure \(error)")
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func setDefault(){
        self.userNameField.text = self.userEntity.name
        self.userProfileTextView.text = self.userEntity.description
        if let imagePath = self.userEntity.image {
            let urlString = ApiManager.getBaseUrl() + imagePath
            self.profileBeforeImage.kf_setImageWithURL(NSURL(string: urlString)!)
            self.profileAfterImage.kf_setImageWithURL(NSURL(string: urlString)!)
        }else{
            //imageView.image = nil
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touch")
        self.userProfileTextView.resignFirstResponder()
    }
    
    
    @IBAction func changeImage(sender: AnyObject) {
        
        let actionSheet:UIAlertController = UIAlertController(title: NSLocalizedString("Prompt.ProfileEdit.UserImage.Change", comment: ""),
                                                              message: nil,
                                                              preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancelAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Cancel", comment: ""),
                                                       style: UIAlertActionStyle.Cancel,
                                                       handler:{
                                                        (action:UIAlertAction!) -> Void in
                                                        print("Cancel")
        })
        
        let cameraAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.ProfileEdit.UserImage.fromCamera", comment: ""),
                                                        style: UIAlertActionStyle.Default,
                                                        handler:{
                                                            (action:UIAlertAction!) -> Void in
                                                                self.startCamera()
        })
        
        
        let galleryAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.ProfileEdit.UserImage.fromGallery", comment: ""),
                                                            style: UIAlertActionStyle.Default,
                                                            handler:{
                                                                (action:UIAlertAction!) -> Void in
                                                                self.startGallery()
        })
        
        let destructAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.ProfileEdit.UserImage.Clear", comment: ""),
                                                        style: UIAlertActionStyle.Destructive,
                                                        handler:{
                                                            (action:UIAlertAction!) -> Void in
                                                            self.imageData = ""
                                                            if let imagePath = self.userEntity.image {
                                                                let urlString = ApiManager.getBaseUrl() + imagePath
                                                                self.profileAfterImage.kf_setImageWithURL(NSURL(string: urlString)!)
                                                            }else{
                                                                //imageView.image = nil
                                                            }
        })
        
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(galleryAction)
        actionSheet.addAction(destructAction)
        presentViewController(actionSheet, animated: true, completion: nil)
        
    }
    
    @IBAction func tapCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func updateProfile(sender: AnyObject) {
        
        guard let name = self.userNameField.text else{
            self.simpleAlertDialog(NSLocalizedString("Prompt.ProfileEdit.UserName.isEmpty", comment: ""), message: nil)
            return
        }
        let user = UserEntity()
        user.name = name
        user.description = self.userProfileTextView.text
        if !self.imageData.isEmpty {
            user.image = self.imageData
        }
        
        let spinner = self.showConnectingSpinner()
        self.isSending = true
        
        API.call(Endpoint.User.ChangeProfile(userEntity: user)) { response in
            spinner.dismissViewControllerAnimated(true, completion: nil)
            
            switch response {
            case .Success(_):
                
                self.dismissViewControllerAnimated(true, completion: nil)
            case .Failure(let error):
                self.simpleAlertDialog(NSLocalizedString("Prompt.FailureToAceess", comment: ""), message: nil)

                
                print("failure \(error)")
            }
        }
        
    }
    
}

extension ProfileEditViewController: QBImagePickerControllerDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    func startCamera(){
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
    
    func startGallery(){
        print("start gallery")
        let picker = QBImagePickerController()
        picker.delegate = self
        picker.mediaType = QBImagePickerMediaType.Image
        picker.allowsMultipleSelection = true
        picker.showsNumberOfSelectedAssets = true
        picker.prompt = NSLocalizedString("Prompt.ProfileEdit.UserImage.Choose", comment: "")
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("camera finished!!")
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(ProfileEditViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
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
                                             targetSize: CGSize(width: 500, height: 500),
                                             contentMode: .AspectFit, options: option) {
                                                image, info in
                                                print("UIImage get!")
                                                print(image)
                                                if let i = image {
                                                    self.changeImageData(i)
                                                }
                                                print("add image!!")
                }
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func qb_imagePickerControllerDidCancel(imagePickerController: QBImagePickerController!) {
        print("gallery cancel!!")
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func changeImageData(image: UIImage){
        
        
        let data:NSData? = UIImageJPEGRepresentation(image, 0.95)
        
        if let jpgData = data {
            
            let encodeString:String = "data:image/jpg;base64," + jpgData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            
            self.imageData = encodeString
            
            self.profileAfterImage.image = image
            
        }else {
            self.simpleAlertDialog(NSLocalizedString("Prompt.ProfileEdit.UserImage.Failed", comment: ""), message: nil)
            
        }
        
    }
    
}
