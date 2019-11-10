//
//  TaskAction.swift
//  fascia-ios
//
//  Created by akirafukushima on 2017/02/27.
//  Copyright © 2017年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa
import ObjectMapper

class TaskAction {
    final let isLoading = BehaviorRelay(value: false)
    final var task: BehaviorRelay<Task?> = BehaviorRelay(value: nil)
    final let err: BehaviorRelay<Error?> = BehaviorRelay(value: nil)
    private let disposeBag = DisposeBag()

    func request(projectID: Int, listID: Int, taskID: Int) {
        if isLoading.value {
            return
        }
        isLoading.accept(true)
        err.accept(nil)
        FasciaAPIService.sharedInstance.call(path: "/api/projects/\(projectID)/lists/\(listID)/tasks/\(taskID)", method: .get, params: nil)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .map { (response, data) -> Task in
                guard let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [String: AnyObject] else {
                    throw TaskError.parserError
                }
                guard let task = Mapper<Task>().map(JSON: json) else {
                    throw TaskError.mappingError
                }
                task.parseMarkdown()
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
