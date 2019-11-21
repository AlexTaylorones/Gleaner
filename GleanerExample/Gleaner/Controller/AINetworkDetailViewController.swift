//
//  AINetworkDetailViewController.swift
//  GleanerExample
//
//  Created by 李盛安 on 2019/11/18.
//  Copyright © 2019 Aisino. All rights reserved.
//

import UIKit

// MARK: - Life Cycle
class AINetworkDetailViewController: UIViewController {
    
    /// HXNetworkModel
    var _model: AINetworkModel!
    var model: AINetworkModel! {
        set {
            _model = newValue
            if model.type == AINetworkType.normal {
                titleLabel.text = "\(newValue.httpMethod) \(newValue.path)"
            } else {
                titleLabel.text = newValue.host
            }
        }
        get {
            return _model
        }
    }
    
    /// 标题栏
    let titleLabel = UILabel()
    
    /// UIPageViewController
    let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    /// VC
    let overViewVC = AINetworkOverViewController()
    let requestVC = AINetworkRequestController()
    let responseVC = AINetworkResponseController()
    
    let testVC = AINetworkWebviewTestController()
    
    /// 懒加载控制器数组
    private lazy var allViewControllers:[UIViewController] = {
        if model.type == AINetworkType.normal {
            return [overViewVC, requestVC, responseVC]
        } else {
            return [overViewVC, testVC]
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
}

// MARK: - UI
extension AINetworkDetailViewController {
    func setUpUI() {
        
        /// 导航栏
        var topHeight = 0
        if #available(iOS 11.0, *) {
            topHeight = UIApplication.shared.windows.first?.safeAreaInsets.bottom == 0 ? 64 : 83
        } else {
            topHeight = 64
        }
        let topView = UIView()
        topView.backgroundColor = kThemeColor
        self.view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(topHeight)
        }
        /// 消失按钮
        let dismissBtn = UIButton()
        dismissBtn.setImage(UIImage.init(named: "btn_navi_back_normal"), for: .normal)
        dismissBtn.addTarget(self, action: #selector(dismissSelected), for: .touchUpInside)
        topView.addSubview(dismissBtn)
        dismissBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(38)
            make.left.equalToSuperview().offset(8)
            make.bottom.equalToSuperview()
        }
        /// 标题
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        topView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(dismissBtn)
        }
        /// 分享按钮
        let shareBtn = UIButton()
        shareBtn.setImage(UIImage.init(named: "gleaner_share"), for: .normal)
        shareBtn.addTarget(self, action: #selector(shareSelected), for: .touchUpInside)
        topView.addSubview(shareBtn)
        shareBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(26)
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalTo(dismissBtn)
        }
        
        /// 菜单栏
        let menuView = UIStackView()
        menuView.distribution = .fillEqually
        menuView.alignment = .fill
        menuView.axis = .horizontal
        self.view.addSubview(menuView)
        menuView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
            make.height.equalTo(48)
        }
        /// 菜单栏按钮
        let titles = model.type == AINetworkType.normal ? ["OVERVIEW", "REQUEST", "RESPONSE"] : ["OVERVIEW", "TEST"]
        for index in 0...titles.count-1 {
            let menuButton = UIButton()
            menuButton.setTitle(titles[index], for: .normal)
            menuButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            menuButton.titleLabel?.textColor = UIColor.white
            menuButton.tag = 1000+index
            menuButton.addTarget(self, action: #selector(menuSelected(sender:)), for: .touchUpInside)
            menuButton.backgroundColor = kThemeColor
            menuView.insertArrangedSubview(menuButton, at: index)
        }
        
        /// UIPageViewController
        overViewVC.model = model
        requestVC.model = model
        responseVC.model = model
        testVC.url = model.url
        pageVC.setViewControllers([allViewControllers.first!], direction: .forward, animated: true, completion: nil)
        pageVC.delegate = self
        pageVC.dataSource = self
        self.addChild(pageVC)
        self.view.addSubview(pageVC.view)
        pageVC.view.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(menuView.snp.bottom)
        }
        
    }
}

// MARL: - UIPageViewControllerDelegate, UIPageViewControllerDataSource
extension AINetworkDetailViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return allViewControllers.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let index = allViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let preIndex = index - 1
        
        // 如果在第一页向右滑动则滚动到最后一页
        if preIndex < 0 {
            return allViewControllers.last
        }
        
        // 判断当前索引是否大于0且少于总索引个数
        guard preIndex>=0, allViewControllers.count>preIndex else {
            return nil
        }
        
        return allViewControllers[preIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = allViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = index + 1
        
        // 如果在最后页向左滑动则滚动到第一页
        if nextIndex == allViewControllers.count {
            return allViewControllers.first
        }
        // 判断当前索引是否大于0且少于总索引个数
        if allViewControllers.count > nextIndex {
            return allViewControllers[nextIndex]
        } else {
            return nil
        }
    }
}

// MARK: - Action
extension AINetworkDetailViewController {
    @objc func dismissSelected() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func menuSelected(sender: UIButton) {
        pageVC.setViewControllers([allViewControllers[sender.tag-1000]], direction: .forward, animated: false, completion: nil)
    }
    
    @objc func shareSelected() {
        let shareText = "\(model.description)"
        
        let alertVC = UIAlertController.init(title: nil, message: nil, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction.init(title: "QQ", style: .default, handler: { (UIAlertAction) in
            UIPasteboard.general.string = shareText
            if UIApplication.shared.canOpenURL(URL(string: "mqq://")!) {
                UIApplication.shared.open(URL(string: "mqq://")!, options: [:], completionHandler: nil)
            } else {
//                self.view.makeToast("已复制, 但打开QQ失败")
            }
        }))
        alertVC.addAction(UIAlertAction.init(title: "微信", style: .default, handler: { (UIAlertAction) in
            UIPasteboard.general.string = shareText
            if UIApplication.shared.canOpenURL(URL(string: "wechat://")!) {
                UIApplication.shared.open(URL(string: "wechat://")!, options: [:], completionHandler: nil)
            } else {
//                self.view.makeToast("已复制, 但打开微信失败")
            }
        }))
        alertVC.addAction(UIAlertAction.init(title: "复制", style: .default, handler: { (UIAlertAction) in
            UIPasteboard.general.string = shareText
//            self.view.makeToast("已复制")
        }))
        alertVC.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (UIAlertAction) in
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
}
