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
    final let isLoading = Variable(false)
    final let err: Variable<Error?> = Variable(nil)
    final let completed = Variable(false)

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
        isLoading.value = true
        err.value = nil
        completed.value = false
        FasciaAPIService.sharedInstance.call(path: "/sign_out", method: .delete, params: nil)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .subscribe(onNext: { (response, _) in
                FasciaAPIService.sharedInstance.deleteSession(response: response)
            }, onError: { (errorType) in
                self.err.value = errorType
                self.isLoading.value = false
            }, onCompleted: {
                self.isLoading.value = false
                self.completed.value = true
            }, onDisposed: nil)
        .disposed(by: self.disposeBag)
    }
}
