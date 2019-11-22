//
//  AIDashboardView.swift
//  GleanerExample
//
//  Created by 李盛安 on 2019/11/19.
//  Copyright © 2019 Aisino. All rights reserved.
//

import UIKit

class AIDashboardView: UIView {
    
    /// 上部计数标签
    let numLabel = UILabel()
    /// 下部文本标签
    let detailLabel = UILabel()
    
    /// 当前视图宽度
    var selfWidth: CGFloat = 0.0
    /// 上级View的Frame
    var superFrame: CGRect = UIScreen.main.bounds
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        selfWidth = frame.size.width
        
        /// Self
        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.5)
        self.layer.cornerRadius = frame.height/2
        self.clipsToBounds = true
        
        /// 上部计数标签
        numLabel.text = "\(AINetworkManager.manager.getLocalModels().count)"
        numLabel.textAlignment = .center
        numLabel.font = UIFont.boldSystemFont(ofSize: 24)
        numLabel.textColor = UIColor.white
        self.addSubview(numLabel)
        numLabel.snp.makeConstraints { (make) in
            make.width.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.8)
        }
        
        /// 下部文本标签
        detailLabel.text = "Gleaner"
        detailLabel.textAlignment = .center
        detailLabel.textColor = UIColor.white
        detailLabel.font = UIFont.systemFont(ofSize: 10)
        self.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.width.centerX.equalToSuperview()
            make.top.equalTo(numLabel.snp.bottom).offset(2)
        }
        
        /// 手势
        addPanGestureRecognizer()
        addTapGestureRecognizer()
        
        /// 接收通知
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "AINetworkManager"), object:nil )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Else
extension AIDashboardView {
    @objc func refresh() {
        numLabel.text = "\(AINetworkManager.manager.getLocalModels().count)"
    }
}

// MARK: - Gesture
extension AIDashboardView {
    func addPanGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(circlePanned(pan:)))
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    func addTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showLogVC))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
}

// MARK: - Action
extension AIDashboardView {
    @objc func circlePanned(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case UIGestureRecognizer.State.began:
            self.superview?.bringSubviewToFront(self)
        case UIGestureRecognizer.State.changed:
            let point = pan.translation(in: self)
            let f = self.frame
            let dx = point.x + f.origin.x
            let dy = point.y + f.origin.y
            self.frame = CGRect(x: dx, y: dy, width: selfWidth, height: selfWidth)
            // 注: 一旦完成上述的移动, 将translation重置十分重要, 否则translation每次都会叠加
            pan.setTranslation(CGPoint(x: 0, y: 0), in: self)
        case UIGestureRecognizer.State.ended:
            let f = self.frame
            var dx = f.origin.x
            var dy = f.origin.y
            if dx > superFrame.size.width-10-selfWidth {
                dx = superFrame.size.width-10-selfWidth
            } else if dx < 10 {
                dx = 10.0
            } else {
                dx = dx > superFrame.size.width-dx ? superFrame.size.width-10-selfWidth : 10
            }
            
            if dy > superFrame.size.height-10-selfWidth {
                dy = superFrame.size.height-10-selfWidth
            } else if dy < 10 {
                dy = 10.0
            }
            
            UIView.animate(withDuration: 0.2) {
                self.frame = CGRect(x: dx, y: dy, width: f.size.width, height: f.size.height)
            }
        default:
            break
        }
        let point:CGPoint = pan.translation(in: self)
        self.transform = CGAffineTransform.init(translationX: point.x, y: point.y)
    }
    
    @objc func showLogVC() {
        let netVC = AINetworkListController()
        AINetworkTool.getCurrentVC().present(netVC, animated: true, completion: nil)
        
        /// 隐藏浮窗
        for view in UIApplication.shared.keyWindow?.subviews ?? [UIView()] {
            if view.isKind(of: AIDashboardView.self) {
                view.isHidden = true
            }
        }
    }
}

