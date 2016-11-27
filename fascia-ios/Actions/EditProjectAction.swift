//
//  EditProjectAction.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/22.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa
import ObjectMapper

class EditProjectAction {
    final let isLoading = Variable(false)
    final let project: Variable<Project?> = Variable(nil)
    final let err: Variable<Error?> = Variable(nil)
    final let disposeBag = DisposeBag()

    func request(_ projectID: Int, params: [String: AnyObject]) {
        if isLoading.value {
            return
        }
        isLoading.value = true
        err.value = nil
        FasciaAPIService.sharedInstance.call("/projects/\(projectID)", method: .post, params: params)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
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
