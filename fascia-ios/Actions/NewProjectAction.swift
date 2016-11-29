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
    final let project: Variable<Project?> = Variable(nil)
    final let err: Variable<Error?> = Variable(nil)
    private let disposeBag = DisposeBag()

    func request(parameter: [String: AnyObject]) {
        if isLoading.value {
            return
        }
        isLoading.value = true
        err.value = nil
        FasciaAPIService.sharedInstance.call(path: "/projects", method: .post, params: parameter)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .map({ (response, data) throws -> Project in
                guard let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [String: AnyObject] else {
                    throw ProjectError.parserError
                }
                guard let project = Mapper<Project>().map(JSON: json) else {
                    throw ProjectError.mappingError
                }
                return project
            })
            .subscribe(onNext: { (project) in
                    self.project.value = project
                }, onError: { (errorType) in
                    self.err.value = errorType
                    self.isLoading.value = false
                }, onCompleted: {
                    self.isLoading.value = false
                }, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
}
