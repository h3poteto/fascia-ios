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

enum NewProjectValidationError: Error {
    case titleError
}

class NewProjectViewModel {
    final private let action = NewProjectAction()
    private(set) var newProject: BehaviorRelay<NewProject>
    final private(set) var title: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    var repository: BehaviorRelay<Repository?> = BehaviorRelay(value: nil)
    final private(set) var dataUpdated: Driver<Project?> = Driver.never()
    final private(set) var isLoading: Driver<Bool> = Driver.never()
    final private(set) var err: Driver<Error?> = Driver.never()

    init(model: NewProject) {
        self.newProject = BehaviorRelay(value: model)

        dataUpdated = Driver
            .combineLatest(
                action.project.asDriver(),
                action.err.asDriver().map({
                    $0 != nil
                }),
                resultSelector: {
                    ($1) ? nil : $0
            })

        isLoading = action.isLoading.asDriver()
        err = action.err.asDriver()
    }

    func update(title: String?, description: String?, repository: Repository?) {
        if title != nil {
            newProject.value.title = title
            self.title.accept(title)
        }
        if description != nil {
            newProject.value.projectDescription = description
        }
        if repository != nil {
            newProject.value.repositoryName = repository?.name
            newProject.value.repositoryID = repository?.id
            newProject.value.repositoryOwner = repository?.ownerName
        }
    }

    func save() -> Observable<Bool> {
        return valid()
            .do(onNext: { (result) in
                if result {
                    self.fetch(newProject: self.newProject.value)
                }
            }, onError: nil, onCompleted: nil, onSubscribe: nil, onDispose: nil)
    }

    func valid() -> Observable<Bool> {
        return newProject.asObservable()
            .flatMap({ (project) -> Observable<Bool> in
                if (project.title?.count)! < 1 {
                    throw NewProjectValidationError.titleError
                }
                return Observable.just(true)
            })
    }

    func fetch(newProject: NewProject) {
        print(newProject)
        let params = Mapper<NewProject>().toJSON(newProject)
        action.request(parameter: params as [String : AnyObject])
    }
}
