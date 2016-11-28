//
//  TaskCellViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/07.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa
import ChameleonFramework

class TaskCellViewModel {
    let task: Variable<Task>
    let title: Observable<String>
    let color: Variable<UIColor>

    init(model: Task, list: List) {
        self.task = Variable(model)
        self.title = self.task.asObservable().map({ (task) -> String in
            return task.title!
        })
        self.color = Variable(UIColor(hexString: list.color!)!)
            //UIColor(hexString: list.color!, alpha: 1.0))
    }
}
