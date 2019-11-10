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

enum NewListValidationError: Error {
    case titleError
    case colorError
}

class NewListViewModel {
    private let action = NewListAction()
    private(set) var newList: BehaviorRelay<NewList>
    final private var project: Project!
    final private(set) var title: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    final private(set) var color: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    final private(set) var dataUpdated: Driver<List?> = Driver.never()
    final private(set) var isLoading: Driver<Bool> = Driver.never()
    final private(set) var err: Driver<Error?> = Driver.never()

    init(model: NewList, project: Project) {
        newList = BehaviorRelay(value: model)
        self.project = project

        dataUpdated = Driver
            .combineLatest(
                action.list.asDriver(),
                action.err.asDriver().map({
                    $0 != nil
                }),
                resultSelector: {
                    ($1) ? nil : $0
            })

        isLoading = action.isLoading.asDriver()
        err = action.err.asDriver()
        color.accept(newList.value.color)
        title.accept(newList.value.title)
    }

    func update(title: String?, color: String?) {
        if title != nil {
            self.title.accept(title)
            newList.value.title = title
        }
        if color != nil {
            self.color.accept(color)
            newList.value.color = color
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
        return newList.asObservable()
            .flatMap({ (list) -> Observable<Bool> in
                if (list.title?.count)! < 1 {
                    throw NewListValidationError.titleError
                }
                if list.color?.count != 6 {
                    throw NewListValidationError.colorError
                }
                return Observable.just(true)
            })
    }

    func fetch() {
        let params = Mapper<NewList>().toJSON(newList.value)
        action.request(projectID: project.id!, params: params as [String : AnyObject])
    }
}
