//
//  PopularTagViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/07/21.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class PopularTagViewController: UIViewController {

    private let hotTagImageTagBase: Int = 10
    private let hotTagNameTag: Int = 20
    private let hotTagCountTag: Int = 21
    
    @IBOutlet weak var tableView: UITableView!
    var pickup: PickupEntity = PickupEntity()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.title = NSLocalizedString("Prompt.PopularTag", comment: "")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension PopularTagViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return self.pickup.popularTag?.count ?? 0
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        
        // TODO: SearchViewControllerと共通化
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("hotTag")! as UITableViewCell
        
        guard let tagContainer = self.pickup.popularTag?[indexPath.row] else{
            cell.hidden = true
            return cell
        }
        
        let tagName: UILabel = cell.viewWithTag(self.hotTagNameTag) as! UILabel
        let tagCount: UILabel = cell.viewWithTag(self.hotTagCountTag) as! UILabel
        tagName.text = tagContainer.tagName
        let c: Int = tagContainer.tagCount ?? 0
        tagCount.text = String(format: NSLocalizedString("Prompt.PopularTag.Count", comment: ""),
                               String(c))
        let topItemCount: Int = (tagContainer.items?.count > 4) ? 4 : (tagContainer.items?.count ?? 0)
        for i in 0..<topItemCount {
            let item = tagContainer.items![i]
            let thumbnail: UIImageView = cell.viewWithTag(self.hotTagImageTagBase + i) as! UIImageView
            
            if let imagePath = item.thumbnail {
                let urlString = ApiManager.getBaseUrl() + imagePath
                thumbnail.kf_setImageWithURL(NSURL(string: urlString)!)
            }else{
                thumbnail.image = UIImage(named: "ic_photo_36dp")
            }
        }
        
        return cell

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("touch!!")
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let storyboard: UIStoryboard = UIStoryboard(name: "SearchResult", bundle: nil)
        let next: SearchResultViewController = storyboard.instantiateViewControllerWithIdentifier("ItemSearch") as! SearchResultViewController
        
        let container = self.pickup.popularTag?[indexPath.row]
        
        if let tag = container?.tagName {
            next.tag = tag
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
}
