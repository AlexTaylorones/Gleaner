//
//  AINetworkModel.swift
//  GleanerExample
//
//  Created by 李盛安 on 2019/11/14.
//  Copyright © 2019 Aisino. All rights reserved.
//

import UIKit

enum AINetworkType {
    case normal
    case webview
}

enum AINetworkWebViewStatus: String {
    case success = "Success"
    case failed = "Failed"
}

var AINetworkDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSS"
    return dateFormatter
}()

var AINetworkListDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "hh:mm:ss"
    return dateFormatter
}()

class AINetworkModel: NSObject {
    ///< 类型
    var type = AINetworkType.normal
    
    ///< 返回码
    var statusCode = "!!!"
    
    ///< 请求类型
    var httpMethod = "-"
    
    ///< URL地址
    var _url: URL!
    var url: URL! {
        set {
            _url = newValue
            
            scheme = newValue?.scheme ?? ""
            host = newValue?.host ?? ""
            port = newValue?.port ?? 0
            path = newValue?.path ?? ""
            query = newValue?.query ?? ""
        }
        get {
            return _url
        }
    }
    
    ///< 传输协议
    var scheme = "-"
    
    ///< 主机地址
    var host = "-"
    
    ///< 端口号
    var port = 0
    
    ///< 绝对路径
    var path = "-"
    
    ///< Query
    var query = "-"
    
    ///< 请求时间
    var requestTime = Date()
    
    ///< 返回时间
    var responseTime = Date()
    
    ///< 耗时ms
    var duration = 0
    
    ///< 请求的大小
    var requestsSize = 0
    
    ///< 返回的大小
    var responseSize = 0
    
    ///< status
    var status = "-"
    
    ///< 返回数据
    var responseJson = ""
    
    ///< Accept
    var accept = "-"
    
    ///< requestAllHTTPHeaderFields
    var requestAllHTTPHeaderFields: [[String: String]] = [[:]]
    
    ///< responseAllHTTPHeaderFields
    var responseAllHTTPHeaderFields: [[String: String]] = [[:]]
    
    ///< target
    var requestTarget = ""
    
    ///< Date
    var date = "-"
    
    ///< SSL
    var ssl = "NO"
    
    override var description: String {
        return type == AINetworkType.normal ? getNormalDescription() : getWebViewDescription()
    }
    
    func getNormalDescription() -> String {
        /// requestAllHTTPHeaderFields
        var requestAll = [String]()
        if requestAllHTTPHeaderFields.count > 0 {
            for index in 0...requestAllHTTPHeaderFields.count-1 {
                let dicTemp = requestAllHTTPHeaderFields[index]
                requestAll.append("\(dicTemp.keys.first ?? ""): \(dicTemp.values.first ?? "")")
            }
        }
        
        /// responseAllHTTPHeaderFields
        var responseAll = [String]()
        if responseAllHTTPHeaderFields.count > 0 {
            for index in 0...responseAllHTTPHeaderFields.count-1 {
                let dicTemp = responseAllHTTPHeaderFields[index]
                responseAll.append("\(dicTemp.keys.first ?? ""): \(dicTemp.values.first ?? "")")
            }
        }
        
        /// overview
        let overviewArray = [
            "",
            "URL: \(url!)",
            "Method: \(httpMethod)",
            "Protocol: \(scheme)",
            "Status: \(status)",
            "Response: \(statusCode)",
            "SSL: \(ssl)",
            "",
            "Request time: \(AINetworkDateFormatter.string(from: requestTime))",
            "Response time: \(AINetworkDateFormatter.string(from: responseTime))",
            "Duration: \(duration) ms",
            "",
            "Request size: \(requestsSize) B",
            "Response size: \(responseSize) B",
            "Total size: \(requestsSize + responseSize) B",
            ""
        ]
        
        /// request
        let requestArray = ["---------- Request ----------", ""] + requestAll + ["", "\(requestTarget)", ""]
        
        /// response
        let responseArray = ["---------- Response ----------", ""] + responseAll + ["", "\(responseJson)", ""]
        
        /// descriptionArray
        let descriptionArray = overviewArray + requestArray + responseArray
        
        return descriptionArray.joined(separator: "\n")
    }
    
    func getWebViewDescription() -> String {
        /// overview
        let overviewArray = [
            "",
            "URL: \(url!)",
            "Protocol: \(scheme)",
            "Status: \(status)",
            "",
            "Request time: \(AINetworkDateFormatter.string(from: requestTime))",
            "Response time: \(AINetworkDateFormatter.string(from: responseTime))",
            "Duration: \(duration) ms",
            ""
        ]
        
        return overviewArray.joined(separator: "\n")
    }
}
