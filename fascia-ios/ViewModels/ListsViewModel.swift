//
//  ListsViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/07.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

class ListsViewModel {
    final private let action = ListsAction()
    final var lists: Lists?
    final private var project: Project!
    final private(set) var listsUpdated: Driver<Lists?> = Driver.never()
    final private(set) var isLoading: Driver<Bool> = Driver.never()
    final private(set) var error: Driver<ErrorType?> = Driver.never()

    init(project: Project) {
        self.project = project
        listsUpdated = Driver
            .combineLatest(
                action.lists.asDriver(),
                action.error.asDriver().map({
                    $0 != nil
                }), resultSelector: {
                    ($1) ? nil : $0
            })

        isLoading = action.isLoading.asDriver()
        error = action.error.asDriver()
    }

    func fetch() {
        action.request(project.id!)
    }

}
