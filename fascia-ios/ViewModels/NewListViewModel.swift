//
//  NewListViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/17.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

class NewListViewModel {
    private(set) var newList: Variable<NewList>
    final private(set) var title: Variable<String?> = Variable(nil)
    final private(set) var color: Variable<String?> = Variable(nil)

    init(model: NewList) {
        newList = Variable(model)
    }

    func update(title: String?, color: String?) {
        if title != nil {
            self.title.value = title
            newList.value.title = title
        }
        if color != nil {
            self.color.value = color
            newList.value.color = color
        }
    }
}
