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

enum NewTaskValidationError: ErrorType {
    case TitleError
}

class NewTaskViewModel {
    private let action = NewTaskAction()
    private(set) var newTask: Variable<NewTask>
    private var list: List
    private(set) var title: Variable<String?> = Variable(nil)
    private(set) var description: Variable<String?> = Variable(nil)
    final private(set) var dataUpdated: Driver<Task?> = Driver.never()
    final private(set) var isLoading: Driver<Bool> = Driver.never()
    final private(set) var error: Driver<ErrorType?> = Driver.never()

    init(model: NewTask, list: List) {
        self.newTask = Variable(model)
        self.list = list

        dataUpdated = Driver
            .combineLatest(
                action.task.asDriver(),
                action.error.asDriver().map({
                    $0 != nil
                }),
                resultSelector: {
                    ($1) ? nil : $0
            })

        isLoading = action.isLoading.asDriver()
        error = action.error.asDriver()
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
            .doOnNext({ (valid) in
                if valid {
                    self.fetch()
                }
            })
    }

    func valid() -> Observable<Bool> {
        return newTask.asObservable()
            .flatMap({ (task) throws -> Observable<Bool> in
                if task.title?.characters.count < 1 {
                    throw NewTaskValidationError.TitleError
                }
                return Observable.just(true)
            })
    }

    func fetch() {
        let params = Mapper<NewTask>().toJSON(newTask.value)
        action.request(list.projectID!, listID: list.id!, params: params)
    }
}
