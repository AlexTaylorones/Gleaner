|作者|日期|
|----|----|
|李盛安|2019/11/22|

# Gleaner

适用于iOS的简单应用内HTTP检查器.Gleaner获取并保留应用程序内所有的HTTP请求和响应.</br>
使用Gleaner的应用会有浮窗显示HTTP的条数.点击浮窗会进入HTTP活动列表.

### 1 开源库地址:[Github地址](https://github.com/AilsaYouCan/Gleaner)

### 2 特性:

- 包含HTTP请求和WebView</br>
- 支持模糊搜索</br>
- 支持单条/全部清除</br>
- 限制200条记录</br>
- 支持文本分享</br>

### 3 集成:
① Podfile文件加入以下代码

```swift
use_frameworks!

target 'YourAppTargetName' do
    pod 'pod 'Gleaner''
end
```
② 终端执行执行 pod install

③ AppDelegate.swift加入以下代码来初始化浮窗

```swift
#if DEBUG
    let dashboardView = AIDashboardView.init(frame: CGRect(x: 200, y: 200, width: 80, height: 80))
    window?.addSubview(dashboardView)
#endif
```