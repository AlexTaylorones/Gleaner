//
//  Single_App
//  NetworkingHandler
//
//  Created by iCocos on 2018/12/25.
//  Copyright © 2018年 iCocos. All rights reserved.
//
// @class NetworkingHandler.swift
// @abstract 网络操作
// @discussion 实现基本网络请求和数据逻辑操作
//

import Foundation
import Alamofire

/// 证书配置
public func defaultAlamofireManager() -> Manager {
    return Manager.default
}

/// 网络操作类
public class NetworkingHandler: RequestCacheProtocol {
    
    // 数据缓存有效时间 默认5分钟
    public static var requestCacheValidTime: Int = 5 * 60
    
    /// APIProvider
    static let APIProvider = MoyaProvider<APIService>(manager: defaultAlamofireManager() ,plugins: [SingleShowState(), SLPrintParameterAndJson()])
    
    /// 网络请求
    ///
    /// - Parameter APIService: APIService枚举
    /// - Returns:
    public static func request(_ APIService: APIService) -> Observable<NR> {

        return Observable<NR>.create { (observer) -> Disposable in

            if APIService.cacheData {
                // 从缓存获取数据
                loadDataFromCacheWithTarget(APIService, success: { (response) in
                    
                    observer.onNext(response)
                    observer.onCompleted()
                    
                }, failure: { (error) in
                    observer.onNext(NR(code: HttpStatus.requestFailed.rawValue,
                                       message: nil,
                                       data: nil,
                                       error: APIError.SingleRequestFailed(error: error)))
                    observer.onCompleted()
                })
                return Disposables.create()
            } else {
                
                // 从网络获取数据
                loadDataFromNetworkWithTarget(APIService, success: { (response) in
                    observer.onNext(response)
                    observer.onCompleted()
                }, failure: { (error) in
                    let errorObj = (error as! MoyaError).errorObj!
                    observer.onNext(NR(code: errorObj.code,
                                       message: nil,
                                       data: nil,
                                       error: APIError.SingleOperationFailure(resultCode: errorObj.code, resultMsg: errorObj.domain + " 请求失败,状态码:\(errorObj.code)")))
                    observer.onCompleted()
                })
            }
            
            return Disposables.create()
        }
            //.debug()
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .filterFailure(nil)
    }
    
}

/// 网络检测
public class NetworkStatusManager {
    
    /// 网络状态
    public var networkStatus: NetworkReachabilityManager.NetworkReachabilityStatus = .unknown
    private var manager: NetworkReachabilityManager?
    
    /// 网络请求单例
    public static let shared: NetworkStatusManager = {
        let shared = NetworkStatusManager()
        shared.manager = NetworkReachabilityManager(host: "www.baidu.com")
        return shared
    }()
    private init() {}
    
    /// 开始监测
    public func start() {
        manager?.listener = { [weak self] status in
            self?.networkStatus = status
        }
        manager?.startListening()
    }
    
    /// 监测网络状态
    func checkNetworkStatus() {
        switch networkStatus {
        case .notReachable:
            print("当前网络=====> 无网络连接")
        case .unknown:
            print("当前网络=====> 未知网络")
        case .reachable(.ethernetOrWiFi):
            print("当前网络=====> 以太网或WIFI")
        case .reachable(.wwan):
            print("当前网络=====> 蜂窝移动网络")
        }
    }
    
}
