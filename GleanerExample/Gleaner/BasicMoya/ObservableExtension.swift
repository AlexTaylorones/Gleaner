//
//  Created by Aisino on 2019/4/11.
//  Copyright © 2019 Aisino. All rights reserved.
//
// @class ObservableExtension.swift
// @abstract RX观察者操作
// @discussion RX实现网络请求监听所有数据与状态s逻辑
//

import Foundation

/// 相应服务
public typealias NR = NetworkResponse

// MARK: - 模型观察服务
extension Observable where Element == NR {
    
    /// 完成回调
    public typealias Complete = ((NR) -> Void)?
    
    /// JSON转Model
    ///
    /// - Parameter modelType: 要转换成的model
    /// - Parameter designatedPath: 指定节点解析
    /// - Returns:
    public func mapModel<T: HandyJSON>(_ modelType: T.Type, designatedPath: String! = nil) -> Observable<T> {
        return map { response in
            if response.code == HttpStatus.success.rawValue || response.code == HXCustomSuccessCode {
                /// 成功
                if response.data is [String: Any] {
                    /// 如果是字典
                    guard let dic = response.data as? [String: Any] else {
                        throw APIError.SingleFailedNormal(error: "模型转换失败: data ==> Model 格式错误")
                    }
                    
                    if (designatedPath != nil) && dic.keys.contains(designatedPath) {
                        guard let targetDic: [String: Any] = dic[designatedPath!] as? [String: Any] else {
                            throw APIError.SingleFailedNormal(error: "模型转换失败: data ==> String 节点:\(String(describing: designatedPath))")
                        }
                        
                        guard let model = T.deserialize(from: targetDic) else {
                            throw APIError.SingleFailedNormal(error: "模型转换失败: data.\(designatedPath.description) ==> Model")
                        }
                        return model
                    } else {
                        guard let model = T.deserialize(from: response.data as? [String: Any]) else {
                            throw APIError.SingleFailedNormal(error: "模型转换失败: data ==> Model")
                        }
                        return model
                    }
                }
                if response.data is String {
                    /// 如果是字符串
                    guard let string = T.deserialize(from: response.data as? String) else {
                        throw APIError.SingleFailedNormal(error: response.data as? String ?? "")
                    }
                    return string
                } else {
                    throw APIError.SingleFailedNormal(error: "data格式错误(预期 json字典/String)")
                }
            } else {
                /// 直接输出错误
                guard let errorMsg = response.errorMsg else {
                    throw APIError.SingleOperationFailure(resultCode: response.code,
                                                          resultMsg: response.message)
                }
                throw APIError.SingleOperationFailure(resultCode: response.code,
                                                      resultMsg: errorMsg)
            }
            }.showError()
    }
    
    /// JSON转String
    ///
    /// - Parameter designatedPath: 指定节点
    ///             treatAsError: 指定节点字段值用作错误提示
    /// - Returns: data字符串
    public func mapString(designatedPath: String! = nil, treatAsError: Bool = false) -> Observable<String> {
        return map { response in
            if response.code == HttpStatus.success.rawValue || response.code == HXCustomSuccessCode {
                /// 成功
                if response.data is String {
                    /// 如果是字符串
                    guard let string = response.data as? String else {
                        throw APIError.SingleFailedNormal(error: "模型转换失败: data ==> String")
                    }
                    return string
                }
                if response.data is [String: Any] {
                    /// 如果是字典
                    let dic = response.data as! [String: Any]
                    
                    if (designatedPath != nil) && dic.keys.contains(designatedPath) {
                        guard let string: String = (dic[designatedPath] as? String) else {
                            throw APIError.SingleFailedNormal(error: "模型转换失败: data ==> String 节点:\(String(describing: designatedPath))")
                        }
                        
                        //指定节点字段值用作错误提示
                        if treatAsError {
                            guard let errorMsg: String = (dic[designatedPath] as? String) else {
                                throw APIError.SingleOperationFailure(resultCode: 0, resultMsg: dic.description)
                            }
                            throw APIError.SingleOperationFailure(resultCode: 0, resultMsg: errorMsg)
                        } else {
                            return string
                        }
                    } else {
                        print("指定节点\(String(describing: designatedPath?.description))不存在:\(dic.description)")
                        return dic.description
                    }
                } else {
                    throw APIError.SingleFailedNormal(error: "data格式错误:预期 String 或 字典")
                }
            } else {
                /// 直接输出错误
                guard let errorMsg = response.errorMsg else {
                    throw APIError.SingleOperationFailure(resultCode: response.code,
                                                          resultMsg: response.message)
                }
                throw APIError.SingleOperationFailure(resultCode: response.code,
                                                      resultMsg: errorMsg)
            }
            }.showError()
    }
    
