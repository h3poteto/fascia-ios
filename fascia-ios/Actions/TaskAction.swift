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
    final let isLoading = Variable(false)
    final var task: Variable<Task?> = Variable(nil)
    final let err: Variable<Error?> = Variable(nil)
    private let disposeBag = DisposeBag()

    func request(projectID: Int, listID: Int, taskID: Int) {
        if isLoading.value {
            return
        }
        isLoading.value = true
        err.value = nil
        FasciaAPIService.sharedInstance.call(path: "/projects/\(projectID)/lists/\(listID)/tasks/\(taskID)", method: .get, params: nil)
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
                self.task.value = task
            }, onError: { (errorType) in
                self.err.value = errorType
                self.isLoading.value = false
            }, onCompleted: {
                self.isLoading.value = false
            }, onDisposed: nil
        )
        .addDisposableTo(disposeBag)
    }
}
