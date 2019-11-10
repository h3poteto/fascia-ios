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
    final let isLoading = BehaviorRelay(value: false)
    final var repositories = BehaviorRelay(value: [Repository]())
    final let err: BehaviorRelay<Error?> = BehaviorRelay(value: nil)
    private let disposeBag = DisposeBag()

    func request() {
        if isLoading.value {
            return
        }
        isLoading.accept(true)
        err.accept(nil)
        FasciaAPIService.sharedInstance.call(path: "/api/github/repositories", method: .get, params: nil)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .map({ (_, data) -> [Repository] in
                guard let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [[String: AnyObject]] else {
                    throw RepositoryError.parserError
                }
                return Repository.buildWithArray(repositories: json)
            })
            .subscribe(onNext: { (repositories) in
                print(repositories)
                self.repositories.accept(repositories)
            }, onError: { (errorType) in
                self.err.accept(errorType)
            }, onCompleted: {
                self.isLoading.accept(false)
            }, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}
