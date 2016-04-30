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
    private final let request = NewProjectRequest()
    private(set) var newProject: Variable<NewProject>
    final private(set) var dataUpdated: Driver<Project?> = Driver.never()
    final private(set) var isLoading: Driver<Bool> = Driver.never()
    final private(set) var error: Driver<ErrorType?> = Driver.never()

    init(model: NewProject) {
        self.newProject = Variable(model)

        dataUpdated = Driver
            .combineLatest(
                request.project.asDriver(),
                request.error.asDriver().map({ (error) in
                    return error != nil
                }),
                resultSelector: { (project, error) -> Project? in
                    guard error is ErrorType else {
                        return nil
                    }
                    return project
            })
        isLoading = request.isLoading.asDriver()
        error = request.error.asDriver()
    }

    func update(title: String?) {
        newProject.value.title = title
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
        request.request(params)
    }
}
