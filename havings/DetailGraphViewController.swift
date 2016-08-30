//
//  DetailGraphViewController.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/06/09.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import UIKit
import Charts
import GoogleMobileAds

class DetailGraphViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChartViewDelegate, BannerUtil {

    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var activityTableView: UITableView!
    
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var activityTableHeightConstraint: NSLayoutConstraint!
    var countData: [CountDataEntity]?
    var rowsBySection: [Int] = []
    var xIndexBySection: [Int] = []
    var itemName: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityTableView.registerNib(UINib(nibName: "ActivityTableViewCellHeader", bundle: nil), forCellReuseIdentifier: "activityHeader")
        activityTableView.registerNib(UINib(nibName: "ActivityTableViewCell", bundle: nil), forCellReuseIdentifier: "activity")
        activityTableView.delegate = self
        activityTableView.dataSource = self
        activityTableView.estimatedRowHeight = 50
        activityTableView.rowHeight = UITableViewAutomaticDimension

        if self.countData != nil && !self.countData!.isEmpty {
            let data = GraphRenderer.appendTodaysData(self.countData!)
            self.countData = data
            setRowsBySection(data)
            
            let start = data.first!.date!
            let end = data.last!.date!
            chartView.descriptionText = String(format: NSLocalizedString("Prompt.Item.Graph.Period", comment: ""), DateTimeFormatter.getStrFromDate(start, format: DateTimeFormatter.formatYMD), DateTimeFormatter.getStrFromDate(end, format: DateTimeFormatter.formatYMD))
        }else{
            chartView.noDataText = NSLocalizedString("Prompt.Item.Graph.Empty", comment: "")
        }
        
        if let name = self.itemName {
            self.title = name
        }
        
        chartView.pinchZoomEnabled = true
        chartView.dragEnabled = true
        chartView.drawBordersEnabled = true
        chartView.delegate = self

