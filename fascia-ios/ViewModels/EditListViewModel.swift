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
    private let requestAction = EditListAction()
    private(set) var editList: Variable<EditList>
    private var project: Project
    final private(set) var title: Variable<String?> = Variable(nil)
    final private(set) var color: Variable<String?> = Variable(nil)
    final private(set) var action: Variable<String?> = Variable(nil)
    final private(set) var dataUpdated: Driver<List?> = Driver.never()
    final private(set) var isLoading: Driver<Bool> = Driver.never()
    final private(set) var error: Driver<ErrorType?> = Driver.never()

    init(model: List, project: Project) {
        let list = EditList()
        list.title = model.title
        list.color = model.color
        editList = Variable(list)

        self.project = project

        dataUpdated = Driver
            .combineLatest(
                requestAction.list.asDriver(),
                requestAction.error.asDriver().map({
                    $0 != nil
                }),
                resultSelector: {
                    ($1) ? nil : $0
            })

        isLoading = requestAction.isLoading.asDriver()
        error = requestAction.error.asDriver()
        color.value = editList.value.color
        title.value = editList.value.title
    }
}

