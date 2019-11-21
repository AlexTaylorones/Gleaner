//
//  AINetworkTextCell.swift
//  GleanerExample
//
//  Created by 李盛安 on 2019/11/18.
//  Copyright © 2019 Aisino. All rights reserved.
//

import UIKit

class AINetworkTextCell: UITableViewCell {
    
    let titleLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.textColor = RGBCOLOR(115, 115, 115)
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.numberOfLines = 0
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints({ (make) in
            make.top.left.equalTo(6)
            make.right.bottom.equalTo(-6)
        })
        
        let lonePress = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPress(sender:)))
        self.addGestureRecognizer(lonePress)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func cellLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.becomeFirstResponder()
            
            let menu = UIMenuController.shared
            if menu.isMenuVisible {
                return
            }
            menu.setTargetRect(self.bounds, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    override var isFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }
    
    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = self.titleLabel.text
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
}
