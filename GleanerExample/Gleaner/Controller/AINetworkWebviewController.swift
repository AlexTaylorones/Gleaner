//
//  AINetworkWebviewController.swift
//  GleanerExample
//
//  Created by 李盛安 on 2019/11/18.
//  Copyright © 2019 Aisino. All rights reserved.
//

import UIKit
import WebKit

class AINetworkWebviewController: UIViewController {
    
    let currentModel = AINetworkModel()
    
    // wkWebView
    lazy var wkWebView = WKWebView()
    // url
    var _url: URL!
    var url: URL! {
        set {
            _url = newValue
            wkWebView.load(URLRequest(url: newValue))
        }
        get {
            return _url
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wkWebView.navigationDelegate = self
        self.view.addSubview(self.wkWebView)
        wkWebView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
    }
}

extension AINetworkWebviewController: WKNavigationDelegate {
    // 监听
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    }
    
    // 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("开始加载...")
    }
    
    // 当内容开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("当内容开始返回...")
    }
    
    // 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("页面加载完成...")
    }
    
    // 页面加载失败时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("页面加载失败...")
    }
    
}

