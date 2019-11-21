//
//  AINetworkTool.swift
//  GleanerExample
//
//  Created by 李盛安 on 2019/11/18.
//  Copyright © 2019 Aisino. All rights reserved.
//

import UIKit

class AINetworkTool: NSObject {
    
    /// 富文本
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - content: 内容
    /// - Returns: 富文本
    class func getAttriString(title: String, content: String) -> NSMutableAttributedString {
        var attriString = NSMutableAttributedString(string: "")
        if title == "" {
            return attriString
        }
        attriString = NSMutableAttributedString(string: "\(title): \(content)")
        attriString.addAttribute(.font, value: UIFont.init(name: "Helvetica-Bold", size: 15) ?? UIFont.boldSystemFont(ofSize: 15), range: NSRange.init(location: 0, length: title.count+1))
        return attriString
    }
    
    /// 字节单位格式化
    ///
    /// - Parameter size: Int B
    /// - Returns: 格式化后的字节字符串
    class func getFormetFileSize(size: Int) -> String {
        var sizeResult = ""
        if size < 1024 {
            sizeResult = "\(size) B"
        } else if size < 1048576 {
            sizeResult = "\(size/1024) K"
        } else if size < 1073741824 {
            sizeResult = "\(size/1048576) M"
        } else {
            sizeResult = "\(size/1073741824) G"
        }
        return sizeResult
    }
    
    /// 耗时单位格式化
    ///
    /// - Parameter seconds: 耗时 ms
    /// - Returns: 格式化后的单位字符串
    class func getFormetTime(seconds: Int) -> String {
        var secondsResult = ""
        if seconds < 1000 {
            secondsResult = "\(seconds) ms"
        } else if seconds < 1000 * 60 {
            secondsResult = "\(seconds/1000) s"
        } else {
            secondsResult = "\(seconds/1000/60) m"
        }
        return secondsResult
    }
    
    /// 获取当前控制器
    ///
    /// - Returns: 当前控制器
    class func getCurrentVC() -> UIViewController{
        var vc = UIApplication.shared.keyWindow?.rootViewController
        
        if (vc?.isKind(of: UITabBarController.self))! {
            vc = (vc as! UITabBarController).selectedViewController
            if (vc?.isKind(of: UINavigationController.self))! {
                vc = (vc as! UINavigationController).visibleViewController
            }
        }else if (vc?.isKind(of: UINavigationController.self))! {
            vc = (vc as! UINavigationController).visibleViewController
        }else if ((vc?.presentedViewController) != nil) {
            vc =  vc?.presentedViewController
        }
        
        return vc!
    }
    
    ///  格式化日期字符串
    ///
    /// - Parameter formatStr: 格式
    /// - Returns: 转换后的字符串
    class func transformToString(date: Date, formatStr: String? = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = formatStr!
        formatter.locale = Locale.init(identifier: "zh_Hans_CN")
        formatter.timeZone = TimeZone.init(identifier: "Asia/Shanghai")
        return formatter.string(from: date)
    }
    
    /// 获取UDID 由UUID代替
    ///
    /// - Returns: UDID
    class func getUDIDString() -> String {
        let savedUuidString = AIKeyChainManager.keyChainReadData(identifier: "SavedUUID") as? String
        if savedUuidString != nil {
            return (savedUuidString)!
        }
        
        let uuidRef = CFUUIDCreate(kCFAllocatorDefault)
        let strRef = CFUUIDCreateString(kCFAllocatorDefault, uuidRef)
        let uuidString = (strRef! as String).replacingOccurrences(of: "-", with: "")
        let _ = AIKeyChainManager.keyChainSaveData(data: uuidString as Any, withIdentifier: "SavedUUID")
        
        return uuidString
    }
}

