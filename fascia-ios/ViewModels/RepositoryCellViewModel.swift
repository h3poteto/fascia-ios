//
//  RepositoryCellViewModel.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/04.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

class RepositoryCellViewModel {
    let model: BehaviorRelay<Repository>
    let fullName: Observable<String>
    let name: Observable<String>
    let openRepository: Observable<Bool>

    init(model: Repository) {
        self.model = BehaviorRelay(value: model)
        self.fullName = self.model.asObservable().map({ (repository) -> String in
            return repository.fullName!
        })
        self.name = self.model.asObservable().map({ (repository) -> String in
            return repository.name!
        })
        self.openRepository = self.model.asObservable().map({ (repository) -> Bool in
            return !repository.privateRepository!
        })
    }
}
