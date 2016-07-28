//
//  ActivityTableViewCell.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/08.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var eventTypeIcon: UIImageView!
    @IBOutlet weak var eventInfo: UILabel!
    @IBOutlet weak var itemThumb: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    
    private var eventEntity: EventEntity?
    var vc: UINavigationController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //let gesture = UITapGestureRecognizer(target: self, action: #selector(DetailGraphViewController.tapSectionHeader(_:)))
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func tapItemName(sender: UIGestureRecognizer){
        guard let item = self.eventEntity?.item, let type = self.eventEntity?.type else {
            return
        }
        
        switch type {
        case .CreateItem, .CreateList, .Dump:
            let storyboard: UIStoryboard = UIStoryboard(name: "Item", bundle: nil)
            let next: ItemViewController = storyboard.instantiateInitialViewController() as! ItemViewController
            next.itemId = item.id!
            self.vc?.pushViewController(next, animated: true)
        case .AddImage:
            if let itemImageId = item.itemImageId {
                let storyboard: UIStoryboard = UIStoryboard(name: "ItemImage", bundle: nil)
                let next: ItemImageViewController = storyboard.instantiateViewControllerWithIdentifier("item_image") as! ItemImageViewController
                next.itemId = item.id!
                next.itemImageId = itemImageId
                self.vc?.pushViewController(next, animated: true)
            }
        default:
            break
        }
        
    }
    
    func setData(event: EventEntity){
        itemName.userInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ActivityTableViewCell.tapItemName(_:)))
        
        itemName.addGestureRecognizer(gesture)
        
        self.eventEntity = event
        
        guard let item = event.item else {
            return
        }
        
        if let eventType = event.type, let name = item.name {
            switch eventType {
            case .CreateList:
                eventInfo.text = NSLocalizedString("Prompt.Item.Graph.Event.CreateList", comment: "")
                eventTypeIcon.image = UIImage(named: "ic_add_list_36dp")
            case .CreateItem:
                eventInfo.text = NSLocalizedString("Prompt.Item.Graph.Event.CreateItem", comment: "")
                eventTypeIcon.image = UIImage(named: "ic_add_item_36dp")
            case .Dump:
                let itemType = (item.isList == true) ? NSLocalizedString("Prompt.List", comment: "") : NSLocalizedString("Prompt.Item", comment: "")
                eventInfo.text = String(format: NSLocalizedString("Prompt.Item.Graph.Event.Dump", comment: ""), itemType)
                eventTypeIcon.image = UIImage(named: "ic_dump_36dp")
            case .AddImage:
                eventInfo.text = String(format: NSLocalizedString("Prompt.Item.Graph.Event.AddImage", comment: ""), name)
                eventTypeIcon.image = UIImage(named: "ic_photo_36dp")
            default:
                eventTypeIcon.image = UIImage(named: "ic_add_item_36dp")
            }
        }

        itemName.text = item.name
        if let userThumbnailPath = item.thumbnail {
            let urlString = ApiManager.getBaseUrl() + userThumbnailPath
            self.itemThumb.kf_setImageWithURL(NSURL(string: urlString)!)
        }else{
            self.itemThumb.image = UIImage(named: "user_thumb")
        }
        
    }
    
}
