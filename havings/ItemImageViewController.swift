//
//  ItemImageViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/09.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import Alamofire

class ItemImageViewController: UIViewController, PostAlertUtil {

    // http://qiita.com/wmoai/items/52b1901e62d28dae9f91
    // http://qiita.com/hanoopy/items/7a2c582cd9758e7a3076
    @IBOutlet weak var scrollView: UIScrollView!
    var imageView: UIImageView!
    var itemImageEntity: ItemImageEntity?
    var itemId: Int?
    var itemImageId: Int?
    private var userId: Int = 0
    private var isSending = false
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var favoriteButtonImage: UIImageView!
    @IBOutlet weak var favoritedUsersContainer: UIView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var imageMemoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.favoriteButtonImage.userInteractionEnabled = true
        self.favoritedUsersContainer.userInteractionEnabled = true
        
        self.scrollView.delegate = self
        imageView = UIImageView()
        
        let tokenManager = TokenManager.sharedManager
        if let ui = tokenManager.getUserId() {
            self.userId = ui
        }
        
        if itemImageEntity != nil {
            setImage()
        } else if let itemId = self.itemId, let itemImageId = self.itemImageId where itemImageEntity == nil {
            let spinnerAlert = self.showConnectingSpinner()
            API.call(Endpoint.ItemImage.Get(itemId: itemId, itemImageId: itemImageId)){ response in
                switch response {
                case .Success(let result):
                    
                    spinnerAlert.dismissViewControllerAnimated(false, completion: nil)

                    self.itemImageEntity = result
                    self.setImage()
                    
                case .Failure(let error):
                    print(error)
                    spinnerAlert.dismissViewControllerAnimated(false, completion: nil)
                    self.simpleAlertDialog(NSLocalizedString("Prompt.Item.Image.Notfound", comment: ""), message: nil)
                }
            }
        }

        scrollView.addSubview(imageView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(tap)
        
        self.itemNameLabel.userInteractionEnabled = true
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

    }
    
    private func setImage(){
        if let imagePath = self.itemImageEntity!.url {
            let urlString = ApiManager.getBaseUrl() + imagePath
            self.imageView.kf_setImageWithURL(NSURL(string: urlString)!, placeholderImage: nil)
        }else{
            self.imageView.image = nil
        }
        
        if self.itemImageEntity!.userId == self.userId {
            let imageDeleteNavbarButton = UIBarButtonItem(title: "Delete", style: .Plain, target: self, action: #selector(ItemImageViewController.deleteImage))
            let imageEditNavbarButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(ItemImageViewController.editImageInfo))
            self.navBar.setRightBarButtonItems([imageDeleteNavbarButton, imageEditNavbarButton], animated: true)
        }
        
        if let itemName = self.itemImageEntity?.itemName {
            self.title = String(format: NSLocalizedString("Prompt.Item.Image", comment: ""), itemName)
            self.itemNameLabel.text = itemName
        }else{
            self.itemNameLabel.hidden = true
        }
        
        self.imageLabel.text = String(format: NSLocalizedString("Prompt.Item.Image.AddedAt", comment: ""), DateTimeFormatter.getStrWithWeekday(self.itemImageEntity!.addedDate!))
        self.favoriteCountLabel.text = "\(self.itemImageEntity!.imageFavoriteCount!)"
        self.imageMemoLabel.text = self.itemImageEntity?.memo
    }
    
