//
//  AINetworkListController.swift
//  GleanerExample
//
//  Created by 李盛安 on 2019/11/18.
//  Copyright © 2019 Aisino. All rights reserved.
//

import UIKit
import SnapKit
import Moya
import SwiftyJSON
import Result
import RxSwift
import Toast_Swift

class AINetworkListController: UIViewController {
    
    let tableView = UITableView()
    
    var models = [AINetworkModel]()
    
    /// Thread Safe Bag
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        
        refresh()
    }
}

extension AINetworkListController {
    func setUpUI() {
        
        /// 导航栏
        var topHeight = 0.0
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
        /// 清除按钮
        let clearBtn = UIButton()
        clearBtn.setImage(UIImage.init(named: "gleaner_clear"), for: .normal)
        clearBtn.addTarget(self, action: #selector(removeAll), for: .touchUpInside)
        topView.addSubview(clearBtn)
        clearBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(26)
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalTo(dismissBtn)
        }
        /// 搜索框
        let searchBar = UISearchBar()
        searchBar.barTintColor = kThemeColor
        searchBar.tintColor = kThemeColor
        searchBar.backgroundColor = kThemeColor
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        topView.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.centerY.equalTo(dismissBtn)
            make.height.equalTo(26)
            make.left.equalTo(dismissBtn.snp.right)
            make.right.equalTo(clearBtn.snp.left)
        }
        
        /// 表视图
        tableView.separatorStyle = .none
        tableView.register(AINetworkListCell.self, forCellReuseIdentifier: "AINetworkListCell")
        tableView.register(AINetworkListWebCell.self, forCellReuseIdentifier: "AINetworkListWebCell")
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
        }
        
        /// 接收通知
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "HXNetworkManager"), object:nil )
        
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AINetworkListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = models[indexPath.row]
        
        if model.type == AINetworkType.normal {
            var cell = tableView.dequeueReusableCell(withIdentifier: "AINetworkListCell") as? AINetworkListCell
            if cell == nil {
                cell = AINetworkListCell.init(style: .default, reuseIdentifier: "AINetworkListCell")
            }
            cell?.selectionStyle = .none
            
            cell?.model = model
            
            return cell!
        }
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "AINetworkListWebCell") as? AINetworkListWebCell
        if cell == nil {
            cell = AINetworkListWebCell.init(style: .default, reuseIdentifier: "AINetworkListWebCell")
        }
        cell?.selectionStyle = .none
        
        cell?.model = model
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "删除") { [weak self] (action, index) in
            let model = self!.models[indexPath.row]
            AINetworkManager.manager.removeModel(model)
        }
        let share = UITableViewRowAction(style: .normal, title: "分享") {[weak self] (action, index) in
            let model = self!.models[indexPath.row]
            
            let shareText = "\(model.description)"
            
            let alertVC = UIAlertController.init(title: nil, message: nil, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction.init(title: "QQ", style: .default, handler: { (UIAlertAction) in
                UIPasteboard.general.string = shareText
                if UIApplication.shared.canOpenURL(URL(string: "mqq://")!) {
                    UIApplication.shared.open(URL(string: "mqq://")!, options: [:], completionHandler: nil)
                } else {
                    self!.view.makeToast("已复制, 但打开QQ失败")
                }
            }))
            alertVC.addAction(UIAlertAction.init(title: "微信", style: .default, handler: { (UIAlertAction) in
                UIPasteboard.general.string = shareText
                if UIApplication.shared.canOpenURL(URL(string: "wechat://")!) {
                    UIApplication.shared.open(URL(string: "wechat://")!, options: [:], completionHandler: nil)
                } else {
                    self!.view.makeToast("已复制, 但打开微信失败")
                }
            }))
            alertVC.addAction(UIAlertAction.init(title: "复制", style: .default, handler: { (UIAlertAction) in
                UIPasteboard.general.string = shareText
                self!.view.makeToast("已复制")
            }))
            alertVC.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (UIAlertAction) in
            }))
            self!.present(alertVC, animated: true, completion: nil)
        }
        return [delete, share]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = AINetworkDetailViewController()
        detailVC.model = models[indexPath.row]
        AINetworkTool.getCurrentVC().present(detailVC, animated: false, completion: nil)
    }
}

// MARK: - UISearchBarDelegate
extension AINetworkListController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.models = AINetworkManager.manager.getLocalModels()
            self.tableView.reloadData()
            return
        }
        /// 过滤
        self.models.removeAll()
        for model in AINetworkManager.manager.getLocalModels() {
            if model.path.uppercased().contains(searchText.uppercased()) {
                self.models.append(model)
            }
        }
        self.tableView.reloadData()
    }
}

// MARK: - Action
extension AINetworkListController {
    @objc func dismissSelected() {
        /// 显示浮窗
        for view in UIApplication.shared.keyWindow?.subviews ?? [UIView()] {
            if view.isKind(of: AIDashboardView.self) {
                view.isHidden = false
            }
        }
        /// 消失
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func removeAll() {
        AINetworkManager.manager.removeAll()
    }
    
    @objc func refresh() {
        models = AINetworkManager.manager.getLocalModels()
        tableView.reloadData()
    }
}

