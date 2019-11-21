//
//  Created by Aisino on 2019/4/11.
//  Copyright © 2019 Aisino. All rights reserved.
//
// @class APIError.swift
// @abstract Api错误状态
// @discussion 获取和返回请求error详细信息
//

import Foundation

/// APi错误分类枚举
///
/// - SingleRequestFailed//网络请求失败:
/// - SingleOperationFailure//接口返回异常,包含错误码和错误信息
/// - SingleFailedNormal//普通错误,仅返回错误信息
public enum APIError: Swift.Error {
    case SingleRequestFailed(error: Error?) //网络请求失败
    case SingleOperationFailure(resultCode: Int?, resultMsg: String?) //接口返回错误
    case SingleFailedNormal(error: String) //普通失败
}

// MARK: - 输出error详细信息
extension APIError: LocalizedError {
    
    /// 错误描述
    public var descriptionStr: String {
        switch self {
        case .SingleRequestFailed(let error):
            //网络异常,使用系统返回的错误信息(带有本地化)
            if error != nil {
                return (error as NSError?)!.localizedDescription
            } else {
                return "操作失败"
            }
        case .SingleOperationFailure(let resultCode, let resultMsg):
            guard let _ = resultCode, let resultMsg = resultMsg else {
                    return "操作失败"
            }
            //网络正常,接口返回错误,使用返回的errorMsg提示
            return resultMsg
        case .SingleFailedNormal(let error):
            return error
        }
    }
    
}

extension Error {
    /// 错误信息文本
    public func APIErrorMsg() -> String {
        let apiError = self as? APIError
        return (apiError?.descriptionStr.contains("NSURLErrorDomain") as Bool? ?? false) ? "" : (apiError?.descriptionStr ?? "")
    }
}
