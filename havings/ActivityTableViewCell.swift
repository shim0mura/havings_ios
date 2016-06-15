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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //let gesture = UITapGestureRecognizer(target: self, action: #selector(DetailGraphViewController.tapSectionHeader(_:)))
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func tapItemName(sender: UIGestureRecognizer){
        print("tap name")
    }
    
    func setData(event: EventEntity){
        itemName.userInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ActivityTableViewCell.tapItemName(_:)))
        
        itemName.addGestureRecognizer(gesture)
        
        self.eventEntity = event
        
        if let eventType = event.eventType {
            switch eventType {
            case "add_list":
                eventTypeIcon.image = UIImage(named: "ic_add_list_36dp")
            case "dump":
                eventTypeIcon.image = UIImage(named: "ic_dump_36dp")
            case "add_image":
                eventTypeIcon.image = UIImage(named: "ic_photo_36dp")
            default:
                eventTypeIcon.image = UIImage(named: "ic_add_item_36dp")
            }
        }

        eventInfo.text = "\(event.item?.name)あああああああああああああああああああああああああああああああああ"
        itemName.text = event.item?.name
    }
    
}
