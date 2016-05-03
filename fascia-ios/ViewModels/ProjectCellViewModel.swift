//
//  ProjectCellViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/04/27.
//  Copyright © 2016年 h3poteto. All rights reserved.
//
import RxSwift
import RxCocoa

class ProjectCellViewModel {
    let model: Variable<Project>
    let title: Observable<String>
    let hideRepository: Observable<Bool>

    init(model: Project) {
        self.model = Variable(model)
        self.title = self.model.asObservable().map({ (project) -> String in
            return project.title!
        })
        self.hideRepository = self.model.asObservable().map({ (project) -> Bool in
            if project.repositoryID != nil && project.repositoryID != 0 {
                return false
            } else {
                return true
            }
        })
    }

}
