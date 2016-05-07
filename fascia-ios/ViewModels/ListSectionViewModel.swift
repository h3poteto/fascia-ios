//
//  ListSectionViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/07.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

class ListSectionViewModel {
    final private let action = ListVisibleAction()
    let list: Variable<List>
    let title: Observable<String>
    let isVisible: Observable<Bool>

    init(model: List) {
        self.list = Variable(model)
        self.title = self.list.asObservable().map({ (list) -> String in
            return list.title!
        })
        self.isVisible = self.list.asObservable().map({ (list) -> Bool in
            return list.isHidden!
        })
    }

    func changeVisible() {
        guard let hidden = list.value.isHidden else {
            return
        }
        if hidden {
            action.display(list.value)
        } else {
            action.hide(list.value)
        }
    }
}
