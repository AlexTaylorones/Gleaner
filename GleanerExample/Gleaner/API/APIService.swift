//
//  Single_App
//  APIService
//
//  Created by iCocos on 2018/12/25.
//  Copyright © 2018年 iCocos. All rights reserved.
//
// @class APIService.swift
// @abstract Api服务
// @discussion Api请求类型与基础服务
//

import Foundation
import Moya
import SwiftyJSON

/// API服务类枚举
///
/// - loadCarBrand: 卡片数据
public enum APIService {
    /// 通用GET请求方式,传入指定的pathComponent和参数
    case getAPI(pathComponent: String ,param: [String: Any], extraHeaders: [String: Any])
    /// 通用POST请求方式
    case postAPI(pathComponent: String ,param: [String: Any], extraHeaders: [String: Any])
    /// 通用PUT请求方式
    case putAPI(pathComponent: String ,param: [String: Any], extraHeaders: [String: Any])
    /// 通用DELETE请求方式
    case deleteAPI(pathComponent: String ,param: [String: Any], extraHeaders: [String: Any])
    /// 通用HEAD请求方式
    case headAPI(pathComponent: String ,param: [String: Any], extraHeaders: [String: Any])
    /// 通用OPTIONS请求方式
    case optionsAPI(pathComponent: String ,param: [String: Any], extraHeaders: [String: Any])
    }


// MARK: - API服务
extension APIService: TargetType {
    /// 基础URL
    public var baseURL: URL {
        let baseUrl = URL(string: BaseURL)!
        // MARK: 通用接口,可传入完整的url(pathComponent)覆盖baseUrl,如无法生成有效的url,仍使用baseUrl
        switch self {
        case .getAPI(let pathComponent, _, _),
             .postAPI(let pathComponent, _, _),
             .deleteAPI(let pathComponent, _, _),
             .putAPI(let pathComponent, _, _),
             .optionsAPI(let pathComponent, _, _),
             .headAPI(let pathComponent, _, _):
            return URL(string: pathComponent, relativeTo: baseUrl) ?? baseUrl
        default:
            return baseUrl
        }
    }

    /// 路径
    public var path: String {
        switch self {
        case .getAPI,
             .postAPI,
             .deleteAPI,
             .putAPI,
             .optionsAPI,
             .headAPI:
            return ""
        }
    }

    /// 方法
    public var method: Moya.Method {
        switch self {
        case .getAPI:
            return .get
        case .postAPI:
            return .post
        case .putAPI:
            return .put
        case .headAPI:
            return .head
        case .optionsAPI:
            return .options
        case .deleteAPI:
            return .delete
        default:
            return .post
        }
    }

    /// 单元测试用
    public var sampleData: Data {
        return "".data(using: .utf8)!
    }

    /// 请求任务
    //░░░░░░░注意:不需要额外参数时,使用default分支即可░░░░░░░░░
    public var task: Task {
        switch self {
            //░░░░░░░通用接口░░░░░░░░░
        default:
            return .requestParameters(parameters: packageParams(parameters),
                                      encoding: parameterEncoding)
        }
    }

    /// 包装参数
    func packageParams(_ content: Any, codecConfig: NetworkCodecConfiguration? = NetworkCodecHelper.shared.config) -> [String: Any] {
        return (codecConfig?.encodeParameters(originParam: content))!
    }
    
    /// 头信息
    public var headers: [String : String]? {
        /// 添加自定义参数
        let fullParam: NSMutableDictionary? = NSMutableDictionary()
        /// 添加默认参数
        fullParam?.addEntries(from: ["Content-Type" : "application/json"])
        return fullParam as? [String : String]
    }
    
    /// 参数编码
    public var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }

    /// 参数 (在parameters 或task 中配置参数,二选一)
    public var parameters: [String: Any] {
        return [:]
    }

    /// 网络请求时是否显示loading...
    public var showStats: Bool {
        return false
    }

    /// 是否缓存结果数据
    public var cacheData: Bool {
        switch self {
        default:
            return false
        }
    }
}

/// 字典转Data
///
/// - Parameter jsonDic: json字典
/// - Returns: jsonData
private func jsonToData(jsonDic: [String: Any]) -> Data? {
    if (!JSONSerialization.isValidJSONObject(jsonDic)) {
        print("is not a valid json object")
        return nil
    }
    //利用自带的json库转换成Data
    //如果设置options为JSONSerialization.WritingOptions.prettyPrinted，则打印格式更好阅读
    let data = try? JSONSerialization.data(withJSONObject: jsonDic, options: [JSONSerialization.WritingOptions.prettyPrinted])
    //Data转换成String打印输出
    let str = String(data:data!, encoding: String.Encoding.utf8)
    //输出json字符串
    print("Json Str:\(str!)")
    return data
}