    /// JSON转Model数组
    ///
    /// - Parameters:
    ///   - modelType: 要转换成的model类型
    ///   - designatedPath: 指定节点解析,例如 data.records;默认nil,转换data字段值
    /// - Returns: Model数组
    public func mapModels<T: HandyJSON>(_ modelType: T.Type, designatedPath: String! = nil) -> Observable<[T]> {
        return map { response in
            if response.code == HttpStatus.success.rawValue || response.code == HXCustomSuccessCode {
                // 必须为字典或者数组
                if (response.data is [String: Any]) || (response.data is [[String: Any]]) {
                    if (designatedPath != nil) {
                        guard let models = [T].deserialize(from: response.dataString, designatedPath: designatedPath) as? [T] else {
                                throw APIError.SingleFailedNormal(error: "模型转换失败: data.\(designatedPath!) ==> Model数组")
                        }
                        return models
                    } else {
                        guard let models = [T].deserialize(from: response.data as? [[String: Any]]) as? [T] else {
                                throw APIError.SingleFailedNormal(error: "模型转换失败: data ==> Model数组")
                        }
                        return models
                    }
                } else {
                    throw APIError.SingleFailedNormal(error: "data格式错误:预期 json数组,字典")
                }
            } else {
                /// 直接输出错误
                guard let errorMsg = response.errorMsg else {
                    throw APIError.SingleOperationFailure(resultCode: response.code,
                                                          resultMsg: response.message)
                }
                throw APIError.SingleOperationFailure(resultCode: response.code,
                                                      resultMsg: errorMsg)
            }
            }.showError()
    }
    
    
    // MARK: - ========以下暂时不用==========
    
