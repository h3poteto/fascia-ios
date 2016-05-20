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
    final let isLoading = Variable(false)
    final let task: Variable<Task?> = Variable(nil)
    final let error: Variable<ErrorType?> = Variable(nil)
    final let disposeBag = DisposeBag()

    func request(projectID: Int, listID: Int, params: [String: AnyObject]) {
        if isLoading.value {
            return
        }
        isLoading.value = true
        error.value = nil
        FasciaAPIService.sharedInstance.call("/projects/\(projectID)/lists/\(listID)/tasks", method: .POST, params: params)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .map { (response, data) throws -> Task in
                guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject] else {
                    throw TaskError.ParserError
                }
                guard let task = Mapper<Task>().map(json) else {
                    throw TaskError.MappingError
                }
                return task
            }
            .subscribe(onNext: { (task) in
                self.task.value = task
                }, onError: { (errorType) in
                    self.error.value = errorType
                    self.isLoading.value = false
                }, onCompleted: {
                    self.isLoading.value = false
                }, onDisposed: nil
            )
            .addDisposableTo(disposeBag)
    }
}
