//
//  AICopyLabel.swift
//  GleanerExample
//
//  Created by 李盛安 on 2019/11/18.
//  Copyright © 2019 Aisino. All rights reserved.
//

import UIKit

// Mark: - Life Cycle
class AICopyLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.isUserInteractionEnabled = true
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressAction))
        self.addGestureRecognizer(longPressGesture)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = true
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressAction))
        self.addGestureRecognizer(longPressGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
}

// Mark: - Action
extension AICopyLabel {
    @objc func longPressAction() {
        self.becomeFirstResponder()
        let copyItem = UIMenuItem(title: "复制", action: #selector(self.copy(_:)))
        let menu = UIMenuController.shared
        menu.menuItems = [copyItem]
        if menu.isMenuVisible {
            return
        }
        menu.setTargetRect(bounds, in: self)
        menu.setMenuVisible(true, animated: true)
    }
}

// Mark: - Else
extension AICopyLabel {
    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = self.text
    }
}
