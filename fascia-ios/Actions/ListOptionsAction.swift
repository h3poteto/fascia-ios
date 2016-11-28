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
    final let isLoading = Variable(false)
    final let listOptions = Variable([ListOption]())
    final let err: Variable<Error?> = Variable(nil)
    final let disposeBag = DisposeBag()

    func request() {
        if isLoading.value {
            return
        }
        isLoading.value = false
        err.value = nil
        FasciaAPIService.sharedInstance.call(path: "/list_options", method: .get, params: nil)
            .observeOn(Scheduler.sharedInstance.mainScheduler)
            .subscribeOn(Scheduler.sharedInstance.backgroundScheduler)
            .map { (response, data) throws -> [ListOption] in
                guard let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [[String: AnyObject]] else {
                    throw ListOptionError.parserError
                }
                return ListOption.buildWithArray(listOptions: json)
            }
            .subscribe(onNext: { (listOptions) -> Void in
                print(listOptions)
                self.listOptions.value = listOptions
                }, onError: { (errorType) in
                    self.err.value = errorType
                    self.isLoading.value = false
                }, onCompleted: {
                    self.isLoading.value = false
                }, onDisposed: nil)
            .addDisposableTo(self.disposeBag)
    }
}
