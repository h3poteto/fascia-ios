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

class NewProjectRequest {
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
        FasciaAPIService.sharedInstance.callBasicAPI("/projects", method: .POST, params: parameter)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .map { (data, response) -> Project in
                guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? [String: AnyObject] else {
                    throw ProjectError.PaserError
                }
                guard let project = Mapper<Project>().map(json) else {
                    throw ProjectError.MappingError
                }
                return project
            }
            .subscribe(onNext: { (project) in
                self.project.value = project
            }, onError: { (errorType) in
                self.error.value = errorType
                self.isLoading.value = false
            }, onCompleted: {
                self.isLoading.value = false
            }, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
}