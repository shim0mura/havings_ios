//
//  ItemTableCellViewTableViewCell.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/05/31.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell  {
    
    let TAGS = ["Tech", "Design", "Humor", "Travel", "Music", "Writing", "Social Media", "Life", "Education", "Edtech", "Education Reform", "Photography", "Startup", "Poetry", "Women In Tech", "Female Founders", "Business", "Fiction", "Love", "Food"]
    
    //@IBOutlet weak var flowLayout: CollectionViewFlowLayoutLeftAlign!
    //@IBOutlet weak var tagCollection: UICollectionView!
    @IBOutlet weak var itemThumbnail: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    // https://teratail.com/questions/7826
    // tagのcollectionViewのheightだけはpriorityをちょっと下げてる
    //@IBOutlet weak var tagHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagList: TagListView!
    
    var itemEntity: ItemEntity?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //let cellNib = UINib(nibName: "TagCollectionViewCell", bundle: nil)

        /*
        tagCollection.registerNib(cellNib, forCellWithReuseIdentifier: "TagCell")
        tagCollection.delegate = self
        tagCollection.dataSource = self
        tagCollection.backgroundColor = UIColor.clearColor()
        
        print("!!!!")
        print(tagCollection.bounds.size.height)
        print(tagCollection.contentSize.height)

        print("!!!")
        //tagHeightConstraint.constant = 100
        self.sizingCell = (cellNib.instantiateWithOwner(nil, options: nil) as NSArray).firstObject as! TagCollectionViewCell?
        self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        */
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setItem(item: ItemEntity){
        self.itemEntity = item
        itemName.text = itemEntity!.name
        //itemCount.text = "\(itemEntity.id)"
        if let thumbnailPath = itemEntity!.thumbnail {
            let urlString = ApiManager.getBaseUrl() + thumbnailPath
            itemThumbnail.kf_setImageWithURL(NSURL(string: urlString)!)
        }else{
            itemThumbnail.image = nil
        }
        
        tagList.removeAllTags()
        itemEntity?.tags?.forEach {
            tagList.addTag($0)
        }
    }
    
    /*
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return TAGS.count
        return itemEntity?.tags?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TagCell", forIndexPath: indexPath) as! TagCollectionViewCell
        self.configureCell(cell, forIndexPath: indexPath)
        print("xxxx \(indexPath.row)")
        print(tagCollection.contentSize.height)

        // http://stackoverflow.com/questions/20792299/uicollectionview-autosize-height
        //tagHeightConstraint.constant = tagCollection.contentSize.height
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        self.configureCell(self.sizingCell!, forIndexPath: indexPath)
        return self.sizingCell!.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    }
    
    func configureCell(cell: TagCollectionViewCell, forIndexPath indexPath: NSIndexPath) {
        let tag = itemEntity!.tags![indexPath.row]
        cell.tagName.text = tag
    }
    
    func fontt() -> CGFloat{
        print(tagCollection.contentSize.height)
        return tagCollection.contentSize.height
    }
    
    func storeSize(size: CGFloat){
        print("CGflowt \(size)")
        tagHeightConstraint.constant = size
    }
    */
    
}
