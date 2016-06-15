//
//  ActivityTableViewCellHeader.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/08.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit

class ActivityTableViewCellHeader: UITableViewCell {
    @IBOutlet weak var headerDate: UILabel!
    @IBOutlet weak var itemCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setHeader(date: NSDate, count: Int){
        headerDate.text = DateTimeFormatter.getStrFromDate(date, format: DateTimeFormatter.formatYMD)
        itemCount.text = "\(count)"
    }
    
}
