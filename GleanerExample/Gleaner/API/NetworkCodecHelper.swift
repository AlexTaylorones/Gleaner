//
//  NetworkCodecHelper.swift
//  elevate
//
//  Created by Aisino on 2019/7/23.
//

import UIKit

/// 头部字段
private let JsonKey_Header = "header"
private let JsonKey_Version = "version"
private let JsonKey_TerminalCode = "terminalCode"
private let JsonKey_RequestUserType = "requestUserType"
private let JsonKey_DeviceId = "deviceId"
private let JsonKey_InterfaceCode = "interfaceCode"
private let JsonKey_TradeSeqr = "tradeSeq"
private let JsonKey_RequestTime = "requestTime"
private let JsonKey_Data = "data"
/// data字段
private let JsonKey_ZipCode = "zipCode"
private let JsonKey_EncryptCode = "encryptCode"
private let JsonKey_HashType = "hashType"
private let JsonKey_Signature = "signature"
private let JsonKey_SymmetricKey = "symmetricKey"
private let JsonKey_Content = "content"
/// 返回content字段
private let JsonKey_ReturnCode = "code"
private let JsonKey_ReturnMsg = "message"
private let JsonKey_Obj = "data"

/// 接口编号枚举
///
/// - login:"001":
public enum InterfaceCode: String {
    /// 登录接口
    case login = "001"
}

/// 用户类型枚举
/// 0企业用户/1个人用户/2税局
/// - login:"001":
public enum UserType: String {
    case enterprise = "0"
    case individual = "1"
    case tax        = "2"
}

/// 报文编码方式配置
public struct NetworkCodecConfiguration {
    /// 0，不压缩；1，gzip压缩
    fileprivate let zipCode: String
    /// 0，不加密；1，AES加密；2，CA证书加密
    fileprivate let encryptCode: String
    /// content hash方式--采用sha256
    fileprivate let hashType: String
    /// content 签名
    fileprivate let signature: String
    /// CA加密的随机密钥
    fileprivate let symmetricKey: String

    /// 接口编码
    public var interfaceCode:String = InterfaceCode.login.rawValue
    /// 用户类型
    public var userType:String = "0"
    
    /// 生成定长随机数字符串
    func createRandomNumStr(lengt: Int, max: UInt32) -> String {
        return String(format: "%0\(lengt)d", Int(arc4random_uniform(max)))
    }
    
    /// 参数编码
    ///
    /// - Parameter originParam:原始入参(data部分)
    /// - Returns: 包装后的参数字典
    func encodeParameters(originParam: Any) -> [String: Any] {
        let packagedParam = NSMutableDictionary()
        
        /// 交易流水号，终端类型标识+请求用户类型+YYYYMMDDHHMMSSSSS+6位随机数
        /// 时间戳(YYYYMMDDHHMMSSSSS)
        let timestamp = "\(u_long(Date().timeIntervalSince1970 * 1000))"
        /// 6位随机数字符串
        let random = createRandomNumStr(lengt: 6, max: 999999)
        /// 请求时间
        let dataString = AINetworkTool.transformToString(date: Date(), formatStr: "yyyy-MM-dd HH:mm:ss")
        
        /// 处理header参数
        packagedParam.addEntries(from: [JsonKey_Header: [
            JsonKey_Version : InterfaceVersion,
            JsonKey_TerminalCode : TerminalCode,
            JsonKey_RequestUserType : userType,
            JsonKey_DeviceId : AINetworkTool.getUDIDString(),
            JsonKey_InterfaceCode : interfaceCode,
            JsonKey_TradeSeqr : TerminalCode + userType + timestamp + random,
            JsonKey_RequestTime : dataString]])
        
        /// 处理content参数
        let encryptParam: Any = originParam
        switch encryptCode {
        case "1":
        // TODO:AES加密
            print("AES加密")
        case "2":
            // TODO:CA证书加密
            print("CA证书加密")
        default:
            print("不加密")
        }
        packagedParam.addEntries(from: [JsonKey_Data: [
            JsonKey_ZipCode : zipCode,
            JsonKey_EncryptCode : encryptCode,
            JsonKey_HashType : hashType,
            JsonKey_Signature : signature,
            JsonKey_SymmetricKey : symmetricKey,
            JsonKey_Content : encryptParam]])
        return packagedParam as! [String : Any]
    }
    
    /// content解码
    ///
    /// - Parameter originJson:服务器返回的原始数据(content部分)
    /// - Returns: 解码后的content
    func decipherContent(originContent: [String: Any]) -> [String: Any] {
        let decodedResponse = NSMutableDictionary()
        
        //TODO: 处理content解密/解压缩
        let decipheredContent: [String: Any] = originContent
        switch encryptCode {
        case "1":
            // TODO:AES加密
            print("AES解密")
        case "2":
            // TODO:CA证书加密
            print("CA证书解密")
        default:
            print("不需要解密")
        }
        /// 返回
        decodedResponse.addEntries(from: decipheredContent)
        return decodedResponse as! [String : Any]
    }
    
    public init(_ zipCode: String, _ encryptCode: String, _ hashType: String, _ signature: String, _ symmetricKey: String) {
        self.init(zipCode: zipCode, encryptCode: encryptCode, hashType: hashType, signature: signature, symmetricKey: symmetricKey)
    }
    
