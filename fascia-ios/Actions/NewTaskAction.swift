//
//  NewTaskAction.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/20.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa
import ObjectMapper

class NewTaskAction {
    final let isLoading = BehaviorRelay(value: false)
    final let task: BehaviorRelay<Task?> = BehaviorRelay(value: nil)
    final let err: BehaviorRelay<Error?> = BehaviorRelay(value: nil)
    private let disposeBag = DisposeBag()

    func request(projectID: Int, listID: Int, params: [String: AnyObject]) {
        if isLoading.value {
            return
        }
        isLoading.accept(true)
        err.accept(nil)
        FasciaAPIService.sharedInstance.call(path: "/api/projects/\(projectID)/lists/\(listID)/tasks", method: .post, params: params)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .map { (response, data) throws -> Task in
                guard let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [String: AnyObject] else {
                    throw TaskError.parserError
                }
                guard let task = Mapper<Task>().map(JSON: json) else {
                    throw TaskError.mappingError
                }
                return task
            }
            .subscribe(onNext: { (task) in
                self.task.accept(task)
            }, onError: { (errorType) in
                self.err.accept(errorType)
                self.isLoading.accept(false)
            }, onCompleted: {
                self.isLoading.accept(false)
            }, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}
