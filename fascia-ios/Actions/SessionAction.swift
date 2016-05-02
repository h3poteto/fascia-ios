//
//  SessionAction.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/01.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

class SessionAction {
    private let disposeBag = DisposeBag()

    func updateSession() {
        FasciaAPIService.sharedInstance.call("/session", method: .POST, params: nil)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .subscribe(onNext: { (response, data) in
                    FasciaAPIService.sharedInstance.saveSession(response)
                }, onError: { (errorType) in
                    print(errorType)
                }, onCompleted: {
                }, onDisposed: nil)
            .addDisposableTo(self.disposeBag)

    }
}
