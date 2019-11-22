<h1 align="center">
  <br>
  <a href="http://"><img src="https://raw.githubusercontent.com/AilsaYouCan/Gleaner/master/GleanerLogo.jpg" alt="Gleaner" width="200"></a>
  <br>
  Gleaner
  <br>
</h1>

<h4 align="center">获取并保留应用程序内所有的HTTP请求和响应.</h4>

## Key Features
适用于iOS的简单应用内HTTP检查器.Gleaner获取并保留应用程序内所有的HTTP请求和响应.</br>
使用Gleaner的应用会有浮窗显示HTTP的条数.点击浮窗会进入HTTP活动列表.
* 包含HTTP请求和WebView</br>
* 支持模糊搜索</br>
* 支持单条/全部清除</br>
* 限制200条记录</br>
* 支持文本分享</br>

## How It Works
1. Podfile

```swift
use_frameworks!

target 'YourAppTargetName' do
    pod 'Gleaner'
end
```
2. run `pod install` 

## Usage
AppDelegate.swift加入以下代码来初始化浮窗

```swift
#if DEBUG
    let dashboardView = AIDashboardView.init(frame: CGRect(x: 200, y: 200, width: 80, height: 80))
    window?.addSubview(dashboardView)
#endif
```

## Release History
* 1.0.1 - Minor fixes.
* 1.0.0 - Initial release.

## License
Copyright (c) 2019 LiShengan

Licensed under the MIT license.
