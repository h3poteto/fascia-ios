//
//  EditProjectViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/22.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa
import ObjectMapper

enum EditProjectValidationError: Error {
    case titleError
}

class EditProjectViewModel {
    private let action = EditProjectAction()
    private(set) var editProject: BehaviorRelay<EditProject>
    private var project: Project
    final private(set) var title: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    final private(set) var description: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    final private(set) var dataUpdated: Driver<Project?> = Driver.never()
    final private(set) var isLoading: Driver<Bool> = Driver.never()
    final private(set) var err: Driver<Error?> = Driver.never()

    init(project: Project) {
        self.project = project
        let e = EditProject()
        e.title = project.title
        e.projectDescription = project.projectDescription
        editProject = BehaviorRelay(value: e)
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
        title = BehaviorRelay(value: self.project.title)
        description = BehaviorRelay(value: self.project.projectDescription)
    }

    func update(title: String?, description: String?) {
        if title != nil {
            self.title.accept(title)
            self.editProject.value.title = title
        }
        if description != nil {
            self.description.accept(description)
            self.editProject.value.projectDescription = description
        }
    }

    func save() -> Observable<Bool> {
        return valid()
            .do(onNext: { (result) in
                if result {
                    self.fetch(editProject: self.editProject.value)
                }
            }, onError: nil, onCompleted: nil, onSubscribe: nil, onDispose: nil)
    }

    func valid() -> Observable<Bool> {
        return editProject.asObservable()
            .flatMap({ (project) -> Observable<Bool> in
                if (project.title?.count)! < 1 {
                    throw EditProjectValidationError.titleError
                }
                return Observable.just(true)
            })
    }
    func fetch(editProject: EditProject) {
        print(editProject)
        let params = Mapper<EditProject>().toJSON(editProject)
        action.request(projectID: project.id!, params: params as [String : AnyObject])
    }
}
