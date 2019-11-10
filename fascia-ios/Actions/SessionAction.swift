//
//  SessionAction.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/01.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa
import WebKit

class SessionAction {
    private let disposeBag = DisposeBag()
    final let isLoading = BehaviorRelay(value: false)
    final let err: BehaviorRelay<Error?> = BehaviorRelay(value: nil)
    final let completed =
        BehaviorRelay(value: false)

    func updateSession() {
        FasciaAPIService.sharedInstance.call(path: "/session", method: .patch, params: nil)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .subscribe(onNext: { (response, _) in
                    FasciaAPIService.sharedInstance.saveSession(response: response)
                }, onError: { (errorType) in
                    print(errorType)
                }, onCompleted: {
                }, onDisposed: nil)
            .disposed(by: self.disposeBag)

    }

    func deleteSession() {
        if isLoading.value {
            return
        }
        isLoading.accept(true)
        err.accept(nil)
        completed.accept(false)
        FasciaAPIService.sharedInstance.call(path: "/sign_out", method: .delete, params: nil)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .subscribe(onNext: { (response, _) in
                FasciaAPIService.sharedInstance.deleteSession(response: response)
            }, onError: { (errorType) in
                self.err.accept(errorType)
                self.isLoading.accept(false)
            }, onCompleted: {
                self.isLoading.accept(false)
                self.completed.accept(true)
            }, onDisposed: nil)
        .disposed(by: self.disposeBag)
    }
}
