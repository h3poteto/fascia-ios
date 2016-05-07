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
    let task: Variable<Task>
    let title: Observable<String>
    let color: Observable<UIColor>

    init(model: Task, list: List) {
        self.task = Variable(model)
        self.title = self.task.asObservable().map({ (task) -> String in
            return task.title!
        })
        self.color = self.task.asObservable().map({ (task) -> UIColor in
            return UIColor(hexString: list.color!, alpha: 1.0)
        })
    }
}
