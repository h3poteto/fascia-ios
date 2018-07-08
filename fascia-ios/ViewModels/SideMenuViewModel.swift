//
//  SideMenuViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2018/07/08.
//  Copyright © 2018年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

class SideMenuViewModel: NSObject {
    private final let action = SessionAction()
    final private(set) var isLoading: Driver<Bool> = Driver.never()
    final private(set) var err: Driver<Error?> = Driver.never()
    final private(set) var completed: Driver<Bool> = Driver.never()

    override init() {
        super.init()
        isLoading = action.isLoading.asDriver()
        err = action.err.asDriver()
        completed = action.completed.asDriver()
    }

    func fetch() {
        action.deleteSession()
    }
}
