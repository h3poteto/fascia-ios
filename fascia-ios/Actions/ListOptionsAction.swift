//
//  ListOptionsAction.swift
//  fascia-ios
//
//  Created by akirafukushima on 2016/05/28.
//  Copyright © 2016年 h3poteto. All rights reserved.
//

import RxSwift
import RxCocoa

class ListOptionsAction {
    final let isLoading = BehaviorRelay(value: false)
    final let listOptions = BehaviorRelay(value: [ListOption]())
    final let err: BehaviorRelay<Error?> = BehaviorRelay(value: nil)
    private let disposeBag = DisposeBag()

    func request() {
        if isLoading.value {
            return
        }
        isLoading.accept(false)
        err.accept(nil)
        FasciaAPIService.sharedInstance.call(path: "/api/list_options", method: .get, params: nil)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .map { (_, data) throws -> [ListOption] in
                guard let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [[String: AnyObject]] else {
                    throw ListOptionError.parserError
                }
                return ListOption.buildWithArray(listOptions: json)
            }
            .subscribe(onNext: { (listOptions) -> Void in
                print(listOptions)
                self.listOptions.accept(listOptions)
            }, onError: { (errorType) in
                self.err.accept(errorType)
                self.isLoading.accept(false)
            }, onCompleted: {
                self.isLoading.accept(false)
            }, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}
