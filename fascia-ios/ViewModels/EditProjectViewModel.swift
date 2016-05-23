//
//  EditProjectViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/22.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

class EditProjectViewModel {
    private let action = EditProjectAction()
    private(set) var editProject: Variable<EditProject>
    private var project: Project
    final private(set) var title: Variable<String?> = Variable(nil)
    final private(set) var description: Variable<String?> = Variable(nil)
    final private(set) var dataUpdated: Driver<Project?> = Driver.never()
    final private(set) var isLoading: Driver<Bool> = Driver.never()
    final private(set) var error: Driver<ErrorType?> = Driver.never()

    init(project: Project) {
        self.project = project
        let e = EditProject()
        e.title = project.title
        e.projectDescription = project.projectDescription
        editProject = Variable(e)
        dataUpdated = Driver
            .combineLatest(
                action.project.asDriver(),
                action.error.asDriver().map({
                    $0 != nil
                }),
                resultSelector: {
                    ($1) ? nil : $0
            })

        isLoading = action.isLoading.asDriver()
        error = action.error.asDriver()
        title = Variable(self.project.title)
        description = Variable(self.project.projectDescription)
    }
}
