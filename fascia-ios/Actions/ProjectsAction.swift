//
//  ProjectsRequest.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/29.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

class ProjectsAction {
    final let isLoading = Variable(false)
    final var projects = Variable([Project]())
    final let err: Variable<Error?> = Variable(nil)
    private let disposeBag = DisposeBag()

    func request() {
        if isLoading.value {
            return
        }
        isLoading.value = true
        err.value = nil
        FasciaAPIService.sharedInstance.call(path: "/projects", method: .get, params: nil)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .map({ (response, data) throws -> [Project] in
                guard let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [[String: AnyObject]] else {
                    throw ProjectError.parserError
                }
                return Project.buildWithArray(projects: json)
            })
            .subscribe(onNext: { (projects) -> Void in
                    print(projects)
                    self.projects.value = projects
                }, onError: { (errorType) in
                    self.err.value = errorType
                    self.isLoading.value = false
                }, onCompleted: {
                    self.isLoading.value = false
                }, onDisposed: nil)
            .addDisposableTo(self.disposeBag)
    }
}
