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
        FasciaAPIService.sharedInstance.callBasicAPI("/projects", method: .GET, params: nil)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .map({ (data, response) -> [Project] in
                guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? [[String: AnyObject]] else {
                    fatalError("parse error")
                }
                return Project.buildWithArray(json)
            })
            .subscribe(onNext: { (projects) in
                self.projects.value = projects
            }, onError: { (errorType) in
                self.error.value = errorType
                self.isLoading.value = false
            }, onCompleted: {
                self.isLoading.value = false
            }, onDisposed: nil)
            .addDisposableTo(self.disposeBag)
    }
}
