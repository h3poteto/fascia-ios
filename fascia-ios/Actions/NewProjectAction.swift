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
    final let isLoading = BehaviorRelay(value: false)
    final let project: BehaviorRelay<Project?> = BehaviorRelay(value: nil)
    final let err: BehaviorRelay<Error?> = BehaviorRelay(value: nil)
    private let disposeBag = DisposeBag()

    func request(parameter: [String: AnyObject]) {
        if isLoading.value {
            return
        }
        isLoading.accept(true)
        err.accept(nil)
        FasciaAPIService.sharedInstance.call(path: "/api/projects", method: .post, params: parameter)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .map({ (_, data) throws -> Project in
                guard let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [String: AnyObject] else {
                    throw ProjectError.parserError
                }
                guard let project = Mapper<Project>().map(JSON: json) else {
                    throw ProjectError.mappingError
                }
                return project
            })
            .subscribe(onNext: { (project) in
                self.project.accept(project)
            }, onError: { (errorType) in
                self.err.accept(errorType)
                self.isLoading.accept(false)
            }, onCompleted: {
                self.isLoading.accept(false)
            }, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}
