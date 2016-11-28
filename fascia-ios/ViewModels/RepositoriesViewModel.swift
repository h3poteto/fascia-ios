//
//  RepositoriesViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/04.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

class RepositoriesViewModel {
    fileprivate final let action = RepositoryAction()
    final var repositories = [Repository]()
    final fileprivate(set) var dataUpdated: Driver<[Repository]> = Driver.never()
    final fileprivate(set) var isLoading: Driver<Bool> = Driver.never()
    final fileprivate(set) var err: Driver<Error?> = Driver.never()
    var selectedRepository: Variable<Repository?> = Variable(nil)


    init() {
        dataUpdated = Driver
            .combineLatest(
                action.repositories.asDriver(),
                action.err.asDriver().map({
                    $0 != nil
                }),
                resultSelector: {
                    ($1) ? [] : $0
            })
        isLoading = action.isLoading.asDriver()
        err = action.err.asDriver()
    }

    func fetch() {
        action.request()
    }
}
