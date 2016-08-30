//
//  BannerUtil.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/08/29.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

protocol BannerUtil: GADBannerViewDelegate {
    
}

extension BannerUtil where Self: UIViewController {
    
    func showAd(bannerView: GADBannerView){
        bannerView.adUnitID = "ca-app-pub-3509309626350343/3809235514"
        bannerView.rootViewController = self
        
        let admobRequest:GADRequest = GADRequest()
        
        
        #if DEBUG
            admobRequest.testDevices = [kGADSimulatorID]
        #elseif STAGING
            admobRequest.testDevices = ["a76fe37a23c9d37fd547b2c57f003950"]
        #else
            admobRequest.testDevices = [kGADSimulatorID]
        #endif
        
        bannerView.loadRequest(admobRequest)
    }
    
}