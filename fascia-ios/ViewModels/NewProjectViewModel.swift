//
//  NewProjectViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/29.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

enum NewProjectValidationError: ErrorType {
    case TitleError
}

class NewProjectViewModel {
    private(set) var project: Variable<Project>

    init(model: Project) {
        self.project = Variable(model)
    }

    func update(title: String?) {
        project.value.title = title
    }

    func save() -> Observable<Bool> {
        return valid()
            .doOnNext({ (result) throws -> Void in
                if result {
                    // api call
                }
            })
    }

    func valid() -> Observable<Bool> {
        return project.asObservable()
            .flatMap({ (project) -> Observable<Bool> in
                if project.title?.characters.count < 1 {
                    throw NewProjectValidationError.TitleError
                }
                return Observable.just(true)
            })
    }

}
