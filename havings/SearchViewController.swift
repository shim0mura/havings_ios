//
//  SearchViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/05/26.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    private var searchController = UISearchController(searchResultsController: nil)
    private var defaultTags: [MultiAutoCompleteToken] = []
    private var filteredTags: [MultiAutoCompleteToken] = []
    private let maxSuggest: Int = 3
    private let maxPopularTag: Int = 4
    private let maxPopularList: Int = 4
    
    private let hotTagImageTagBase: Int = 10
    private let hotTagNameTag: Int = 20
    private let hotTagCountTag: Int = 21
    
    private var beforeLoad: Bool = true
    private var isInputText: Bool = false
    private var pickup: PickupEntity?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self

        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.placeholder = "search!!!"
        self.searchController.searchBar.autocapitalizationType = .None
        self.searchController.dimsBackgroundDuringPresentation = false
        self.navigationItem.titleView = self.searchController.searchBar
        self.navigationItem.titleView?.frame = self.searchController.searchBar.frame
        self.navigationController?.navigationBarHidden = false
        
        self.defaultTags = DefaultTagPresenter.getDefaultTags()
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.registerNib(UINib(nibName: "ItemTableViewCell", bundle: nil), forCellReuseIdentifier: "itemCell")
     
        API.call(Endpoint.Pickup.Get) { response in
            switch response {
            case .Success(let result):
                self.pickup = result
                self.beforeLoad = false
                self.tableView.reloadData()
            case .Failure(let error):
                print("failure \(error)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapMoreHotTag(sender: AnyObject) {
        print("more tag")
        let storyboard: UIStoryboard = UIStoryboard(name: "Pickup", bundle: nil)
        let next: PopularTagViewController = storyboard.instantiateViewControllerWithIdentifier("PopularTag") as! PopularTagViewController
        if let pickup = self.pickup {
            next.pickup = pickup
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
    @IBAction func tapMoreList(sender: AnyObject) {
        print("more list")
        let storyboard: UIStoryboard = UIStoryboard(name: "Pickup", bundle: nil)
        let next: PopularListViewController = storyboard.instantiateViewControllerWithIdentifier("PopularList") as! PopularListViewController
        if let pickup = self.pickup {
            next.pickup = pickup
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
    private func toSearchResult(tag: String){
        let storyboard: UIStoryboard = UIStoryboard(name: "SearchResult", bundle: nil)
        let next: SearchResultViewController = storyboard.instantiateViewControllerWithIdentifier("ItemSearch") as! SearchResultViewController
        
        if !tag.isEmpty {
            next.tag = tag
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
    private func toTag(){
    
    }

}

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filteredTags = []
        
        if let target = self.searchController.searchBar.text {
            for_i: for i in self.defaultTags {
                if i.matchToken(target) {
                    self.filteredTags.append(i)
                    if self.filteredTags.count > self.maxSuggest {
                        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
                        break for_i
                    }
                }
            }
        }
        
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.isInputText = true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        print("search!!")
        if let t = searchBar.text {
            self.toSearchResult(t)
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.isInputText = false
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)

    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        if section == 0 {
            return self.filteredTags.count
        }else if section == 1 {
            if self.beforeLoad {
                return 1
            }else{
                return  (self.pickup?.popularTag?.count > self.maxPopularTag) ? self.maxPopularTag : (self.pickup?.popularTag?.count ?? 0)
            }
        }else if section == 2 {
            if self.beforeLoad {
                return 1
            }else{
                return  (self.pickup?.popularList?.count > self.maxPopularList) ? self.maxPopularList : (self.pickup?.popularList?.count ?? 0)
            }
        }else {
            return 0
        }
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let tag = self.filteredTags[indexPath.row]
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
            cell.textLabel?.text = tag.topText
            return cell
        }else if self.beforeLoad {
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("loading")! as UITableViewCell
            return cell

        }else if indexPath.section == 1 {
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("hotTag")! as UITableViewCell

            guard let tagContainer = self.pickup?.popularTag?[indexPath.row] else{
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
            
        }else if indexPath.section == 2 {
            let cell : ItemTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("itemCell") as! ItemTableViewCell
            let item = self.pickup!.popularList![indexPath.row]
            cell.setItem(item)
            return cell
        }else {
            return UITableViewCell(style: .Default, reuseIdentifier: "cell")
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 0: searchの候補
        // 1: 人気のタグ
        // 2: 人気のリスト
        // 3に新着リストとかアイテム入るかも
        return 3
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            if self.isInputText {
                let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("suggestSectionHeader")! as UITableViewCell
                return cell.contentView
            }else{
                return nil
            }

        }else if section == 1 {
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("hotTagHeader")! as UITableViewCell
            return cell.contentView
        }else if section == 2 {
            let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("hotListHeader")! as UITableViewCell
            return cell.contentView
        }else{
            return nil
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("touch!!")
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 && self.isInputText {
            let tag = self.filteredTags[indexPath.row]
            self.toSearchResult(tag.topText)
            
        }else if indexPath.section == 1{
            let container = self.pickup?.popularTag?[indexPath.row]
            if let tag = container?.tagName {
                self.toSearchResult(tag)
            }
        }else if indexPath.section == 2{
            let container = self.pickup?.popularList?[indexPath.row]
            if let id = container?.id {
                let next = UIStoryboard(name: "Item", bundle: nil).instantiateInitialViewController() as! ItemViewController
                next.itemId = id
                self.navigationController?.pushViewController(next, animated: true)
            }
        }
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && !self.isInputText {
            return 0
        }else{
            return 44        
        }
    }
    
}
