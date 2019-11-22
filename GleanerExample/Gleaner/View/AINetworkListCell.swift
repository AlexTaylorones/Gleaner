//
//  AINetworkListCell.swift
//  GleanerExample
//
//  Created by 李盛安 on 2019/11/18.
//  Copyright © 2019 Aisino. All rights reserved.
//

import UIKit

//enum HXNetworkErrorType {
//    case OK             ///< 200 客户端请求成功
//    case BadRequest     ///< 400 客户端请求有语法错误, 不能被服务器所理解
//    case Unauthorized   ///< 401 请求未经授权
//    case Forbidden      ///< 403 服务器收到请求, 但是拒绝提供服务
//    case NotFound       ///< 404 请求资源不存在, 输入了错误的URL
//    case InternalServerError    ///< 500 服务器发生不可预期的错误
//    case ServerUnavilable       ///< 503 服务器当前不能处理客户端的请求, 一段时间以后可能恢复正常
//}

//enum HXNetworkCellType {
//    case normal     ///< 成功 黑色主题
//    case error      ///< 请求成功, 但不为200 红色主题
//    case failed       ///< Failed 黄色主题
//}

class AINetworkListCell: UITableViewCell {
    
    /// 状态码
    let statusLabel = UILabel()
    /// URL
    let urlLabel = UILabel()
    /// Host
    let hostLabel = UILabel()
    
    /// StackView
    let stackView = UIStackView()
    /// 时间
    let timeLabel = UILabel()
    /// 耗时
    let durationLabel = UILabel()
    /// 字节
    let sizeLabel = UILabel()
    
    var _model: AINetworkModel!
    var model: AINetworkModel! {
        set {
            _model = newValue
            
            self.statusLabel.text = "\(model.statusCode)"
            self.urlLabel.text = "\(model.httpMethod) \(model.path)"
            self.hostLabel.text = "\(model.host)"
            self.sizeLabel.text = AINetworkTool.getFormetFileSize(size: model.responseSize)
            self.durationLabel.text = AINetworkTool.getFormetTime(seconds: model.duration)
            self.timeLabel.text = AINetworkListDateFormatter.string(from: model.requestTime)
            
            if model.statusCode == "200" {
                self.statusLabel.textColor = UIColor.black
                self.urlLabel.textColor = UIColor.black
            } else if model.status == "Failed"{
                self.statusLabel.textColor = RGBCOLOR(241, 190, 66)
                self.urlLabel.textColor = RGBCOLOR(241, 190, 66)
            } else {
                self.statusLabel.textColor = RGBCOLOR(213, 80, 63)
                self.urlLabel.textColor = RGBCOLOR(213, 80, 63)
            }
        }
        get {
            return _model
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension AINetworkListCell {
    func setUpUI() {
        /// 状态码
        statusLabel.font = UIFont.boldSystemFont(ofSize: 16)
        statusLabel.textColor = RGBCOLOR(241, 190, 66)
        statusLabel.textAlignment = .center
        self.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.top.equalTo(12)
            make.width.equalTo(50)
        }
        
        /// URL
        urlLabel.font = UIFont.boldSystemFont(ofSize: 16)
        urlLabel.numberOfLines = 0
        self.addSubview(urlLabel)
        urlLabel.snp.makeConstraints { (make) in
            make.left.equalTo(statusLabel.snp.right).offset(0)
            make.top.equalTo(12)
            make.right.equalTo(-6)
        }
        
        /// Host
        hostLabel.font = UIFont.systemFont(ofSize: 14)
        hostLabel.textColor = RGBCOLOR(115, 115, 115)
        self.addSubview(hostLabel)
        hostLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(urlLabel)
            make.top.equalTo(urlLabel.snp.bottom).offset(8)
        }
        
        /// StackView
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        self.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.left.right.equalTo(hostLabel)
            make.height.equalTo(19.5)
            make.top.equalTo(hostLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-6)
        }
        setUpStackView()
        
        /// 下划线
        let lineView = UIView()
        lineView.backgroundColor = RGBCOLOR(220, 220, 220)
        self.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func setUpStackView() {
        stackView.insertArrangedSubview(sizeLabel, at: 0)
        sizeLabel.textColor = RGBCOLOR(115, 115, 115)
        sizeLabel.font = UIFont.systemFont(ofSize: 14)
        
        stackView.insertArrangedSubview(durationLabel, at: 0)
        durationLabel.textColor = RGBCOLOR(115, 115, 115)
        durationLabel.font = UIFont.systemFont(ofSize: 14)

        stackView.insertArrangedSubview(timeLabel, at: 0)
        timeLabel.textColor = RGBCOLOR(115, 115, 115)
        timeLabel.font = UIFont.systemFont(ofSize: 14)
    }

}
