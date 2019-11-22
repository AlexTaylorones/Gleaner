//
//  AINetworkManager.swift
//  GleanerExample
//
//  Created by 李盛安 on 2019/11/18.
//  Copyright © 2019 Aisino. All rights reserved.
//

import UIKit

class AINetworkManager: NSObject {
    /// 单例
    public static let manager: AINetworkManager = AINetworkManager()
    
    /// 模型数组
    var localNetModels = [AINetworkModel]()
}

// MARK: - Public
extension AINetworkManager {
    
    /// 存入本地
    ///
    /// - Parameter model: HXNetworkModel
    public func saveModel(_ model: AINetworkModel) {
        localNetModels.insert(model, at: 0)
        // 限制最多200条
        if localNetModels.count == 201 {
            localNetModels.removeLast()
        }
        // 更新
        self.postNotification()
    }
    
    /// 单条移除
    ///
    /// - Parameter _model: HXNetworkModel
    public func removeModel(_ model: AINetworkModel) {
        /// 移除
        for index in 0...localNetModels.count-1 where localNetModels[index] == model {
            localNetModels.remove(at: index)
            break
        }
        // 更新
        self.postNotification()
    }
    
    /// 清除本地模型数组
    public func removeAll() {
        localNetModels.removeAll()
        // 更新
        self.postNotification()
    }
    
    /// 获取本地网络数组
    ///
    /// - Returns: 本地网络数组
    public func getLocalModels() -> [AINetworkModel] {
        return localNetModels
    }
    
    /// 发送通知
    private func postNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"AINetworkManager"), object:nil, userInfo:[:])
    }
}

