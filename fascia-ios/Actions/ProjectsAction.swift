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
    final let isLoading = BehaviorRelay(value: false)
    final var projects = BehaviorRelay(value: [Project]())
    final let err: BehaviorRelay<Error?> = BehaviorRelay(value: nil)
    private let disposeBag = DisposeBag()

    func request() {
        if isLoading.value {
            return
        }
        isLoading.accept(true)
        err.accept(nil)
        FasciaAPIService.sharedInstance.call(path: "/api/projects", method: .get, params: nil)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .map({ (_, data) throws -> [Project] in
                guard let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [[String: AnyObject]] else {
                    throw ProjectError.parserError
                }
                return Project.buildWithArray(projects: json)
            })
            .subscribe(onNext: { (projects) -> Void in
                print(projects)
                self.projects.accept(projects)
            }, onError: { (errorType) in
                self.err.accept(errorType)
                self.isLoading.accept(false)
            }, onCompleted: {
                self.isLoading.accept(false)
            }, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}
