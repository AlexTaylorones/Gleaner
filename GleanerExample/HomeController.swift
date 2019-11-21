//
//  HomeController.swift
//  GleanerExample
//
//  Created by 李盛安 on 2019/11/19.
//  Copyright © 2019 Aisino. All rights reserved.
//

import UIKit

// MARK: - Life Cycle
class HomeController: UIViewController {
    
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let requestBtn = UIButton()
        requestBtn.setTitle("发送请求", for: .normal)
        requestBtn.setTitleColor(UIColor.black, for: .normal)
        requestBtn.addTarget(self, action: #selector(request), for: .touchUpInside)
        self.view.addSubview(requestBtn)
        requestBtn.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
    }

}

// MARK: - Action
extension HomeController {
    @objc func request() {
        NetworkingHandler
            .request(.getAPI(pathComponent: "api=mtop.common.getTimestamp", param: [:], extraHeaders: [:]))
            .subscribe(onNext: { (response) in
                
            }, onError: { (error) in
                
            })
            .disposed(by:bag)
    }
}
