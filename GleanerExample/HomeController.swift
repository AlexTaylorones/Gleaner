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
        
        let getBtn = UIButton()
        getBtn.setTitle("Get请求", for: .normal)
        getBtn.setTitleColor(UIColor.black, for: .normal)
        getBtn.addTarget(self, action: #selector(getRequest), for: .touchUpInside)
        self.view.addSubview(getBtn)
        getBtn.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
        let failBtn = UIButton()
        failBtn.setTitle("Fail请求", for: .normal)
        failBtn.setTitleColor(UIColor.black, for: .normal)
        failBtn.addTarget(self, action: #selector(failRequest), for: .touchUpInside)
        self.view.addSubview(failBtn)
        failBtn.snp.makeConstraints { (make) in
            make.width.height.centerX.equalTo(getBtn)
            make.top.equalTo(getBtn.snp.bottom).offset(22)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }

}

// MARK: - Action
extension HomeController {
    @objc func getRequest() {
        NetworkingHandler
            .request(.getAPI(pathComponent: "api=mtop.common.getTimestamp", param: [:], extraHeaders: [:]))
            .subscribe(onNext: { (response) in
                
            }, onError: { (error) in
                
            })
            .disposed(by:bag)
    }
    
    @objc func failRequest() {
        NetworkingHandler
            .request(.getAPI(pathComponent: "api=mtop.common", param: [:], extraHeaders: [:]))
            .subscribe(onNext: { (response) in
                
            }, onError: { (error) in
                
            })
            .disposed(by:bag)
    }
}
