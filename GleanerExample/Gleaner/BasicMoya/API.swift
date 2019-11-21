//
//  Created by Aisino on 2019/4/11.
//  Copyright © 2019 Aisino. All rights reserved.
//
// @class API.swift
// @abstract Api请求
// @discussion Resetful Api基本请求返回信息
//

import Foundation
@_exported import HandyJSON
@_exported import RxSwift
@_exported import SwiftyJSON
@_exported import RxDataSources
@_exported import Moya

/// message映射字段
public var HXMessageKey = "msg"
/// 自定义成功返回码,根据平台配置
public var HXCustomSuccessCode: Int? = 200

/// 网络请求返回数据结构
public struct NetworkResponse: HandyJSON {
    
    /// 接口返回状态码
    public var code: Int = -999
    /// 接口返回附加信息
    public var message: String?
    public var errorMsg: String?
    /// 接口返回数据
    public var data: Any?
    
    public var access_token: String?
    public var token_type: String?
    public var userId: String?
    
    /// 接口返回数据部分的jsonString, "{\"data\":XXX}"
    var dataString: String! {
        get {
            let dataDic: [String: Any?] = ["data" : data]
            let dataJson = try! JSONSerialization.data(withJSONObject: dataDic, options: [])
            let jsonString = String(data: dataJson, encoding: String.Encoding.utf8)
            return jsonString!
        }
    }
    
    var error: APIError?
    
    /// Api初始化
    public init() {
        self.init(code: 0, message: nil, data: nil, error: nil)
    }
    
    /// Api初始化
    ///
    /// - Parameters:
    ///   - code: 状态码
    ///   - message: 消息
    ///   - data: 数据
    ///   - error: 错误
    public init(code: Int, message: String?, data: Any?, error: APIError?) {
        self.code = code
        self.message = message
        self.data = data
        self.error = error
    }
    
    public mutating func mapping(mapper: HelpingMapper) {
        // 将json中的msg这个key 转换为message 属性
        // 写法一 mapper <<< self.message <-- "msg"
        // 写法二
        mapper.specify(property: &message, name: HXMessageKey)
        mapper.specify(property: &errorMsg, name: "error")
    }
}

import Alamofire

/// json数组传参
public struct HXJSONArrayEncoding: Alamofire.ParameterEncoding {
    public static let `default` = HXJSONArrayEncoding()
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        
        guard let json = parameters?["jsonArray"] else {
            return request
        }
        
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        request.httpBody = data
        return request
    }
}

/// 各code代表什么
public enum HttpStatus: Int {
    case success = 0000 // 成功
    case logout = 9999 // token过期
    case requestFailed = 300 //网络请求失败
    case noDataOrDataParsingFailed = 301 //无数据或解析失败
    case unknownError = -999 //未知错误
}
