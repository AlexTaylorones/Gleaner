//
//  Single_App
//  RequestCacheProtocol
//
//  Created by iCocos on 2018/12/25.
//  Copyright © 2018年 iCocos. All rights reserved.
//
// @class RequestCacheProtocol.swift
// @abstract 请求缓存
// @discussion 网络请求缓存与加载协议
//

import Foundation
import SwiftyJSON
import Moya
import YYCache

/// 请求缓存协议
protocol RequestCacheProtocol {
    
    static var cacheName: String { get }
    /// 从缓存获取数据
    static func loadDataFromCacheWithTarget(_ target: APIService, success: @escaping (NR) -> Void, failure: @escaping (Error?) -> Void)
    
    /// 从网络获取数据
    static func loadDataFromNetworkWithTarget(_ target: APIService, success: @escaping (NR) -> Void, failure: @escaping (Error?) -> Void)

}

// MARK: - 网络请求缓存
extension RequestCacheProtocol where Self: NetworkingHandler {
    
    /// 缓存标识
    static var cacheName: String {
        return "NETWORKDATA"
    }
    
    /// 从缓存获取数据
    ///
    /// - Parameters:
    ///   - target: Api目标服务
    ///   - success: 成功状态
    ///   - failure: 失败状态
    static func loadDataFromCacheWithTarget(_ target: APIService, success: @escaping (NR) -> Void, failure: @escaping (Error?) -> Void) {
        
        let paramsStr = JSON(arrayLiteral: target.parameters).rawString() ?? ""
        let cache_key = String(format: "%@%@%@", target.baseURL.absoluteString, target.path, paramsStr)
        
        guard let cache = YYCache(name: cacheName),
            cache.containsObject(forKey: cache_key),
            let obj = cache.object(forKey: cache_key) as? [String: Any],
            let cache_timeStamp = obj["cache_timeStamp"] as? Int,
            (Int(Date().timeIntervalSince1970) - cache_timeStamp) <= requestCacheValidTime,
            let nr = NR.deserialize(from: obj) else {
                // 没找到数据或数据无效则进行网络请求
                loadDataFromNetworkWithTarget(target, success: success, failure: failure)
                return
        }
        
        success(nr)
        print("""
            从缓存获取到数据=====> \(target)
            =====> \(obj)
            """)
    }
    
    
    /// 从网络获取数据
    ///
    /// - Parameters:
    ///   - target: Api目标服务
    ///   - success: 成功状态
    ///   - failure: 失败状态
    static func loadDataFromNetworkWithTarget(_ target: APIService, success: @escaping (NR) -> Void, failure: @escaping (Error?) -> Void) {
        // 从网络获取数据
        APIProvider.request(target) { (response) in
            switch response {
            case let .success(result):
                // 网络请求成功
                guard let json = try? result.mapJSON(),
                    var dict = json as? [String: Any],
                    let response = NR.deserialize(from: dict)
                    else {
                        // 请求路径
                        let urlPath = target.baseURL.absoluteString + "/\(target.path)"
                        let error = NSError(domain: urlPath, code: result.statusCode, userInfo: [:])
                        failure(MoyaError.underlying(error as Error, nil))
                        return
                }
                success(response)
                
                if target.cacheData {
                    // 更新本地保存的数据
                    let paramsStr = JSON(arrayLiteral: target.parameters).rawString() ?? ""
                    let cache_key = String(format: "%@%@%@", target.baseURL.absoluteString, target.path, paramsStr)
                    
                    guard let cache = YYCache(name: cacheName) else { break }
                    dict["cache_timeStamp"] = Int(Date().timeIntervalSince1970)
                    cache.setObject(dict as NSCoding, forKey: cache_key)
                }
            case let .failure(error):
                // 网络请求失败
                failure(error)
            }
        }
    }
    
}
