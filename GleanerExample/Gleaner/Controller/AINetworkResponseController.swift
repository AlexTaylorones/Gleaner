//
//  AINetworkResponseController.swift
//  GleanerExample
//
//  Created by 李盛安 on 2019/11/18.
//  Copyright © 2019 Aisino. All rights reserved.
//

import UIKit

class AINetworkResponseController: AINetworkBaseController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(AINetworkTextCell.self, forCellReuseIdentifier: "AINetworkTextCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AINetworkResponseController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if model == nil {
            return 0
        }
        return model.responseAllHTTPHeaderFields.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "AINetworkTextCell") as? AINetworkTextCell
        if cell == nil {
            cell = AINetworkTextCell.init(style: .default, reuseIdentifier: "AINetworkTextCell")
        }
        cell?.selectionStyle = .none
        
        if indexPath.row == model.responseAllHTTPHeaderFields.count {
            cell?.titleLabel.text = model.responseJson
        } else {
            let dicTemp = model.responseAllHTTPHeaderFields[indexPath.row]
            cell?.titleLabel.attributedText = AINetworkTool.getAttriString(title: dicTemp.keys.first ?? "", content: dicTemp.values.first ?? "")
        }
        
        return cell!
    }
}

