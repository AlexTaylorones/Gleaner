//
//  AINetworkBaseController.swift
//  GleanerExample
//
//  Created by 李盛安 on 2019/11/14.
//  Copyright © 2019 Aisino. All rights reserved.
//

import UIKit

class AINetworkBaseController: UIViewController {
    
    let tableView = UITableView()
    
    /// Model
    var _model: AINetworkModel!
    var model: AINetworkModel! {
        set {
            _model = newValue
            refresh()
        }
        get {
            return _model
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    /// 刷新
    func refresh() {
        tableView.reloadData()
    }
    
}

// MARK: - UI
extension AINetworkBaseController {
    func setUpUI() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = RGBCOLOR(250, 250, 250)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
    }
}
