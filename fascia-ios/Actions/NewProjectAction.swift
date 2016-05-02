//
//  NewProjectRequest.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/30.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa
import ObjectMapper

class NewProjectAction {
    final let isLoading = Variable(false)
    final let project = Variable(Project())
    final let error: Variable<ErrorType?> = Variable(nil)
    final let disposeBag = DisposeBag()

    func request(parameter: [String: AnyObject]) {
        if isLoading.value {
            return
        }
        isLoading.value = true
        error.value = nil
        FasciaAPIService.sharedInstance.call("/projects", method: .POST, params: parameter)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .subscribe(onNext: { (respnse, project) in
                print(project)
            }, onError: { (errorType) in
                self.error.value = errorType
                self.isLoading.value = false
            }, onCompleted: {
                self.isLoading.value = false
            }, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
}
