//
//  NewListViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/17.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa
import ObjectMapper

enum NewListValidationError: ErrorType {
    case TitleError
    case ColorError
}

class NewListViewModel {
    private let action = NewListAction()
    private(set) var newList: Variable<NewList>
    final private var project: Project!
    final private(set) var title: Variable<String?> = Variable(nil)
    final private(set) var color: Variable<String?> = Variable(nil)

    init(model: NewList, project: Project) {
        newList = Variable(model)
        self.project = project
    }

    func update(title: String?, color: String?) {
        if title != nil {
            self.title.value = title
            newList.value.title = title
        }
        if color != nil {
            self.color.value = color
            newList.value.color = color
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
        return newList.asObservable()
            .flatMap({ (list) -> Observable<Bool> in
                if list.title?.characters.count < 1 {
                    throw NewListValidationError.TitleError
                }
                if list.color?.characters.count != 6 {
                    throw NewListValidationError.ColorError
                }
                return Observable.just(true)
            })
    }

    func fetch() {
        let params = Mapper<NewList>().toJSON(newList.value)
        action.request(project.id!, params: params)
    }
}
