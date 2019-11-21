//
//  AINetworkDefine.swift
//  GleanerExample
//
//  Created by 李盛安 on 2019/11/18.
//  Copyright © 2019 Aisino. All rights reserved.
//

import Foundation
import UIKit

func RGBCOLOR(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
    return UIColor(red: (r)/255.0, green: (g)/255.0, blue: (b)/255.0, alpha: 1.0)
}

func RGBACOLOR(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {
    return UIColor(red: (r)/255.0, green: (g)/255.0, blue: (b)/255.0, alpha: a)
}

/// BaseURL
let BaseURL = "http://api.m.taobao.com/rest/api3.do"

/// 接口版本号，目前v1.0
let InterfaceVersion = "v1.0"
/// 终端类型标识 0：B/S；1：C/S；2：APP
let TerminalCode = "2"

/// 状态栏高度
let statusBarHeight = UIApplication.shared.statusBarFrame.height

/// 导航栏高度
let navigationHeight = (statusBarHeight + 44)

/// tabbar高度
let tabBarHeight = (statusBarHeight == 44 ? 83 : 49)

/// 获取屏幕大小
let screenBounds:CGRect = UIScreen.main.bounds

/// 系统statusBar高度
let kStatusBarHeight = UIApplication.shared.statusBarFrame.height

/// 屏幕宽高
let kScreenWidth = UIScreen.main.bounds.size.width
let kScreenHeight = UIScreen.main.bounds.size.height

/// 主题颜色
let kThemeColor = RGBCOLOR(44, 101, 192)

/// 通用背景色
let kBgColor = RGBCOLOR(245, 245, 249)


