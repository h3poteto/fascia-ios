//
//  ProjectsViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/24.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

class ProjectsViewModel: NSObject {
    private final let action = ProjectsAction()
    final var projects = [Project]()
    final fileprivate(set) var dataUpdated: Driver<[Project]> = Driver.never()
    final fileprivate(set) var isLoading: Driver<Bool> = Driver.never()
    final fileprivate(set) var err: Driver<Error?> = Driver.never()

    override init() {
        super.init()

        dataUpdated = Driver
            .combineLatest(
                action.projects.asDriver(),
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
