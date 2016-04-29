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
    private final let request = ProjectsRequest()
    final var projects = [Project]()
    final private(set) var dataUpdated: Driver<[Project]> = Driver.never()
    final private(set) var isLoading: Driver<Bool> = Driver.never()
    final private(set) var error: Driver<ErrorType?> = Driver.never()

    override init() {
        super.init()

        dataUpdated = Driver
            .combineLatest(
                request.projects.asDriver(),
                request.error.asDriver().map({
                    $0 != nil
                }),
                resultSelector: {
                    ($1) ? [] : $0
            })

        isLoading = request.isLoading.asDriver()
        error = request.error.asDriver()
    }

    func fetch() {
        request.request()
    }
}
