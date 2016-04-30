//
//  ProjectsRequest.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/29.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

class ProjectsRequest {
    final let isLoading = Variable(false)
    final let projects = Variable([Project]())
    final let error: Variable<ErrorType?> = Variable(nil)
    final let disposeBag = DisposeBag()

    func request() {
        if isLoading.value {
            return
        }
        isLoading.value = true
        error.value = nil
        FasciaAPIService().call("/projects", method: .GET, params: nil)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .subscribe(onNext: { (projects) -> Void in
                print(projects)
            }, onError: { (errorType) in
                self.error.value = errorType
                self.isLoading.value = false
            }, onCompleted: {
                self.isLoading.value = false
            }, onDisposed: nil)
            .addDisposableTo(self.disposeBag)
    }
}
