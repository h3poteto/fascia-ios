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
    let list: BehaviorRelay<List>
    let title: Observable<String>
    let isVisible: Observable<Bool>
    final private(set) var listsUpdated: Driver<Lists?> = Driver.never()
    final private(set) var isLoading: Driver<Bool> = Driver.never()
    final private(set) var err: Driver<Error?> = Driver.never()

    init(model: List) {
        self.list = BehaviorRelay(value: model)
        self.title = self.list.asObservable().map({ (list) -> String in
            return list.title!
        })
        self.isVisible = self.list.asObservable().map({ (list) -> Bool in
            return list.isHidden!
        })

        self.listsUpdated = Driver
            .combineLatest(
                action.lists.asDriver(),
                action.err.asDriver().map({
                    $0 != nil
                }), resultSelector: {
                    ($1) ? nil : $0
            })
        self.isLoading = action.isLoading.asDriver()
        self.err = action.err.asDriver()
    }

    func changeVisible() {
        guard let hidden = list.value.isHidden else {
            return
        }
        if hidden {
            action.display(list: list.value)
        } else {
            action.hide(list: list.value)
        }
    }
}
