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
    fileprivate let action = EditProjectAction()
    fileprivate(set) var editProject: Variable<EditProject>
    fileprivate var project: Project
    final fileprivate(set) var title: Variable<String?> = Variable(nil)
    final fileprivate(set) var description: Variable<String?> = Variable(nil)
    final fileprivate(set) var dataUpdated: Driver<Project?> = Driver.never()
    final fileprivate(set) var isLoading: Driver<Bool> = Driver.never()
    final fileprivate(set) var err: Driver<Error?> = Driver.never()

    init(project: Project) {
        self.project = project
        let e = EditProject()
        e.title = project.title
        e.projectDescription = project.projectDescription
        editProject = Variable(e)
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
        title = Variable(self.project.title)
        description = Variable(self.project.projectDescription)
    }

    func update(_ title: String?, description: String?) {
        if title != nil {
            self.title.value = title
            self.editProject.value.title = title
        }
        if description != nil {
            self.description.value = description
            self.editProject.value.projectDescription = description
        }
    }

    func save() -> Observable<Bool> {
        return valid()
            .do(onNext: { (result) in
                if result {
                    self.fetch(self.editProject.value)
                }
            }, onError: nil, onCompleted: nil, onSubscribe: nil, onDispose: nil)
    }

    func valid() -> Observable<Bool> {
        return editProject.asObservable()
            .flatMap({ (project) -> Observable<Bool> in
                if (project.title?.characters.count)! < 1 {
                    throw EditProjectValidationError.titleError
                }
                return Observable.just(true)
            })
    }
    func fetch(_ editProject: EditProject) {
        print(editProject)
        let params = Mapper<EditProject>().toJSON(editProject)
        action.request(project.id!, params: params as [String : AnyObject])
    }
}
