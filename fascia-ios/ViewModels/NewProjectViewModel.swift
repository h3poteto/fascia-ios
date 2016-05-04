//
//  NewProjectViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/29.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa
import ObjectMapper

enum NewProjectValidationError: ErrorType {
    case TitleError
}

class NewProjectViewModel {
    private final let action = NewProjectAction()
    private(set) var newProject: Variable<NewProject>
    final private(set) var title: Variable<String?> = Variable(nil)
    final private(set) var dataUpdated: Driver<Project?> = Driver.never()
    final private(set) var isLoading: Driver<Bool> = Driver.never()
    final private(set) var error: Driver<ErrorType?> = Driver.never()
    var repository: Variable<Repository?> = Variable(nil)

    init(model: NewProject) {
        self.newProject = Variable(model)

        dataUpdated = Driver
            .combineLatest(
                action.project.asDriver(),
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
            newProject.value.title = title
            self.title.value = title
        }
        if description != nil {
            newProject.value.description = description
        }
    }

    func save() -> Observable<Bool> {
        return valid()
            .doOnNext({ (result) throws -> Void in
                if result {
                    self.fetch(self.newProject.value)
                }
            })
    }

    func valid() -> Observable<Bool> {
        return newProject.asObservable()
            .flatMap({ (project) -> Observable<Bool> in
                if project.title?.characters.count < 1 {
                    throw NewProjectValidationError.TitleError
                }
                return Observable.just(true)
            })
    }

    func fetch(newProject: NewProject) {
        let params = Mapper<NewProject>().toJSON(newProject)
        action.request(params)
    }
}
