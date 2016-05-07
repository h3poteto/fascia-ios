//
//  TaskCellViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/07.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

class TaskCellViewModel {
    let model: Variable<Task>
    let title: Observable<String>

    init(model: Task) {
        self.model = Variable(model)
        self.title = self.model.asObservable().map({ (task) -> String in
            return task.title!
        })
    }
}
