//
//  AddImageViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/29.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import QBImagePicker

class AddImageViewController: UIViewController, PostAlertUtil {

    var isSending = false
    var item: ItemEntity = ItemEntity()
    let selectedImageTag = 50
    let selectedImageDateTag = 51
    let selectedImageMemoTag = 52
    
    var currentDate = NSDate()
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    weak var finishDelegate: FinishItemUpdateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        
        self.imageCollectionView.emptyDataSetSource = self
        self.imageCollectionView.emptyDataSetDelegate = self
        
        self.title = NSLocalizedString("Prompt.ItemForm.AddImage", comment: "")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func postButton(sender: AnyObject) {
        print("post!!")
        
        if isSending {
            return
        }
        
        guard let images = self.item.imageDataForPost where !images.isEmpty else {
            self.simpleAlertDialog(NSLocalizedString("Prompt.AddImage.NoImage", comment: ""), message: nil)
            return
        }
        guard let itemId = self.item.id else {
            return
        }
        
        self.isSending = true
        let spinnerAlert = self.showConnectingSpinner()
        
        API.call(Endpoint.Item.AddImage(itemId: itemId, item: self.item)){ response in
            switch response {
            case .Success(let result):
                spinnerAlert.dismissViewControllerAnimated(false, completion: nil)
                self.isSending = false
                
                if let errors = result.errors as? Dictionary<String, AnyObject> {
                    self.showFailedAlert(errors)
                    return
                }
                
                self.navigationController?.dismissViewControllerAnimated(true){
                    print("dismiss controller")
                    self.finishDelegate?.finish(String(format: NSLocalizedString("Prompt.AddImage.Success", comment: ""), self.item.name!))
                    self.item.imageDataForPost = nil
                }
            case .Failure(let error):
                print(error)
                spinnerAlert.dismissViewControllerAnimated(false, completion: nil)
                self.simpleAlertDialog(NSLocalizedString("Prompt.FailureToAceess", comment: ""), message: nil)
                
                self.isSending = false
            }
        }
    }
    
    @IBAction func addCameraImage(sender: AnyObject) {
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

    @IBAction func addGalleryImage(sender: AnyObject) {
        print("start gallery")
        let picker = QBImagePickerController()
        picker.delegate = self
        picker.mediaType = QBImagePickerMediaType.Image
        picker.allowsMultipleSelection = true
        picker.showsNumberOfSelectedAssets = true
        
        self.presentViewController(picker, animated: true, completion: nil)
    }

    
}

extension AddImageViewController: ImageDataEditViewDelegate {
    func editImageData(imageEntity: ItemImageEntity){
        self.imageCollectionView.reloadData()
    }
}

// TODO: AddFormViewControllerとの共通化
// imagePickableにいれようとしたけど、よく分からんエラーが出て無理

extension AddImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("listImageCell", forIndexPath: indexPath)
        
        let imageEntity = self.item.imageDataForPost![indexPath.row]
        let imageView: UIImageView = cell.viewWithTag(selectedImageTag) as! UIImageView
        imageView.image = imageEntity.imageByUIImage
        let dateLabel: UILabel = cell.viewWithTag(selectedImageDateTag) as! UILabel
        dateLabel.text = DateTimeFormatter.getStrFromDate(imageEntity.addedDate!, format: DateTimeFormatter.formatYMD)
        let memoLabel: UILabel = cell.viewWithTag(selectedImageMemoTag) as! UILabel
        if let memo = imageEntity.memo {
            memoLabel.text = memo
        }else{
            memoLabel.text = "写真のメモ..."
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(100, 100)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("select!! \(indexPath.row)")
        let actionSheet:UIAlertController = UIAlertController(title: NSLocalizedString("Prompt.Item.Image.AddForm", comment: ""),
                                                              message: nil,
                                                              preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancelAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Cancel", comment: ""),
                                                       style: UIAlertActionStyle.Cancel,
                                                       handler:{
                                                        (action:UIAlertAction!) -> Void in
                                                        print("Cancel")
        })
        
        let defaultAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Item.Image.AddInfo", comment: ""),
                                                        style: UIAlertActionStyle.Default,
                                                        handler:{
                                                            (action:UIAlertAction!) -> Void in
                                                            let next: ImageDataEditViewController? = self.storyboard?.instantiateViewControllerWithIdentifier("image_data_edit") as? ImageDataEditViewController
                                                            if let imageDataEditVC = next {
                                                                imageDataEditVC.imageEntity = self.item.imageDataForPost![indexPath.row]
                                                                imageDataEditVC.editDelegate = self
                                                                self.presentViewController(imageDataEditVC, animated: true, completion: nil)
                                                            }
        })
        
        
        let destructiveAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Item.Image.CancelAdd", comment: ""),
                                                            style: UIAlertActionStyle.Destructive,
                                                            handler:{
                                                                (action:UIAlertAction!) -> Void in
                                                                print("Destructive")
                                                                
                                                                self.item.imageDataForPost!.removeAtIndex(indexPath.row)
                                                                self.imageCollectionView.reloadData()
        })
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(defaultAction)
        actionSheet.addAction(destructiveAction)
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.item.imageDataForPost?.count ?? 0
    }
    
}

extension AddImageViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let image = UIImage(named: "housekeeping")!
        
        let newHeight:CGFloat = 55
        let scale = newHeight / image.size.height
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = NSLocalizedString("Prompt.AddImage.NoImage", comment: "")
        let font = UIFont.systemFontOfSize(16)
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName : UIColor.darkGrayColor()])
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {        
        let itemTypePrompt = (self.item.isList! == true) ? NSLocalizedString("Prompt.List", comment: "") : NSLocalizedString("Prompt.Item", comment: "")
        let text = String(format: NSLocalizedString("Prompt.AddImage.NoImage.Detail", comment: ""), itemTypePrompt)
        let font = UIFont.systemFontOfSize(12)
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName : UIColor.darkGrayColor()])
    }
    
}

// TODO: 共通化
// ImagePickable.swiftにまとめてみたけど、delegateとしてextensionを設定するのはうまくいかないっぽい？
extension AddImageViewController: QBImagePickerControllerDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
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
