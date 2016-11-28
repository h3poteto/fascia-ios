//
//  HUDManager.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/03.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import UIKit
import SVProgressHUD
import RxSwift
import RxCocoa

class HUDManager {
    fileprivate let disposeBag = DisposeBag()

    init() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setBackgroundColor(UIColor.black)
        SVProgressHUD.setForegroundColor(UIColor.white)
    }

    func bind(_ loadingTarget: Driver<Bool>) {
        loadingTarget
            .drive(onNext: { (loading) in
                if loading {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    SVProgressHUD.show()
                } else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    SVProgressHUD.dismiss()
                }
            }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
}