    func deleteImage(){
        
        let alert: UIAlertController = UIAlertController(title: NSLocalizedString("Prompt.Item.Image.Delete", comment: ""), message: NSLocalizedString("Prompt.Item.Image.Delete.Detail", comment: ""), preferredStyle:  UIAlertControllerStyle.Alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Ok", comment: ""), style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            
            let spinnerAlert = self.showConnectingSpinner()
            
            API.call(Endpoint.ItemImage.Delete(itemId: self.itemImageEntity!.itemId!, itemImageId: self.itemImageEntity!.id!)){ response in
                switch response {
                case .Success(let result):
                    
                    spinnerAlert.dismissViewControllerAnimated(true, completion: {
                        self.dismissViewControllerAnimated(true, completion: nil)
                        print(result)
                        print("success!!")
                    })
                    
                case .Failure(let error):
                    print(error)
                    spinnerAlert.dismissViewControllerAnimated(false, completion: nil)
                    self.simpleAlertDialog(NSLocalizedString("Prompt.FailureToAceess", comment: ""), message: nil)
                }
            }
            
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Prompt.Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func editImageInfo(){
        guard let itemImageEntity = self.itemImageEntity else {
            return
        }
        let storyboard: UIStoryboard = UIStoryboard(name: "Form", bundle: nil)
        let next: ImageDataEditViewController = storyboard.instantiateViewControllerWithIdentifier("image_data_edit") as! ImageDataEditViewController
        next.imageEntity = itemImageEntity
        next.editDelegate = self
        self.presentViewController(next, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let size = imageView.image?.size {
            // imageViewのサイズがscrollView内に収まるように調整
            let wrate = scrollView.frame.width / size.width
            let hrate = scrollView.frame.height / size.height
            let rate = min(wrate, hrate, 1)
            imageView.frame.size = CGSizeMake(size.width * rate, size.height * rate)
            
            // contentSizeを画像サイズに設定
            scrollView.contentSize = imageView.frame.size
            // 初期表示のためcontentInsetを更新
            updateScrollInset()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func tapFavorite(sender: AnyObject) {
        guard let alreadyFavorite = self.itemImageEntity?.isFavorited else {
            return
        }
        guard self.isSending == false else{
            return
        }
        
        let completeHandler = { (response: Result<GenericResult, NSError>) in
            switch response {
            case .Success(let result):
                self.isSending = false
                print(result.errors)
                print(result)
                if let errors = result.errors as? Dictionary<String, AnyObject> {
                    self.showFailedAlert(errors)
                    return
                }else{
                    self.toggleFavoriteState(!alreadyFavorite)
                    self.itemImageEntity!.isFavorited = !alreadyFavorite
                }
            case .Failure(let error):
                self.isSending = false
                print("failure \(error)")
                self.simpleAlertDialog(NSLocalizedString("Prompt.Favorite.Failed", comment: ""), message: nil)
            }
        }
        
        if alreadyFavorite {
            self.isSending = true
            API.call(Endpoint.Favorite.UnFavoriteItemImage(itemImageId: self.itemImageEntity!.id!), completion: completeHandler)
        }else{
            self.isSending = true
            API.call(Endpoint.Favorite.FavoriteItemImage(itemImageId: self.itemImageEntity!.id!), completion: completeHandler)
        }
    }
    
    @IBAction func tapItemName(sender: AnyObject) {
        if let id = self.itemImageEntity?.itemId {
            let storyboard: UIStoryboard = UIStoryboard(name: "Item", bundle: nil)
            let next: ItemViewController = storyboard.instantiateInitialViewController() as! ItemViewController
            next.itemId = id
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
    @IBAction func tapFavoritedUsers(sender: AnyObject) {
        print("favorited users")
        
        let storyboard: UIStoryboard = UIStoryboard(name: "UserList", bundle: nil)
        let next: UserListViewController = storyboard.instantiateInitialViewController() as! UserListViewController
        next.userListStyle = UserListViewController.UserListStyle.ImageFavoritedUser
        next.relatedId = self.itemImageEntity!.id!
        
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    private func toggleFavoriteState(isFavorite: Bool){
        if isFavorite {
            self.favoriteButtonImage.image = UIImage(named: "ic_favorite_pink_300_36dp")
        }else{
            self.favoriteButtonImage.image = UIImage(named: "ic_favorite_border_white_36dp")
        }
    }
    
    private func updateScrollInset() {
        // imageViewの大きさからcontentInsetを再計算
        // なお、0を下回らないようにする
        scrollView.contentInset = UIEdgeInsetsMake(
            max((scrollView.frame.height - imageView.frame.height)/2, 0),
            max((scrollView.frame.width - imageView.frame.width)/2, 0),
            0,
            0
        );
    }
}

extension ItemImageViewController : UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        // ズームのために要指定
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        // ズームのタイミングでcontentInsetを更新
        updateScrollInset()
    }
    
    func doubleTapped(gesture: UITapGestureRecognizer) -> Void {
        
        print(self.scrollView.zoomScale)
        if ( self.scrollView.zoomScale < self.scrollView.maximumZoomScale ) {
            
            let newScale:CGFloat = self.scrollView.zoomScale * 3
            let zoomRect:CGRect = self.zoomRectForScale(newScale, center: gesture.locationInView(gesture.view))
            self.scrollView.zoomToRect(zoomRect, animated: true)
            
        } else {
            self.scrollView.setZoomScale(1.0, animated: true)
        }
    }
    // 領域
    func zoomRectForScale(scale:CGFloat, center: CGPoint) -> CGRect{
        var zoomRect: CGRect = CGRect()
        zoomRect.size.height = self.scrollView.frame.size.height / scale
        zoomRect.size.width = self.scrollView.frame.size.width / scale
        
        zoomRect.origin.x = center.x - zoomRect.size.width / 2.0
        zoomRect.origin.y = center.y - zoomRect.size.height / 2.0
        
        return zoomRect
    }
}

extension ItemImageViewController: ImageDataEditViewDelegate {
    
    func editImageData(imageEntity: ItemImageEntity){
        let spinnerAlert = self.showConnectingSpinner()

        API.call(Endpoint.ItemImage.UpdateMetaData(itemId: self.itemImageEntity!.itemId!, itemImageEntity: self.itemImageEntity!)){ response in
            switch response {
            case .Success(let result):
                self.isSending = false
                print(result)
                spinnerAlert.dismissViewControllerAnimated(false, completion: nil)

            case .Failure(let error):
                print(error)
                spinnerAlert.dismissViewControllerAnimated(false, completion: nil)
                self.simpleAlertDialog(NSLocalizedString("Prompt.FailureToAceess", comment: ""), message: nil)
                
                self.isSending = false
            }
        }
        
    }
}


