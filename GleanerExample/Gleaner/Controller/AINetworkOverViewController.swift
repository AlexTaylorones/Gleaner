//
//  AINetworkOverViewController.swift
//  GleanerExample
//
//  Created by 李盛安 on 2019/11/18.
//  Copyright © 2019 Aisino. All rights reserved.
//

import UIKit

class AINetworkOverViewController: AINetworkBaseController {
    
    var arrData = [[String: String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(AINetworkTextCell.self, forCellReuseIdentifier: "AINetworkTextCell")

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func refresh() {
        model.type == AINetworkType.normal ? getNormalData() : getWebViewData()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AINetworkOverViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "AINetworkTextCell") as? AINetworkTextCell
        if cell == nil {
            cell = AINetworkTextCell.init(style: .default, reuseIdentifier: "AINetworkTextCell")
        }
        cell?.selectionStyle = .none
        
        let data = arrData[indexPath.row].first
        cell?.titleLabel.attributedText = AINetworkTool.getAttriString(title: data?.key ?? "", content: data?.value ?? "")
        
        return cell!
    }
}

extension AINetworkOverViewController {
    func getNormalData() {
        arrData = [ ["URL": "\(model.url!)"],
                    ["Method": "\(model.httpMethod)"],
                    ["Protocol": "\(model.scheme)"],
                    ["Status": "\(model.status)"],
                    ["Response": "\(model.statusCode)"],
                    ["SSL": "\(model.ssl)"],
                    ["": ""],
                    ["Request time": "\(AINetworkDateFormatter.string(from: model.requestTime))"],
                    ["Response time": "\(AINetworkDateFormatter.string(from: model.responseTime))"],
                    ["Duration": AINetworkTool.getFormetTime(seconds: model.duration)],
                    ["": ""],
                    ["Request size": AINetworkTool.getFormetFileSize(size: model.requestsSize)],
                    ["Response size": AINetworkTool.getFormetFileSize(size: model.responseSize)],
                    ["Total size": AINetworkTool.getFormetFileSize(size: (model.requestsSize + model.responseSize))],
                    ["": ""]
        ]
    }
    
    func getWebViewData() {
        arrData = [ ["URL": "\(model.url!)"],
                    ["Protocol": "\(model.scheme)"],
                    ["Status": "\(model.status)"],
                    ["": ""],
                    ["Request time": "\(AINetworkDateFormatter.string(from: model.requestTime))"],
                    ["Response time": "\(AINetworkDateFormatter.string(from: model.responseTime))"],
                    ["Duration": AINetworkTool.getFormetTime(seconds: model.duration)],
                    ["": ""]]
    }
    
}

