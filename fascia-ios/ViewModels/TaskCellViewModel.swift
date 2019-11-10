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
    let task: BehaviorRelay<Task>
    let title: Observable<String>
    let color: BehaviorRelay<UIColor>

    init(model: Task, list: List) {
        self.task = BehaviorRelay(value: model)
        self.title = self.task.asObservable().map({ (task) -> String in
            return task.title!
        })
        self.color = BehaviorRelay(value: UIColor(hexString: list.color!)!)
            //UIColor(hexString: list.color!, alpha: 1.0))
    }
}
