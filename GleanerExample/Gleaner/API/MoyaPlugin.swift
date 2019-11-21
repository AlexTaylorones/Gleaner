//
//  Created by Aisino on 2019/4/11.
//  Copyright © 2019 Aisino. All rights reserved.
//
// @class MoyaPlugin.swift
// @abstract Moya拓展支持
// @discussion 提供请求Moya操作与服务
//

import Foundation
import UIKit
import Moya
import SwiftyJSON
import Result

/// 超时时间默认20s
let kTimeoutInterval:Double = 20.0

var currentModel = AINetworkModel()

/// Moya插件: 网络请求时显示loading...
public final class SingleShowState: NSObject, PluginType {
    
    /// 在发送之前调用来修改请求
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        request.timeoutInterval = kTimeoutInterval //超时时间
        return request
    }
    
    /// 在通过网络发送请求(或存根)之前立即调用
    public func willSend(_ request: RequestType, target: TargetType) {
        guard target is APIService else { return }
        /// 判断是否需要显示: 网络请求之前，显示对应的进度条
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
    /// 在收到响应之后调用，但是在MoyaProvider调用它的完成处理程序之前调用
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        /// 0.3s后消失：网络请求之后，移除进度条
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }

//        if case .success(let response) = result {
//            /// token过期处理
//            guard let dic: [String : Any] = try? JSONSerialization.jsonObject(with: response.data, options: .mutableLeaves) as? [String : Any] else {
//                UIApplication.shared.keyWindow?.makeToast("请求失败")
//                return
//            }
//
//            if dic.keys.contains("code") {
//                var code: Int = 0
//                /// 登录返回code为String类型,其他接口为Number
//                if dic["code"] is String {
//                    code = (dic["code"] as! String).toInt()
//                } else if dic["code"] is NSNumber {
//                    code = (dic["code"] as! NSNumber).intValue
//                }
//
//                if code == 1999 {
//                    DispatchQueue.main.async {
//                        UIApplication.shared.keyWindow?.makeToast("用户认证失败,请重新登录")
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
//                            let lastIdentity = PlatformConfig.shared.checkLastLoginStatus()
//                            if lastIdentity == .enterprise {
//                                // 进入企业用户非首次登录首页
//                                UIApplication.shared.keyWindow?.rootViewController = EnterpriseLoginController()
//                            } else if lastIdentity == .personal {
//                                // 进入个人用户非首次登录首页
//                                UIApplication.shared.keyWindow?.rootViewController = PersonalLoginController()
//                            } else {
//                                // 进入首次登录界面
//                                UIApplication.shared.keyWindow?.rootViewController = LoginController()
//                            }
//                        })
//                    }
//                } else {
//                    UIApplication.shared.keyWindow?.makeToast(dic["message"] as? String)
//                }
//            }
//        } else {
//            /// 统一处理网络异常
//            if result.error != nil {
//                HXLoading.dismiss()
                UIApplication.shared.keyWindow?.makeToast((result.error?.errorUserInfo["NSLocalizedDescription"]) as? String)
//            }
//        }
    }
    
    /// 调用以在完成之前修改结果
//    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {}
    
}

/// Moya插件: 控制台打印请求的参数和服务器返回的json数据
public final class SLPrintParameterAndJson: NSObject, PluginType {
    
    /// 发生请求
    ///
    /// - Parameters:
    ///   - request: 请求类型
    ///   - target: 目标类型
    public func willSend(_ request: RequestType, target: TargetType) {
        #if DEBUG
        print("""
            发送请求:
            1.API:\n\(request.request?.url?.absoluteString ?? "") -- \(request.request?.httpMethod ?? "")
            2.参数:\n\(NSString(data: (request.request?.httpBody ?? Data()), encoding: String.Encoding.utf8.rawValue) ?? "")
            3.请求头:\n\(target.headers ?? [:])\n<=====
            """)
        
        currentModel = AINetworkModel()
        
        currentModel.url = request.request?.url
        currentModel.httpMethod = request.request?.httpMethod ?? ""
        var arrTemp: [[String: String]] = [[:]]
        for (key, value) in (request.request?.allHTTPHeaderFields)! {
            arrTemp.append([key: value])
        }
        currentModel.requestAllHTTPHeaderFields = arrTemp
        
        currentModel.requestTime = Date()
        
        var arrParameter = [String]()
        for dic in target.task.parameters {
            let title = dic.key
            let content = dic.value
            arrParameter.append("\(title)=\(content)")
        }
        
        currentModel.requestTarget = arrParameter.joined(separator: "&")

        currentModel.requestsSize = request.request?.httpBody?.count ?? 0
        
        #endif
    }
    
