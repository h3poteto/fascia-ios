//
//  EditListViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/27.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa
import ObjectMapper

enum EditListValidationError: Error {
    case titleError
    case colorError
}

class EditListViewModel {
    fileprivate let editListAction = EditListAction()
    fileprivate let listOptionAction = ListOptionsAction()
    fileprivate let disposeBag = DisposeBag()
    fileprivate(set) var editList: Variable<EditList>
    fileprivate var list: List
    var listOptions = [ListOption]()
    final fileprivate(set) var title: Variable<String?> = Variable(nil)
    final fileprivate(set) var color: Variable<String?> = Variable(nil)
    final fileprivate(set) var action: Variable<String?> = Variable(nil)
    final fileprivate(set) var dataUpdated: Driver<List?> = Driver.never()
    final fileprivate(set) var isLoading: Driver<Bool> = Driver.never()
    final fileprivate(set) var err: Driver<Error?> = Driver.never()

    init(model: List) {
        self.list = model
        let edit = EditList()
        edit.title = model.title
        edit.color = model.color
        editList = Variable(edit)

        dataUpdated = Driver
            .combineLatest(
                editListAction.list.asDriver(),
                editListAction.err.asDriver().map({
                    $0 != nil
                }),
                resultSelector: {
                    ($1) ? nil : $0
            })

        isLoading = editListAction.isLoading.asDriver()
        err = editListAction.err.asDriver()
        color.value = editList.value.color
        title.value = editList.value.title
    }

    func loadOption() {
        listOptionAction.listOptions.asObservable()
            .subscribe(onNext: { (listOptions) in
                guard let id = self.list.listOptionID else { return }
                let option = ListOption.findAction(listOptions: listOptions, id: id)
                self.editList.value
                    .action = option?.action
                self.action.value = option?.action
                self.listOptions = listOptions
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        listOptionAction.request()
    }

    func update(_ title: String?, color: String?, option: ListOption?) {
        if title != nil {
            self.title.value = title
            editList.value.title = title
        }
        if color != nil {
            self.color.value = color
            editList.value.color = color
        }
        if option != nil {
            self.action.value = option?.action
            editList.value.action = option?.action
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
        return editList.asObservable()
            .flatMap({ (list) -> Observable<Bool> in
                if (list.title?.characters.count)! < 1 {
                    throw EditListValidationError.titleError
                }
                if list.color?.characters.count != 6 {
                    throw EditListValidationError.colorError
                }
                return Observable.just(true)
            })
    }

    func fetch() {
        let params = Mapper<EditList>().toJSON(editList.value)
        editListAction.request(projectID: list.projectID!, listID: list.id!, params: params as [String : AnyObject])
    }
}