    /// JSON转Model或Model数组
    ///
    /// - Parameters:
    ///   - modelType: 要转换成的model
    ///   - completeModels: model数组
    ///   - completeModel: model
    /// - Returns:
    public func JSON2Model<T: HandyJSON>(_ modelType: T.Type, completeModels: (([T]) -> Void)? = nil, completeModel: ((T) -> Void)? = nil) -> Observable<NR> {
        
        return map { response in
            if response.code == HttpStatus.success.rawValue || response.code == HXCustomSuccessCode {
                /// 成功
                if response.data is [String: Any] {
                    /// 如果是字典
                    guard let model = T.deserialize(from: response.data as? [String: Any]) else {
                            throw APIError.SingleFailedNormal(error: "数据解析失败")
                    }
                    completeModel?(model)
                    return response
                } else if response.data is [[String: Any]] {
                    /// 如果是数组
                    guard let models = [T].deserialize(from: response.data as? [[String: Any]]) as? [T] else {
                            throw APIError.SingleFailedNormal(error: "数据解析失败")
                    }
                    completeModels?(models)
                    return response
                } else {
                    throw APIError.SingleFailedNormal(error: "无数据")
                }
                
            } else {
                /// 直接输出错误
                guard let errorMsg = response.errorMsg else {
                    throw APIError.SingleOperationFailure(resultCode: response.code,
                                                          resultMsg: response.message)
                }
                throw APIError.SingleOperationFailure(resultCode: response.code,
                                                      resultMsg: errorMsg)
            }
            }.showError()
    }
    
    
    /// 成功
    ///
    /// - Parameter complete: 成功的闭包
    /// - Returns: 
    public func isSuccess(_ complete: Complete) -> Observable<NR> {
        return map { response in
            if response.code == HttpStatus.success.rawValue || response.code == HXCustomSuccessCode {
                complete?(response)
                return response
            } else {
                /// 直接输出错误
                guard let errorMsg = response.errorMsg else {
                    throw APIError.SingleOperationFailure(resultCode: response.code,
                                                          resultMsg: response.message)
                }
                throw APIError.SingleOperationFailure(resultCode: response.code,
                                                      resultMsg: errorMsg)
            }
            }.showError()
    }
    
    
    /// 过滤失败
    ///
    /// - Parameter complete: 失败的闭包
    /// - Returns:
    public func filterFailure(_ complete: Complete) -> Observable<NR> {
        return map { response in
            /// 登录接口没有code.需要特殊处理
            if response.access_token != nil {
                return response
            }
            
            if response.code == HttpStatus.success.rawValue || response.code == HXCustomSuccessCode {
                return response
            } else {
                /// 直接输出错误
                guard let errorMsg = response.errorMsg else {
                    let res = NR(code: response.code,
                                 message: response.message,
                                 data: response.data,
                                 error: response.error != nil
                                    ? response.error
                                    : APIError.SingleOperationFailure(resultCode: response.code,
                                                                      resultMsg: response.message))
                    complete?(res)
                    throw res.error!
                }
                let res = NR(code: response.code,
                             message: response.message,
                             data: response.data,
                             error: response.error != nil
                                ? response.error
                                : APIError.SingleOperationFailure(resultCode: response.code,
                                                                  resultMsg: errorMsg))
                complete?(res)
                throw res.error!
            }
            }.showError()
    }
    
}

// MARK: - 错误观察服务
extension Observable {
    
    /// 输出error
    private func showError() -> Observable<Element> {
        return self.do(onError: { (error) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
//                print("Observable.showError:\(error.APIErrorMsg())")
            }
        })
    }
    
}

// MARK: - Map观察服务
extension Observable where Element: HandyJSON {
    
    /// 转dataSource
    ///
    /// - Parameter text: 一般为空或section的header
    /// - Returns:
    public func mapSectionModel(_ text: String) -> Observable<[SectionModel<String, Element>]> {
        return map { model in
            return [SectionModel(model: text, items: [model])]
        }
    }
    
}

// MARK: - Data观察服务
extension Observable {
    
    /// 转dataSource
    ///
    /// - Parameters:
    ///   - text: String或[String],决定返回的是一个section还是多个section
    ///   - type: 由于是E是数组, 所以需要传入model的类型
    /// - Returns:
    public func mapSectionModel<T: HandyJSON>(_ text: Any, type: T.Type) -> Observable<[SectionModel<String, T>]> {
        return map { models in
            guard let models = models as? [T] else {
                return [SectionModel(model: "", items: [])]
            }
            
            if let text = text as? String {
                return [SectionModel(model: text, items: models)]
            }
            
            if let text = text as? [String] {
                
                var array = [SectionModel<String, T>]()
                
                for (index, value) in models.enumerated() {
                    var str = ""
                    if text.count - 1 < index {
                        str = text.last ?? ""
                    } else {
                        str = text[index]
                    }
                    array.append(SectionModel(model: str, items: [value]))
                }
                return array
            }
            
            return [SectionModel(model: "", items: [])]
        }
    }
}

// MARK: - 绑定选择器观察服务
extension Observable {
    
    /// 绑定选择器
    ///
    /// - Parameter sel: 选择器
    /// - Returns: 观察者对象
    public func bindToSelector(sel: Selector) -> Observable {
        return map { element in
            return element
        }
    }
    
}