    /// 接受数据
    ///
    /// - Parameters:
    ///   - result: 结果
    ///   - target: 目标类型
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        
        #if DEBUG
        switch result {
        case .success(let response):
            do {
                let jsonObiect = try response.mapJSON()
                print("""
                    请求成功:
                    1.API:\n\(response.request?.url?.absoluteString ?? "") -- \(response.request?.httpMethod ?? "")
                    2.参数:\n\(NSString(data: (response.request?.httpBody ?? Data()), encoding: String.Encoding.utf8.rawValue) ?? "")
                    3.请求头:\n\(target.headers ?? [:])
                    4.接口返回:\n\(JSON(jsonObiect))\n<=====
                    """)
            } catch {
                print("""
                    接口异常: -- statusCode:\(response.statusCode)
                    1.API:\n\(response.request?.url?.absoluteString ?? "") -- \(response.request?.httpMethod ?? "")
                    2.参数:\n\(NSString(data: (response.request?.httpBody ?? Data()), encoding: String.Encoding.utf8.rawValue) ?? "")
                    3.请求头:\n\(target.headers ?? [:])
                    4.接口返回:\n\(response.data))\n<=====
                    """)
            }
        case.failure(let error):
            print("""
                \(target) 请求失败: \(error.errorObj ?? NSError()) <=====
                """)
        }
        self.analyezeResponse(result)
        #endif
    }
    
    /// 分析返回数据
    func analyezeResponse(_ result: Result<Response, MoyaError>) {
        /// 返回时间
        currentModel.responseTime = Date()

        switch result {
        case .success(let response):

            /// 状态码
            currentModel.statusCode = "\(response.statusCode)"
            /// 耗时
            currentModel.duration = 0
            /// 大小
            currentModel.responseSize = response.data.count
            /// 返回数据
            do {
                let jsonObiect = try response.mapJSON()
                currentModel.responseJson = "\(JSON(jsonObiect))"
            } catch {}

            /// response allHTTPHeaderFields
            var arrTemp: [[String: String]] = [[:]]
            for (key, value) in (response.response?.allHeaderFields)! {
                arrTemp.append([key as! String : value as! String])
            }
            currentModel.responseAllHTTPHeaderFields = arrTemp
            
            currentModel.status = "Complete"
        case .failure(let error):
            let errorObj = error.errorObj
            currentModel.statusCode = "\(errorObj?.code ?? HttpStatus.unknownError.rawValue)"
            currentModel.status = "Failed"
        }
        
        /// 耗时
        currentModel.duration = Int((Double(currentModel.responseTime.timeIntervalSince1970) - Double(currentModel.requestTime.timeIntervalSince1970)) * 1000)
        
        /// 存入本地
        AINetworkManager.manager.saveModel(currentModel)
    }
    
}

/// 为MoyaError提供扩展方法,解析完整的错误信息
extension MoyaError {
    public var errorObj: NSError? {
        switch self {
        case .imageMapping:
            return NSError(domain: "", code: HttpStatus.unknownError.rawValue, userInfo: [NSLocalizedDescriptionKey : "Failed to map data to an Image."])
        case .jsonMapping:
            return NSError(domain: "", code: HttpStatus.unknownError.rawValue, userInfo: [NSLocalizedDescriptionKey : "Failed to map data to JSON."])
        case .stringMapping:
            return NSError(domain: "", code: HttpStatus.unknownError.rawValue, userInfo: [NSLocalizedDescriptionKey : "Failed to map data to a String."])
        case .objectMapping:
            return NSError(domain: "", code: HttpStatus.unknownError.rawValue, userInfo: [NSLocalizedDescriptionKey : "Failed to map data to a Decodable object."])
        case .encodableMapping:
            return NSError(domain: "", code: HttpStatus.unknownError.rawValue, userInfo: [NSLocalizedDescriptionKey : "Failed to encode Encodable object into data."])
        case .statusCode:
            return NSError(domain: "", code: HttpStatus.unknownError.rawValue, userInfo: [NSLocalizedDescriptionKey : "Status code didn't fall within the given range."])
        case .requestMapping:
            return NSError(domain: "", code: HttpStatus.unknownError.rawValue, userInfo: [NSLocalizedDescriptionKey : "Failed to map Endpoint to a URLRequest."])
        case .parameterEncoding(let error):
            return NSError(domain: "", code: HttpStatus.unknownError.rawValue, userInfo: [NSLocalizedDescriptionKey : "Failed to encode parameters for URLRequest. \(error.localizedDescription)"])
        case .underlying(let error, _):
            return error as NSError
        }
    }
}

extension Task {
    public var parameters: [String: Any] {
        switch self {
        case .requestParameters(let parameters, _):
            return parameters
        default:
            return [:]
        }
    }
}
