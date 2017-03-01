//
//  TaskViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2017/02/27.
//  Copyright © 2017年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

class TaskViewModel {
    final private let action = TaskAction()
    final var task: Task!
    var project: Project!
    var list: List!
    final private(set) var taskUpdated: Driver<Task?> = Driver.never()
    final private(set) var isLoading: Driver<Bool> = Driver.never()
    final private(set) var err: Driver<Error?> = Driver.never()

    init(project: Project, list: List, task: Task) {
        self.project = project
        self.list = list
        self.task = task
        taskUpdated = Driver
            .combineLatest(
                action.task.asDriver(),
                action.err.asDriver().map({
                    $0 != nil
                }), resultSelector: {
                    ($1) ? nil : $0
            })
        isLoading = action.isLoading.asDriver()
        err = action.err.asDriver()
    }

    func fetch() {
        action.request(projectID: project.id!, listID: list.id!, taskID: self.task.id!)
    }
}
