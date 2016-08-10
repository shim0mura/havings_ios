//
//  TooltipManager.swift
//  havings
//
//  Created by Tatsuhiko Shimomura on 2016/08/09.
//  Copyright © 2016年 Tatsuhiko Shimomura. All rights reserved.
//

import Foundation
import KeychainAccess
import EasyTipView

class TooltipManager {
    
    enum ShowStatus: String {
        case List = "tooltip_status_list"
        case Item = "tooltip_status_item"
        case Dump = "tooltip_status_dump"
        case Image = "tooltip_status_image"
        case Nomore = "tooltip_status_nomore"
    }
    
    private static let statusKey: String = "tooltip_status"

    static func getToolTip() -> EasyTipView? {
        let keychain = Keychain(service: TokenManager.service)
        let tip: EasyTipView

        do {
            let s : String? = try keychain.getString(statusKey)
            
            if let st = s {
                let status = ShowStatus(rawValue: st)!
                switch status {
                case .List:
                    tip = EasyTipView(text: NSLocalizedString("Prompt.Tooltip.List", comment: ""))
                    tip.backgroundColor = UIColorUtil.accentColor
                    return tip
                case .Item:
                    tip = EasyTipView(text: NSLocalizedString("Prompt.Tooltip.Item", comment: ""))
                    tip.backgroundColor = UIColorUtil.accentColor
                    return tip
                case .Dump:
                    tip = EasyTipView(text: NSLocalizedString("Prompt.Tooltip.Dump", comment: ""))
                    tip.backgroundColor = UIColorUtil.accentColor
                    return tip
                case .Image:
                    tip = EasyTipView(text: NSLocalizedString("Prompt.Tooltip.Image", comment: ""))
                    tip.backgroundColor = UIColorUtil.accentColor
                    return tip
                case .Nomore:
                    return nil
                }
            }else{
                tip = EasyTipView(text: NSLocalizedString("Prompt.Tooltip.List", comment: ""))
                tip.backgroundColor = UIColorUtil.accentColor
                setNextStatus()
                return tip
            }
            
        }catch{
            print("something occured access to keychain in get")
            tip = EasyTipView(text: NSLocalizedString("Prompt.Tooltip.List", comment: ""))
            tip.backgroundColor = UIColorUtil.accentColor
            setNextStatus()
            return tip
        }
    }
    
    static func getStatus() -> String?{
        let keychain = Keychain(service: TokenManager.service)
        do {
            let s : String? = try keychain.getString(statusKey)
            return s
        }catch{
            print("something occured access to keychain in set")
            return nil
        }
    }
    
    static func setNextStatus(){
        let keychain = Keychain(service: TokenManager.service)
        do {
            let s : String? = try keychain.getString(statusKey)
            
            if let st = s, let status = ShowStatus(rawValue: st) {
                keychain[statusKey] = status.rawValue
                print(status.rawValue)
                switch status {
                case .List:
                    keychain[statusKey] = ShowStatus.Item.rawValue
                case .Item:
                    keychain[statusKey] = ShowStatus.Dump.rawValue
                case .Dump:
                    keychain[statusKey] = ShowStatus.Image.rawValue
                case .Image:
                    keychain[statusKey] = ShowStatus.Nomore.rawValue
                case .Nomore:
                    break
                }
            }else{
                keychain[statusKey] = ShowStatus.List.rawValue
            }
            
        }catch{
            print("something occured access to keychain in set")
            keychain[statusKey] = ShowStatus.List.rawValue

        }

    }
    
}