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
    private let disposeBag = DisposeBag()

    init() {
        SVProgressHUD.setDefaultStyle(.Dark)
        SVProgressHUD.setBackgroundColor(UIColor.blackColor())
        SVProgressHUD.setForegroundColor(UIColor.whiteColor())
    }

    func bind(loadingTarget: Driver<Bool>) {
        loadingTarget
            .driveNext { (loading) in
                if loading {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                    SVProgressHUD.show()
                } else {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    SVProgressHUD.dismiss()
                }
            }
            .addDisposableTo(disposeBag)
    }
}
