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
    final let err: Variable<Error?> = Variable(nil)
    fileprivate let disposeBag = DisposeBag()

    func request() {
        if isLoading.value {
            return
        }
        isLoading.value = true
        err.value = nil
        FasciaAPIService.sharedInstance.call(path: "/github/repositories", method: .get, params: nil)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .map({ (response, data) -> [Repository] in
                guard let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [[String: AnyObject]] else {
                    throw RepositoryError.parserError
                }
                return Repository.buildWithArray(json)
            })
            .subscribe(onNext: { (repositories) in
                    print(repositories)
                    self.repositories.value = repositories
                }, onError: { (errorType) in
                    self.err.value = errorType
                }, onCompleted: {
                    self.isLoading.value = false
                }, onDisposed: nil
            )
            .addDisposableTo(disposeBag)
    }
}