    init(zipCode: String, encryptCode: String, hashType: String, signature: String, symmetricKey: String) {
        self.zipCode = zipCode
        self.encryptCode = encryptCode
        self.hashType = hashType
        self.signature = signature
        self.symmetricKey = symmetricKey
    }
}

/// 网络请求编解码工具类
public class NetworkCodecHelper: NSObject {
    public var config: NetworkCodecConfiguration?
    
    /// 单例
    public static let shared: NetworkCodecHelper = {
        let shared = NetworkCodecHelper()
        shared.config = NetworkCodecConfiguration(zipCode: "0", encryptCode: "0", hashType: "sha256", signature: "", symmetricKey: "")
        return shared
    }()
}

/// 网络请求返回结果处理类
class ResponseResult<T: HandyJSON>: HandyJSON {
    
    required init() { }
    
    var returnCode = ""
    var returnMsg = ""
    var model: T?
    var models: [T]?
    
    fileprivate init(code: String, msg: String, model: T? = nil, models: [T]? = []) {
        self.returnCode = code
        self.returnMsg = msg
        self.model = model
        self.models = models
    }
    
    /// 从json中解码content内容
    public class func decodeFromJson(json: [String: Any]) -> [String: Any] {
        guard let dataDic: [String: Any] = json[JsonKey_Data] as? [String : Any] else {
            return [:]
        }
        /// 从data中解析压缩/解码方式
        let serverZipCode = dataDic[JsonKey_SymmetricKey] as? String ?? ""
        let serverEncryptCode = dataDic[JsonKey_SymmetricKey] as? String ?? ""
        let serverHashType = dataDic[JsonKey_SymmetricKey] as? String ?? ""
        let serverSignature = dataDic[JsonKey_SymmetricKey] as? String ?? ""
        let serverSymmetricKey = dataDic[JsonKey_SymmetricKey] as? String ?? ""
        /// 获取解码方式
        let codecConfig = NetworkCodecConfiguration(zipCode: serverZipCode, encryptCode: serverEncryptCode, hashType: serverHashType, signature: serverSignature, symmetricKey: serverSymmetricKey)
        
        guard let contentDic: [String :Any] = dataDic[JsonKey_Content] as? [String : Any] else {
            return [:]
        }
        
        return codecConfig.decipherContent(originContent: contentDic)
    }
    
    /// JSON转Model
    ///
    /// - Parameter modelType: 要转换成的model
    /// - Parameter designatedPath: 指定节点解析
    /// - Returns:Model
    public class func getModelFromResponse(response: NetworkResponse, _ modelType: T.Type, destinationPath: String? = nil) -> ResponseResult {
        /// content字典
        let contentDic: [String: Any] = decodeFromJson(json: response.toJSON() ?? [:])
        /// obj字典
        let objDic = contentDic[JsonKey_Obj] as? [String : Any] ?? [:]
        /// 返回码
        let code = (contentDic[JsonKey_ReturnCode] as? String) ?? ""
        /// 返回描述
        let msg = (contentDic[JsonKey_ReturnMsg] as? String) ?? ""
        
        if destinationPath == nil {
            /// 对象
            let model = T.deserialize(from: objDic)
            return ResponseResult(code: code, msg: msg, model: model, models: nil)
        } else {
            let dataJson = try! JSONSerialization.data(withJSONObject: contentDic, options: [])
            let jsonString = String(data: dataJson, encoding: String.Encoding.utf8)

            let model = T.deserialize(from: jsonString, designatedPath: destinationPath)
            return ResponseResult(code: code, msg: msg, model: model, models: nil)
        }
    }
    
    /// JSON转Model数组
    ///
    /// - Parameter modelType: 要转换的model类型
    /// - Parameter designatedPath: 指定节点解析
    /// - Returns:Model数组
    public class func getModelsFromResponse(response: NetworkResponse, _ modelType: T.Type, destinationPath: String? = nil) -> ResponseResult {
        /// content字典
        let contentDic: [String: Any] = decodeFromJson(json: response.toJSON() ?? [:])
        /// obj字典
        let objDic = contentDic[JsonKey_Obj] as? [[String : Any]] ?? [[:]]
        /// 返回码
        let code = (contentDic[JsonKey_ReturnCode] as? String) ?? ""
        /// 返回描述
        let msg = (contentDic[JsonKey_ReturnMsg] as? String) ?? ""
        
        if destinationPath == nil {
            /// 对象数组
            let models = [T].deserialize(from: objDic) as? [T]
            return ResponseResult(code: code, msg: msg, model: nil, models: models)
        } else {
            let dataJson = try! JSONSerialization.data(withJSONObject: contentDic, options: [])
            let jsonString = String(data: dataJson, encoding: String.Encoding.utf8)
            
            /// 对象数组
            let models = [T].deserialize(from: jsonString, designatedPath: destinationPath) as? [T]
            return ResponseResult(code: code, msg: msg, model: nil, models: models)
        }
    }
    
    public class func getResponseJson(response: NetworkResponse) -> [String: Any] {
        /// content字典
        let contentDic: [String: Any] = decodeFromJson(json: response.toJSON() ?? [:])
        return contentDic
    }
}
