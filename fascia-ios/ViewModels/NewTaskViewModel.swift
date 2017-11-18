//
//  NewTaskViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/20.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa
import ObjectMapper

enum NewTaskValidationError: Error {
    case titleError
}

class NewTaskViewModel {
    private let action = NewTaskAction()
    private(set) var newTask: Variable<NewTask>
    private var list: List
    private(set) var title: Variable<String?> = Variable(nil)
    private(set) var description: Variable<String?> = Variable(nil)
    final private(set) var dataUpdated: Driver<Task?> = Driver.never()
    final private(set) var isLoading: Driver<Bool> = Driver.never()
    final private(set) var err: Driver<Error?> = Driver.never()

    init(model: NewTask, list: List) {
        self.newTask = Variable(model)
        self.list = list

        dataUpdated = Driver
            .combineLatest(
                action.task.asDriver(),
                action.err.asDriver().map({
                    $0 != nil
                }),
                resultSelector: {
                    ($1) ? nil : $0
            })

        isLoading = action.isLoading.asDriver()
        err = action.err.asDriver()
    }

    func update(title: String?, description: String?) {
        if title != nil {
            self.title.value = title
            newTask.value.title = title
        }
        if description != nil {
            self.description.value = description
            newTask.value.taskDescription = description
        }
    }

    func save() -> Observable<Bool> {
        return valid()
            .do(onNext: { (valid) in
                if valid {
                    self.fetch()
                }
            }, onError: nil, onCompleted: nil, onSubscribe: nil, onDispose: nil)
    }

    func valid() -> Observable<Bool> {
        return newTask.asObservable()
            .flatMap({ (task) throws -> Observable<Bool> in
                guard let title = task.title else {
                    throw NewTaskValidationError.titleError
                }
                if title.count < 1 {
                    throw NewTaskValidationError.titleError
                }
                return Observable.just(true)
            })
    }

    func fetch() {
        let params = Mapper<NewTask>().toJSON(newTask.value)
        action.request(projectID: list.projectID!, listID: list.id!, params: params as [String : AnyObject])
    }
}
