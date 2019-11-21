//
//  AINetworkListWebCell.swift
//  GleanerExample
//
//  Created by 李盛安 on 2019/11/18.
//  Copyright © 2019 Aisino. All rights reserved.
//

import UIKit

class AINetworkListWebCell: UITableViewCell {
    
    /// 状态
    let statusLabel = UILabel()
    /// Url
    let urlLabel = UILabel()
    
    /// StackView
    let stackView = UIStackView()
    /// 时间
    let timeLabel = UILabel()
    /// 耗时
    let durationLabel = UILabel()
    
    var _model: AINetworkModel!
    var model: AINetworkModel! {
        set {
            _model = newValue
            
            self.statusLabel.text = "\(model.status)"
            self.durationLabel.text = AINetworkTool.getFormetTime(seconds: model.duration)
            self.timeLabel.text = AINetworkListDateFormatter.string(from: model.requestTime)
            self.urlLabel.text = model.host
            
            if model.status == AINetworkWebViewStatus.success.rawValue {
                self.statusLabel.textColor = UIColor.black
                self.urlLabel.textColor = UIColor.black
            } else {
                self.statusLabel.textColor = RGBCOLOR(241, 190, 66)
                self.urlLabel.textColor = RGBCOLOR(241, 190, 66)
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

extension AINetworkListWebCell {
    func setUpUI() {
        /// 状态码
        statusLabel.font = UIFont.boldSystemFont(ofSize: 16)
        statusLabel.textColor = RGBCOLOR(241, 190, 66)
        self.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { (make) in
            make.left.equalTo(6)
            make.top.equalTo(6)
            make.width.equalTo(50)
        }
        
        /// URL
        urlLabel.font = UIFont.boldSystemFont(ofSize: 16)
        urlLabel.numberOfLines = 0
        self.addSubview(urlLabel)
        urlLabel.snp.makeConstraints { (make) in
            make.left.equalTo(statusLabel.snp.bottom).offset(6)
            make.centerY.equalTo(statusLabel)
            make.right.equalTo(-6)
        }
        
        /// StackView
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        self.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.left.right.equalTo(urlLabel)
            make.height.equalTo(19.5)
            make.top.equalTo(urlLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
        }
        setUpStackView()
        
        /// 下划线
        let lineView = UIView()
        lineView.backgroundColor = RGBCOLOR(220, 220, 220)
        lineView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func setUpStackView() {
        stackView.insertSubview(durationLabel, at: 0)
        durationLabel.textColor = RGBCOLOR(115, 115, 115)
        durationLabel.font = UIFont.systemFont(ofSize: 14)
        
        stackView.insertSubview(timeLabel, at: 0)
        timeLabel.textColor = RGBCOLOR(115, 115, 115)
        timeLabel.font = UIFont.systemFont(ofSize: 14)
    }
    
}
