//
//  RepositoryAction.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/04.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa
import ObjectMapper

class RepositoryAction {
    final let isLoading = Variable(false)
    final var repositories = Variable([Repository]())
    final let error: Variable<ErrorType?> = Variable(nil)
    private let disposeBag = DisposeBag()

    func request() {
        if isLoading.value {
            return
        }
        isLoading.value = true
        error.value = nil
        FasciaAPIService.sharedInstance.call("/github/repositories", method: .GET, params: nil)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .map({ (response, data) -> [Repository] in
                guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [[String: AnyObject]] else {
                    throw RepositoryError.ParserError
                }
                return Repository.buildWithArray(json)
            })
            .subscribe(onNext: { (repositories) in
                    self.repositories.value = repositories
                }, onError: { (errorType) in
                    self.error.value = errorType
                }, onCompleted: {
                    self.isLoading.value = false
                }, onDisposed: nil
            )
            .addDisposableTo(disposeBag)
    }
}
