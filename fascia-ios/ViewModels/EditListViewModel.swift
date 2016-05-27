//
//  EditListViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/27.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

class EditListViewModel {
    private let editListAction = EditListAction()
    private let listOptionAction = ListOptionsAction()
    private let disposeBag = DisposeBag()
    private(set) var editList: Variable<EditList>
    private var list: List
    final private(set) var title: Variable<String?> = Variable(nil)
    final private(set) var color: Variable<String?> = Variable(nil)
    final private(set) var action: Variable<String?> = Variable(nil)
    final private(set) var dataUpdated: Driver<List?> = Driver.never()
    final private(set) var isLoading: Driver<Bool> = Driver.never()
    final private(set) var error: Driver<ErrorType?> = Driver.never()

    init(model: List) {
        self.list = model
        let edit = EditList()
        edit.title = model.title
        edit.color = model.color
        editList = Variable(edit)


        dataUpdated = Driver
            .combineLatest(
                editListAction.list.asDriver(),
                editListAction.error.asDriver().map({
                    $0 != nil
                }),
                resultSelector: {
                    ($1) ? nil : $0
            })

        isLoading = editListAction.isLoading.asDriver()
        error = editListAction.error.asDriver()
        color.value = editList.value.color
        title.value = editList.value.title
    }

    func loadOption() {
        listOptionAction.listOptions.asObservable()
            .subscribeNext { (listOptions) in
                guard let id = self.list.listOptionID else { return }
                let option = ListOption.findAction(listOptions, id: id)
                self.editList.value
                    .action = option?.action
                self.action.value = option?.action
            }
            .addDisposableTo(disposeBag)
        listOptionAction.request()
    }

    func update(title: String?, color: String?) {
        if title != nil {
            self.title.value = title
            editList.value.title = title
        }
        if color != nil {
            self.color.value = color
            editList.value.color = color
        }
    }
}