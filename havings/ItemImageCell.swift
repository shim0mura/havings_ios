//
//  ItemImageCell.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/04.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class ItemImageCell: UITableViewCell {
    
    @IBOutlet weak var itemImage: UIImageView!
    var itemImageEntity: ItemImageEntity?
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // TODO: サイズに合わせる
    // 今のところはcellheightを300にしてるけど、本来はcellの高さを画像のheightに合わせたい
    // (heightが200しか無い画像だったら、cellのheightも200にする)
    // kingfisherのcompletionHandlerの中でtableview.reloadRowAtIndexPathを呼べばいいけど
    // indexPathが動的に変わるしheightもキャッシュしないといけなくてその管理が面倒なので、今は簡易な実装にする
    // 参考：http://codesanswer.com/question/192900-uitableviewcell-height-resize-when-image-is-downloaded
    func setItem(imageEntity: ItemImageEntity){
        //print(itemImage.bounds.height)
        //print(self.bounds.height)
        itemImageEntity = imageEntity
        if let imagePath = itemImageEntity!.url {
            let urlString = ApiManager.getBaseUrl() + imagePath
            itemImage.kf_setImageWithURL(NSURL(string: urlString)!)
        }else{
            itemImage.image = nil
        }
    }

}