        let marker = BalloonMarker(color: UIColorUtil.mainColor, font: UIFont.systemFontOfSize(UIFont.systemFontSize()), insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        chartView.marker = marker
        
        let right = chartView.getAxis(ChartYAxis.AxisDependency.Right)
        right.drawLabelsEnabled = false
        let left = chartView.getAxis(ChartYAxis.AxisDependency.Left)
        left.valueFormatter = DoubleToIntFormatter()
        
        if self.countData != nil {
            let lineChartData = GraphRenderer.createChartData(self.countData!)
            
            chartView.data = lineChartData.0
            self.xIndexBySection = lineChartData.1
            
            print(self.xIndexBySection)
        }else{
            activityTableView.hidden = true
            activityTableHeightConstraint.constant = 0
        }
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        showAd(bannerView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tapSectionHeader(sender: UIGestureRecognizer){
        print("tap header")
        if let section: Int = sender.view?.tag {
            highlightValueBySection(section)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = self.countData, let c = data[data.count - 1 - section].events?.count else{
            return 0
        }
        
        return c
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = activityTableView.dequeueReusableCellWithIdentifier("activityHeader")! as! ActivityTableViewCellHeader
        
        guard let c = countData?.count, let cd = countData?[c - 1 - section] else {
            print("header nil!!")
            return nil
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(DetailGraphViewController.tapSectionHeader(_:)))
        cell.addGestureRecognizer(gesture)
        cell.tag = section
        cell.setHeader(cd.date!, count: cd.count!)
        return cell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = activityTableView.dequeueReusableCellWithIdentifier("activity")! as! ActivityTableViewCell
        guard let c = countData?.count, let cd = countData?[c - 1 - indexPath.section], let e = cd.events?[indexPath.row] else {
            print("row nil!!")
            
            return cell
        }
        
        cell.vc = self.navigationController
        cell.setData(e)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        highlightValueBySection(indexPath.section)
        activityTableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.rowsBySection.count
    }
    
    func highlightValueBySection(section: Int){
        let xindex = xIndexBySection.count - 1 - section
        print("tap cell \(xindex), xIndexBySection[xindex]")
        chartView.highlightValue(xIndex: xIndexBySection[xindex], dataSetIndex: 0)
    }
 
    func setRowsBySection(data: [CountDataEntity]){
        if data.isEmpty {
            self.rowsBySection = []
            return
        }
        
        self.rowsBySection = data.map {
            return $0.events?.count ?? 0
        }
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        print("selected")
        print(entry)
        if let dataIndex = xIndexBySection.indexOf(entry.xIndex) {
            print("dataIndex \(dataIndex)")
            let ip = NSIndexPath(forRow: NSNotFound, inSection: self.xIndexBySection.count - 1 - dataIndex)
            
            self.activityTableView.scrollToRowAtIndexPath(ip, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }
    

}

public class BalloonMarker: ChartMarker
{
    public var color: UIColor?
    public var arrowSize = CGSize(width: 15, height: 11)
    public var font: UIFont?
    public var insets = UIEdgeInsets()
    public var minimumSize = CGSize()
    
    private var labelns: NSString?
    private var _labelSize: CGSize = CGSize()
    private var _size: CGSize = CGSize()
    private var _paragraphStyle: NSMutableParagraphStyle?
    private var _drawAttributes = [String : AnyObject]()
    
    public init(color: UIColor, font: UIFont, insets: UIEdgeInsets)
    {
        super.init()
        
        self.color = color
        self.font = font
        self.insets = insets
        
        _paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .Center
    }
    
    public override var size: CGSize { return _size; }
    
    public override func draw(context context: CGContext, point: CGPoint)
    {
        if (labelns == nil)
        {
            return
        }
        
        let offset = self.offsetForDrawingAtPos(point)
        
        var rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: point.y + offset.y),
            size: _size)
        rect.origin.x -= _size.width / 2.0
        rect.origin.y -= _size.height
        
        CGContextSaveGState(context)
        
        CGContextSetFillColorWithColor(context, color?.CGColor)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context,
                             rect.origin.x,
                             rect.origin.y)
        CGContextAddLineToPoint(context,
                                rect.origin.x + rect.size.width,
                                rect.origin.y)
        CGContextAddLineToPoint(context,
                                rect.origin.x + rect.size.width,
                                rect.origin.y + rect.size.height - arrowSize.height)
        CGContextAddLineToPoint(context,
                                rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
                                rect.origin.y + rect.size.height - arrowSize.height)
        CGContextAddLineToPoint(context,
                                rect.origin.x + rect.size.width / 2.0,
                                rect.origin.y + rect.size.height)
        CGContextAddLineToPoint(context,
                                rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
                                rect.origin.y + rect.size.height - arrowSize.height)
        CGContextAddLineToPoint(context,
                                rect.origin.x,
                                rect.origin.y + rect.size.height - arrowSize.height)
        CGContextAddLineToPoint(context,
                                rect.origin.x,
                                rect.origin.y)
        CGContextFillPath(context)
        
        rect.origin.y += self.insets.top
        rect.size.height -= self.insets.top + self.insets.bottom
        
        UIGraphicsPushContext(context)
        
        labelns?.drawInRect(rect, withAttributes: _drawAttributes)
        
        UIGraphicsPopContext()
        
        CGContextRestoreGState(context)
    }
    
    public override func refreshContent(entry entry: ChartDataEntry, highlight: ChartHighlight)
    {
        let label = Int(entry.value).description
        labelns = label as NSString
        
        _drawAttributes.removeAll()
        _drawAttributes[NSFontAttributeName] = self.font
        _drawAttributes[NSParagraphStyleAttributeName] = _paragraphStyle
        _drawAttributes[NSForegroundColorAttributeName] = UIColorUtil.accentColor
        
        _labelSize = labelns?.sizeWithAttributes(_drawAttributes) ?? CGSizeZero
        _size.width = _labelSize.width + self.insets.left + self.insets.right
        _size.height = _labelSize.height + self.insets.top + self.insets.bottom
        _size.width = max(minimumSize.width, _size.width)
        _size.height = max(minimumSize.height, _size.height)
    }
}
